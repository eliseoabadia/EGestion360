using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.Adquisicion;

public static class RequisitionJourneyReader
{
    public static async Task<RequisitionJourney> ReadAsync(EGestionContext context, int id, int companyId, int yearId)
    {
        // Anchor every branch to the authorized company/year; do not infer downstream
        // progress from the requisition's editable status or from the visible grid page.
        var requisition = context.Requisicions.AsNoTracking().Where(x => x.PkidRequisicion == id
            && x.FkidEmpresaSis == companyId && x.FkidAnioSis == yearId && x.Activo);
        var requests = context.SolicitudSuficiencia.AsNoTracking().Where(x => x.Activo
            && x.FkidEmpresaSis == companyId && requisition.Any(r => r.PkidRequisicion == x.FkidRequisicionOrco));
        var authorizations = context.AutorizacionSuficiencia.AsNoTracking().Where(x => x.Activo
            && x.FkidEmpresaSis == companyId && x.Estatus == 2
            && requests.Any(s => s.PkidSolicitudSuficiencia == x.FkidSolicitudSuficienciaPres));
        var commitments = context.Contratos1.AsNoTracking().Where(x => x.Activo && x.FkidEmpresaSis == companyId
            && authorizations.Any(a => a.PkidAutorizacionSuficiencia == x.FkidAutorizacionSuficienciaPres));
        var orders = context.OrdenCompras.AsNoTracking().Where(x => x.Activo && x.FkidEmpresaSis == companyId
            && requisition.Any(r => r.PkidRequisicion == x.FkidRequisicionOrco));
        var invoices = context.Facturas.AsNoTracking().Where(x => x.Activo && x.FkidEmpresaSis == companyId
            && commitments.Any(c => c.PkidContrato == x.FkidContratoPres));
        var provisions = context.Clcs.AsNoTracking().Where(x => x.Activo && x.FkidEmpresaSis == companyId
            && commitments.Any(c => c.PkidContrato == x.FkidContratoPres));
        var result = new RequisitionJourney();
        if (!await requisition.AnyAsync()) return result;
        result.Steps.Add(new("Requisición", true, "Registrada"));
        var quotes = await context.Cotizacions.AsNoTracking().CountAsync(x => x.Activo
            && requisition.Any(r => r.PkidRequisicion == x.FkidRequisicionOrco));
        result.Steps.Add(new("Cotización", quotes > 0, quotes > 0 ? $"{quotes} registrada(s)" : "Sin cotización registrada"));
        result.Steps.Add(new("Suficiencia", await authorizations.AnyAsync(), "Palomita cuando existe autorización vigente"));
        result.Steps.Add(new("Compromiso", await commitments.AnyAsync(x => x.Estatus == 2), "Palomita cuando existe compromiso autorizado"));
        var orderCount = await orders.CountAsync();
        var authorizedOrders = await orders.CountAsync(x => x.FkidEstatusOrdenCompraOrco == 2);
        result.Steps.Add(new("Orden de compra", orderCount > 0,
            orderCount == 0 ? "Sin orden registrada" : $"{orderCount} creada(s); {authorizedOrders} por surtir"));
        var lines = context.OrdenCompraDetalles.AsNoTracking().Where(x => x.Activo
            && orders.Any(o => o.PkidOrdenCompra == x.FkidOrdenCompraOrco));
        var hasLines = await lines.AnyAsync();
        var received = await lines.AnyAsync(x => x.CantidadRecibida > 0);
        var outstanding = await lines.AnyAsync(x => x.CantidadSolicitada > x.CantidadRecibida);
        result.Steps.Add(new("Recepción", hasLines && received && !outstanding,
            received ? outstanding ? "Recepción parcial" : "Renglones recibidos" : "Sin recepción registrada", received && outstanding));
        result.Steps.Add(new("Factura", await invoices.AnyAsync(), "Palomita cuando existe factura activa vinculada al compromiso"));
        result.Steps.Add(new("Provisión / CLC", await provisions.AnyAsync(), "Documento de trámite de pago registrado"));
        var cheques = await context.Cheques.AsNoTracking().CountAsync(x => x.Activo && x.FkidEmpresaSis == companyId
            && provisions.Any(p => p.PkidClc == x.FkidClcPres));
        result.Steps.Add(new("Cheque", cheques > 0, cheques > 0
            ? $"{cheques} registrado(s). El registro no confirma el cobro." : "Sin cheque vinculado"));
        return result;
    }
}

using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.Almacen;

public static class OrderReceiptWriter
{
    public static async Task ApplyAsync(EGestionContext context, IUserContextService userContext,
        int detailId, decimal delta, int actor, CancellationToken cancellationToken = default)
    {
        if (context.Database.CurrentTransaction is null)
            throw new InvalidOperationException("La recepción requiere una transacción compartida con el movimiento.");
        var company = userContext.GetCurrentEmpresaId();
        var year = userContext.GetCurrentAnioPresupuestalId();
        var now = DateTime.Now;
        var affected = await context.OrdenCompraDetalles.Where(detail =>
                detail.PkidOrdenCompraDetalle == detailId && detail.Activo &&
                detail.FkidOrdenCompraOrcoNavigation.Activo &&
                detail.FkidOrdenCompraOrcoNavigation.FkidEstatusOrdenCompraOrco >= 2 &&
                detail.FkidOrdenCompraOrcoNavigation.FkidEmpresaSis == company &&
                detail.FkidOrdenCompraOrcoNavigation.FkidRequisicionOrcoNavigation.FkidAnioSis == year &&
                detail.CantidadRecibida + delta >= 0 &&
                detail.CantidadRecibida + delta <= detail.CantidadSolicitada)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(detail => detail.CantidadRecibida, detail => detail.CantidadRecibida + delta)
                .SetProperty(detail => detail.FechaModificacion, now)
                .SetProperty(detail => detail.UsuarioModificacion, actor), cancellationToken);
        if (affected != 1)
            throw new InvalidOperationException(EG.Common.ApplicationText.Validation.ReceiptRejected);
    }
}

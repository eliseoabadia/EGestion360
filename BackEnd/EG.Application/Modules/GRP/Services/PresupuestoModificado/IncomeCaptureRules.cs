using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Common.Modules;

namespace EG.Application.Services.PresupuestoModificado;

public static class IncomeCaptureRules
{
    // Matches decimal(18,2) parameters and @Importe in the existing income procedure.
    public const decimal MaximumAmount = IncomeAmountRules.MaximumAmount;

    public static string? ValidateDetailCapture(IngreAdecuacionDetalleResponse request)
    {
        if (request.FkidIngreAdecuacionPres <= 0 || request.FkidIngresoAutorizadoPres <= 0)
            return "Selecciona la adecuacion y el ingreso autorizado.";
        if (request.Fecha == default)
            return "Captura una fecha valida.";
        if (request.FkidTipoMovimientoPres is not (3 or 4))
            return "Para ingresos solo se permiten aumentos o reducciones.";

        (string Name, decimal Value)[] amounts =
        [
            ("enero", request.Enero), ("febrero", request.Febrero), ("marzo", request.Marzo),
            ("abril", request.Abril), ("mayo", request.Mayo), ("junio", request.Junio),
            ("julio", request.Julio), ("agosto", request.Agosto), ("septiembre", request.Septiembre),
            ("octubre", request.Octubre), ("noviembre", request.Noviembre), ("diciembre", request.Diciembre)
        ];
        decimal total = 0m;
        foreach (var amount in amounts)
        {
            var error = IncomeAmountRules.ValidateMonth(amount.Value);
            if (error != null) return $"Revisa {amount.Name}: {error}";
            total += amount.Value;
        }
        if (total <= 0m) return "Solicita un importe para al menos un mes.";
        return total > MaximumAmount ? "El importe total supera la capacidad del registro." : null;
    }

    public static bool IsLocked(IngreAdecuacionResponse current) =>
        current.Autorizado || current.FkidAccionAdecuacionMasterPres == 2;

    public static string? ValidateUpdate(IngreAdecuacionResponse request, IngreAdecuacionResponse current)
    {
        if (IsLocked(current))
            return "La adecuacion esta en autorizacion o ya fue autorizada y no puede modificarse.";
        if (request.FkidAnioSis != current.FkidAnioSis ||
            (request.FkidPolizaConta.HasValue && request.FkidPolizaConta != current.FkidPolizaConta))
            return "No se permite cambiar el ejercicio o la poliza de una adecuacion existente.";
        if (request.Fecha == default) return "Captura una fecha valida.";
        return null;
    }

    public static void PrepareCreate(IngreAdecuacionResponse request)
    {
        request.Autorizado = false;
        request.FkidAccionAdecuacionMasterPres = 1;
        request.FechaSolicitud = null;
        request.FechaAutorizacion = null;
    }

    public static void PreserveServerState(IngreAdecuacionResponse request, IngreAdecuacionResponse current)
    {
        request.PkidIngreAdecuacion = current.PkidIngreAdecuacion;
        request.Clave = current.Clave;
        request.FkidAnioSis = current.FkidAnioSis;
        request.FkidPolizaConta = current.FkidPolizaConta;
        request.FkidEstatusAdecuacionPres = current.FkidEstatusAdecuacionPres;
        request.Autorizado = current.Autorizado;
        request.FkidAccionAdecuacionMasterPres = current.FkidAccionAdecuacionMasterPres;
        request.FechaSolicitud = current.FechaSolicitud;
        request.FechaAutorizacion = current.FechaAutorizacion;
        request.Activo = current.Activo;
        request.UsuarioCreacion = current.UsuarioCreacion;
        request.FechaCreacion = current.FechaCreacion;
    }
}

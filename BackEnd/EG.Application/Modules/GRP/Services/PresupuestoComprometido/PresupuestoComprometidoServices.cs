using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;

namespace EG.Application.Services.PresupuestoComprometido
{
    public class AutorizacionSuficienciaAppService(
        GenericService<AutorizacionSuficiencium, AutorizacionSuficienciaDto, AutorizacionSuficienciaResponse> service,
        GenericService<VwAutorizacionSuficiencium, AutorizacionSuficienciaDto, AutorizacionSuficienciaResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<AutorizacionSuficiencium, VwAutorizacionSuficiencium, AutorizacionSuficienciaDto, AutorizacionSuficienciaResponse>(
            service,
            serviceView,
            context,
            "PkidAutorizacionSuficiencia",
            "Autorizacion de suficiencia",
            (dto, id) => dto.PkidAutorizacionSuficiencia = id,
            "PRES.SP_MantenimientoAutorizacionSuficiencia",
            response => response.PkidAutorizacionSuficiencia,
            BuildParameters)
    {
        private static SqlParameter[] BuildParameters(int action, int? id, AutorizacionSuficienciaResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdAutorizacionSuficiencia", id ?? response?.PkidAutorizacionSuficiencia),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdSolicitudSuficiencia_PRES", response?.FkidSolicitudSuficienciaPres),
                StoredProcedureExecutor.Param("@FechaAutorizacion", ToDateTime(response?.FechaAutorizacion)),
                StoredProcedureExecutor.Param("@Justificacion", response?.Justificacion),
                StoredProcedureExecutor.Param("@GastoNoProgramable", response?.GastoNoProgramable),
                StoredProcedureExecutor.Param("@IdGastoNoProgramable", response?.IdGastoNoProgramable),
                StoredProcedureExecutor.Param("@IdCompromisoNomina", response?.IdCompromisoNomina),
                StoredProcedureExecutor.Param("@AutorizadoPor_NOM", response?.AutorizadoPorNom),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }

        private static DateTime? ToDateTime(DateOnly? value)
        {
            return value.HasValue && value.Value != default
                ? value.Value.ToDateTime(TimeOnly.MinValue)
                : null;
        }
    }

    public class AutorizacionSuficienciaDetalleAppService(
        GenericService<AutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto, AutorizacionSuficienciaDetalleResponse> service,
        GenericService<VwAutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto, AutorizacionSuficienciaDetalleResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<AutorizacionSuficienciaDetalle, VwAutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto, AutorizacionSuficienciaDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidAutorizacionSuficienciaDetalle",
            "Detalle de autorizacion de suficiencia",
            (dto, id) => dto.PkidAutorizacionSuficienciaDetalle = id,
            "PRES.SP_MantenimientoAutorizacionSuficiencia",
            response => response.PkidAutorizacionSuficienciaDetalle,
            BuildParameters)
    {
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

        private static SqlParameter[] BuildParameters(int action, int? id, AutorizacionSuficienciaDetalleResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdAutorizacionSuficiencia", response?.FkidAutorizacionSuficienciaPres),
                StoredProcedureExecutor.Param("@PKIdAutorizacionSuficienciaDetalle", id ?? response?.PkidAutorizacionSuficienciaDetalle),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdSolicitudSuficienciaDetalle_PRES", response?.FkidSolicitudSuficienciaDetallePres),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response?.FkidPartidaConta),
                StoredProcedureExecutor.Param("@Enero", response?.Enero),
                StoredProcedureExecutor.Param("@Febrero", response?.Febrero),
                StoredProcedureExecutor.Param("@Marzo", response?.Marzo),
                StoredProcedureExecutor.Param("@Abril", response?.Abril),
                StoredProcedureExecutor.Param("@Mayo", response?.Mayo),
                StoredProcedureExecutor.Param("@Junio", response?.Junio),
                StoredProcedureExecutor.Param("@Julio", response?.Julio),
                StoredProcedureExecutor.Param("@Agosto", response?.Agosto),
                StoredProcedureExecutor.Param("@Septiembre", response?.Septiembre),
                StoredProcedureExecutor.Param("@Octubre", response?.Octubre),
                StoredProcedureExecutor.Param("@Noviembre", response?.Noviembre),
                StoredProcedureExecutor.Param("@Diciembre", response?.Diciembre),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }
}

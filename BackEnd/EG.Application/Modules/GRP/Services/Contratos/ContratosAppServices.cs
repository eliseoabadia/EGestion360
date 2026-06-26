using EG.Application.Interfaces.Contratos;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contratos;
using EG.Domain.DTOs.Responses.Contratos;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Contratos
{
    public class RegistroCompromisoAppService(
        GenericService<Contrato, OrcoContratoDto, OrcoContratoResponse> service,
        GenericService<VwContrato1, OrcoContratoDto, OrcoContratoResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Contrato, VwContrato1, OrcoContratoDto, OrcoContratoResponse>(
            service,
            serviceView,
            context,
            "PkidContrato",
            "Registro de compromiso",
            (dto, id) => dto.PkidContrato = id,
            "ORCO.SP_MantenimientoContratos",
            response => response.PkidContrato,
            BuildParameters),
            IRegistroCompromisoAppService
    {
        private const int EstatusInicial = 1;
        private const int EstatusAutorizado = 2;
        private readonly EGestionContext _context = context;

        public override async Task<PagedResult<OrcoContratoResponse>> CreateAsync(OrcoContratoResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<OrcoContratoResponse>> UpdateAsync(int id, OrcoContratoResponse response, int usuarioActual)
        {
            var current = await GetCurrentAsync(id);
            if (current == null)
            {
                return Failure<OrcoContratoResponse>($"Registro de compromiso con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (current.FkidEstatusContratoOrco > EstatusInicial)
            {
                return Failure<OrcoContratoResponse>("El registro ya fue autorizado. No se puede editar.", "LOCKED");
            }

            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.FkidEstatusContratoOrco = current.FkidEstatusContratoOrco;
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await GetCurrentAsync(id);
            if (current == null)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Registro de compromiso con ID {id} no encontrado.",
                    Code = "NOT_FOUND",
                    Data = false,
                    TotalCount = 0
                };
            }

            if (current.FkidEstatusContratoOrco > EstatusInicial)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "El registro ya fue autorizado. No se puede eliminar.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            return await base.DeleteAsync(id);
        }

        public async Task<PagedResult<OrcoContratoResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var result = await GetByIdAsync(id);
            if (!result.Success || result.Data == null)
            {
                return Failure<OrcoContratoResponse>($"Registro de compromiso con ID {id} no encontrado.", "NOT_FOUND");
            }

            var registro = result.Data;
            if (registro.FkidEstatusContratoOrco != EstatusInicial)
            {
                return Failure<OrcoContratoResponse>("Solo se pueden autorizar registros en estatus inicial.", "LOCKED");
            }

            registro.FkidEstatusContratoOrco = EstatusAutorizado;
            var updated = await base.UpdateAsync(id, registro, usuarioActual);
            updated.Message = updated.Success ? "Registro de compromiso autorizado correctamente." : updated.Message;
            return updated;
        }

        private async Task<PagedResult<OrcoContratoResponse>?> NormalizeAndValidateAsync(OrcoContratoResponse response, bool isCreate)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe existir una empresa seleccionada.");
            }

            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<OrcoContratoResponse>("La descripcion es requerida.");
            }

            if (response.FkidTipoContratoOrco <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar un tipo de contrato.");
            }

            if (response.FkidTipoDocumentoOrco <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar un tipo de documento.");
            }

            if (response.FechaContrato == default)
            {
                response.FechaContrato = DateTime.Today;
            }

            if (isCreate || response.FkidEstatusContratoOrco <= 0)
            {
                response.FkidEstatusContratoOrco = EstatusInicial;
            }

            response.Numero ??= string.Empty;
            response.FundamentoJuridico ??= string.Empty;
            response.PlazoEjecucion ??= string.Empty;
            response.FlArchivo ??= string.Empty;
            response.Justificacion ??= string.Empty;
            response.SesionSubcomite ??= string.Empty;
            response.Activo = true;

            await Task.CompletedTask;
            return null;
        }

        private Task<Contrato?> GetCurrentAsync(int id)
        {
            return _context.Contratos
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidContrato == id && x.Activo);
        }

        private static SqlParameter[] BuildParameters(int action, int? id, OrcoContratoResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdContrato", id ?? response?.PkidContrato),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdOrdenCompra_ORCO", response?.FkidOrdenCompraOrco),
                StoredProcedureExecutor.Param("@FKIdTipoContrato_ORCO", response?.FkidTipoContratoOrco),
                StoredProcedureExecutor.Param("@FKIdTipoDocumento_ORCO", response?.FkidTipoDocumentoOrco),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response?.FkidAreaSis),
                StoredProcedureExecutor.Param("@FKIdTipoGarantia_ORCO", response?.FkidTipoGarantiaOrco),
                StoredProcedureExecutor.Param("@FKIdProcedimientoContratacion_ORCO", response?.FkidProcedimientoContratacionOrco),
                StoredProcedureExecutor.Param("@FKIdFundamentoJuridico_ORCO", response?.FkidFundamentoJuridicoOrco),
                StoredProcedureExecutor.Param("@FundamentoJuridico", response?.FundamentoJuridico),
                StoredProcedureExecutor.Param("@Numero", response?.Numero),
                StoredProcedureExecutor.Param("@Descripcion", response?.Descripcion),
                StoredProcedureExecutor.Param("@FechaContrato", response?.FechaContrato.Date),
                StoredProcedureExecutor.Param("@FechaRecepcion", response?.FechaRecepcion?.Date),
                StoredProcedureExecutor.Param("@FechaFirmaContrato", response?.FechaFirmaContrato?.Date),
                StoredProcedureExecutor.Param("@FechaVigenciaInicio", response?.FechaVigenciaInicio?.Date),
                StoredProcedureExecutor.Param("@FechaVigenciaFin", response?.FechaVigenciaFin?.Date),
                StoredProcedureExecutor.Param("@FKIdModalidad_ORCO", response?.FkidModalidadOrco),
                StoredProcedureExecutor.Param("@MontoMaximo", response?.MontoMaximo),
                StoredProcedureExecutor.Param("@MontoMinimo", response?.MontoMinimo),
                StoredProcedureExecutor.Param("@Penalizacion", response?.Penalizacion),
                StoredProcedureExecutor.Param("@PlazoEjecucion", response?.PlazoEjecucion),
                StoredProcedureExecutor.Param("@FL_Archivo", response?.FlArchivo),
                StoredProcedureExecutor.Param("@Justificacion", response?.Justificacion),
                StoredProcedureExecutor.Param("@FKIdArticulo_ORCO", response?.FkidArticuloOrco),
                StoredProcedureExecutor.Param("@FKIdFraccion_ORCO", response?.FkidFraccionOrco),
                StoredProcedureExecutor.Param("@SesionSubcomite", response?.SesionSubcomite),
                StoredProcedureExecutor.Param("@IsSesionExtraordinaria", response?.IsSesionExtraordinaria),
                StoredProcedureExecutor.Param("@FechaSesionSubcomite", response?.FechaSesionSubcomite?.Date),
                StoredProcedureExecutor.Param("@FKIdEstatusContrato_ORCO", response?.FkidEstatusContratoOrco),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class SaldosContratoAppService(
        GenericService<VwEgreCompNoDev, SaldosContratoResponse, SaldosContratoResponse> service,
        GenericService<VwEgreCompNoDev, SaldosContratoResponse, SaldosContratoResponse> serviceView)
        : AdquisicionCrudAppService<VwEgreCompNoDev, VwEgreCompNoDev, SaldosContratoResponse, SaldosContratoResponse>(
            service,
            serviceView,
            "PkidContrato",
            "Saldos de contrato",
            (dto, id) => dto.PkidContrato = id)
    {
        public override Task<PagedResult<SaldosContratoResponse>> CreateAsync(SaldosContratoResponse response, int usuarioActual) =>
            Task.FromResult(ReadOnlyFailure<SaldosContratoResponse>());

        public override Task<PagedResult<SaldosContratoResponse>> UpdateAsync(int id, SaldosContratoResponse response, int usuarioActual) =>
            Task.FromResult(ReadOnlyFailure<SaldosContratoResponse>());

        public override Task<PagedResult<bool>> DeleteAsync(int id) =>
            Task.FromResult(ReadOnlyFailure<bool>());

        private static PagedResult<T> ReadOnlyFailure<T>() => new()
        {
            Success = false,
            Message = "La vista de saldos de contratos es solo lectura.",
            Code = "READ_ONLY",
            TotalCount = 0
        };
    }

    public class EstadoContratoAppService(
        GenericService<Contrato1, EstadoContratoDto, EstadoContratoResponse> service,
        GenericService<VwContrato2, EstadoContratoDto, EstadoContratoResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Contrato1, VwContrato2, EstadoContratoDto, EstadoContratoResponse>(
            service,
            serviceView,
            context,
            "PkidContrato",
            "Estado de contrato",
            (dto, id) => dto.PkidContrato = id,
            "PRES.SP_MantenimientoContrato",
            response => response.PkidContrato,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;

        public override async Task<PagedResult<EstadoContratoResponse>> UpdateAsync(int id, EstadoContratoResponse response, int usuarioActual)
        {
            var current = await _context.Contratos1
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidContrato == id && x.Activo);

            if (current == null)
            {
                return Failure<EstadoContratoResponse>($"Estado de contrato con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (current.Estatus > 1)
            {
                return Failure<EstadoContratoResponse>("El contrato ya fue autorizado. No se puede modificar el estado.", "LOCKED");
            }

            response.Estatus = Math.Max(1, response.Estatus);
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override Task<PagedResult<EstadoContratoResponse>> CreateAsync(EstadoContratoResponse response, int usuarioActual) =>
            Task.FromResult(Failure<EstadoContratoResponse>("El estado de contrato no permite altas desde esta pantalla.", "READ_ONLY"));

        public override Task<PagedResult<bool>> DeleteAsync(int id) =>
            Task.FromResult(Failure<bool>("El estado de contrato no permite eliminaciones desde esta pantalla.", "READ_ONLY"));

        private static SqlParameter[] BuildParameters(int action, int? id, EstadoContratoResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdContrato", id ?? response?.PkidContrato),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdAutorizacionSuficiencia_PRES", response?.FkidAutorizacionSuficienciaPres),
                StoredProcedureExecutor.Param("@FKIdProveedor_SIS", response?.FkidProveedorSis),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@NumeroContrato", response?.NumeroContrato),
                StoredProcedureExecutor.Param("@Descripcion", response?.Descripcion),
                StoredProcedureExecutor.Param("@FechaContrato", ToDateTime(response?.FechaContrato)),
                StoredProcedureExecutor.Param("@FechaInicioVigencia", ToDateTime(response?.FechaInicioVigencia)),
                StoredProcedureExecutor.Param("@FechaFinVigencia", ToDateTime(response?.FechaFinVigencia)),
                StoredProcedureExecutor.Param("@MontoTotal", response?.MontoTotal),
                StoredProcedureExecutor.Param("@PlazoEjecucion", response?.PlazoEjecucion),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }

        private static DateTime? ToDateTime(DateOnly? value) =>
            value?.ToDateTime(TimeOnly.MinValue);
    }
}

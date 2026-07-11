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

            var tipoContratoExists = await _context.TipoContratos
                .AsNoTracking()
                .AnyAsync(x => x.PkidTipoContrato == response.FkidTipoContratoOrco && x.Activo);

            if (!tipoContratoExists)
            {
                return Failure<OrcoContratoResponse>("El tipo de contrato seleccionado no existe o esta inactivo.");
            }

            var tipoDocumentoExists = await _context.TipoDocumentos
                .AsNoTracking()
                .AnyAsync(x => x.PkidTipoDocumento == response.FkidTipoDocumentoOrco && x.Activo);

            if (!tipoDocumentoExists)
            {
                return Failure<OrcoContratoResponse>("El tipo de documento seleccionado no existe o esta inactivo.");
            }

            if (!response.FkidOrdenCompraOrco.HasValue || response.FkidOrdenCompraOrco.Value <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar una orden de compra autorizada.");
            }

            var ordenCompra = await _context.OrdenCompras
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidOrdenCompra == response.FkidOrdenCompraOrco.Value && x.Activo);

            if (ordenCompra == null)
            {
                return Failure<OrcoContratoResponse>("La orden de compra seleccionada no existe o esta inactiva.");
            }

            if (ordenCompra.FkidEstatusOrdenCompraOrco <= 1)
            {
                return Failure<OrcoContratoResponse>("La orden de compra debe estar autorizada antes de registrar el compromiso.");
            }

            response.FkidEmpresaSis = ordenCompra.FkidEmpresaSis;

            if (!response.FkidAreaSis.HasValue || response.FkidAreaSis.Value <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar un area.");
            }

            var areaExists = await _context.Areas
                .AsNoTracking()
                .AnyAsync(x => x.PkidArea == response.FkidAreaSis.Value && x.Activo);

            if (!areaExists)
            {
                return Failure<OrcoContratoResponse>("El area seleccionada no existe o esta inactiva.");
            }

            if (!response.FkidModalidadOrco.HasValue || response.FkidModalidadOrco.Value <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar una modalidad.");
            }

            var modalidadExists = await _context.Modalidads
                .AsNoTracking()
                .AnyAsync(x => x.PkidModalidad == response.FkidModalidadOrco.Value && x.Activo);

            if (!modalidadExists)
            {
                return Failure<OrcoContratoResponse>("La modalidad seleccionada no existe o esta inactiva.");
            }

            if (!response.FkidProcedimientoContratacionOrco.HasValue || response.FkidProcedimientoContratacionOrco.Value <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar un procedimiento de contratacion.");
            }

            var procedimientoExists = await _context.ProcedimientoContratacions
                .AsNoTracking()
                .AnyAsync(x => x.PkidProcedimientoContratacion == response.FkidProcedimientoContratacionOrco.Value && x.Activo);

            if (!procedimientoExists)
            {
                return Failure<OrcoContratoResponse>("El procedimiento de contratacion seleccionado no existe o esta inactivo.");
            }

            if (!response.FkidTipoGarantiaOrco.HasValue || response.FkidTipoGarantiaOrco.Value <= 0)
            {
                return Failure<OrcoContratoResponse>("Debe seleccionar un tipo de garantia.");
            }

            var garantiaExists = await _context.TipoGarantia
                .AsNoTracking()
                .AnyAsync(x => x.PkidTipoGarantia == response.FkidTipoGarantiaOrco.Value && x.Activo);

            if (!garantiaExists)
            {
                return Failure<OrcoContratoResponse>("El tipo de garantia seleccionado no existe o esta inactivo.");
            }

            if (response.FkidArticuloOrco.HasValue && response.FkidArticuloOrco.Value > 0)
            {
                var articuloExists = await _context.Articulos
                    .AsNoTracking()
                    .AnyAsync(x => x.PkidArticulo == response.FkidArticuloOrco.Value && x.Activo);

                if (!articuloExists)
                {
                    return Failure<OrcoContratoResponse>("El articulo seleccionado no existe o esta inactivo.");
                }
            }

            if (response.FkidFraccionOrco.HasValue && response.FkidFraccionOrco.Value > 0)
            {
                var fraccionExists = await _context.Fraccions
                    .AsNoTracking()
                    .AnyAsync(x => x.PkidFraccion == response.FkidFraccionOrco.Value && x.Activo);

                if (!fraccionExists)
                {
                    return Failure<OrcoContratoResponse>("La fraccion seleccionada no existe o esta inactiva.");
                }
            }

            if (response.FechaContrato == default)
            {
                response.FechaContrato = DateTime.Today;
            }

            var fechaOrden = ordenCompra.FechaOrdenCompra.ToDateTime(TimeOnly.MinValue);
            if (response.FechaContrato.Date < fechaOrden.Date)
            {
                return Failure<OrcoContratoResponse>("La fecha del contrato debe ser igual o mayor a la fecha de la orden de compra.");
            }

            if (response.FechaVigenciaInicio.HasValue &&
                response.FechaVigenciaFin.HasValue &&
                response.FechaVigenciaFin.Value.Date < response.FechaVigenciaInicio.Value.Date)
            {
                return Failure<OrcoContratoResponse>("La fecha final de vigencia no puede ser menor a la fecha inicial.");
            }

            response.FechaRecepcion ??= response.FechaContrato;
            if (response.MontoMaximo <= 0m && ordenCompra.Total > 0m)
            {
                response.MontoMaximo = ordenCompra.Total;
            }

            if (response.MontoMaximo <= 0m)
            {
                return Failure<OrcoContratoResponse>("El monto maximo debe ser mayor a cero.");
            }

            if (response.MontoMinimo <= 0m)
            {
                response.MontoMinimo = response.MontoMaximo;
            }

            if (response.MontoMinimo > response.MontoMaximo)
            {
                return Failure<OrcoContratoResponse>("El monto minimo no puede ser mayor al monto maximo.");
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
        GenericService<VwEgresoDisponible, SaldosContratoResponse, SaldosContratoResponse> service,
        GenericService<VwEgresoDisponible, SaldosContratoResponse, SaldosContratoResponse> serviceView)
        : AdquisicionCrudAppService<VwEgresoDisponible, VwEgresoDisponible, SaldosContratoResponse, SaldosContratoResponse>(
            service,
            serviceView,
            "PkidEgresoAutorizado",
            "Saldos disponibles para contrato",
            (dto, id) => dto.PkidEgresoAutorizado = id)
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
            BuildParameters),
            IEstadoContratoAppService
    {
        private const int EstatusBorrador = 1;
        private const int EstatusVigente = 2;
        private const int EstatusConcluido = 3;
        private const int TipoPolizaLiberacionRemanente = 4;
        private const int TipoDetalleComprometido = 1;
        private const int TipoDetallePorEjercer = 2;

        private readonly EGestionContext _context = context;

        public override async Task<PagedResult<EstadoContratoResponse>> CreateAsync(EstadoContratoResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, currentId: null);
            if (validation != null)
            {
                return validation;
            }

            response.Estatus = EstatusBorrador;

            var created = await base.CreateAsync(response, usuarioActual);
            var contratoId = ResolveResultId(created, response.PkidContrato);
            if (!created.Success || contratoId <= 0)
            {
                return created;
            }

            var detailValidation = await EnsureDetailsFromAutorizacionAsync(contratoId, response.FkidAutorizacionSuficienciaPres, usuarioActual);
            if (detailValidation != null)
            {
                return detailValidation;
            }

            var refreshed = await GetByIdAsync(contratoId);
            refreshed.Message = "Contrato creado con partidas de la autorizacion de suficiencia.";
            return refreshed;
        }

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

            var validation = await NormalizeAndValidateAsync(response, id);
            if (validation != null)
            {
                return validation;
            }

            response.Estatus = current.Estatus;
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.Contratos1
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidContrato == id && x.Activo);

            if (current == null)
            {
                return Failure<bool>($"Estado de contrato con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (current.Estatus > 1)
            {
                return Failure<bool>("El contrato ya fue autorizado. No se puede eliminar.", "LOCKED");
            }

            return await base.DeleteAsync(id);
        }

        public async Task<PagedResult<EstadoContratoResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var current = await _context.Contratos1
                .Include(x => x.ContratoDetalles)
                .FirstOrDefaultAsync(x => x.PkidContrato == id && x.Activo);

            if (current == null)
            {
                return Failure<EstadoContratoResponse>($"Estado de contrato con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (current.Estatus != EstatusBorrador)
            {
                return Failure<EstadoContratoResponse>("Solo se pueden autorizar contratos en borrador.", "LOCKED");
            }

            var activeDetails = current.ContratoDetalles.Where(x => x.Activo).ToList();
            if (activeDetails.Count == 0)
            {
                return Failure<EstadoContratoResponse>("El contrato no tiene partidas generadas desde la autorizacion de suficiencia.");
            }

            var totalDetails = activeDetails.Sum(DetailTotal);
            if (totalDetails <= 0m)
            {
                return Failure<EstadoContratoResponse>("El total de las partidas del contrato debe ser mayor a cero.");
            }

            current.Estatus = EstatusVigente;
            current.FechaModificacion = DateTime.Now;
            current.UsuarioModificacion = usuarioActual;
            await _context.SaveChangesAsync();

            return await RefreshedAsync(id, "Contrato autorizado correctamente. Ya no se puede editar ni eliminar.");
        }

        public async Task<PagedResult<EstadoContratoResponse>> LiberarRemanenteAsync(int id, int usuarioActual)
        {
            var current = await _context.Contratos1
                .Include(x => x.ContratoDetalles)
                .FirstOrDefaultAsync(x => x.PkidContrato == id && x.Activo);

            if (current == null)
            {
                return Failure<EstadoContratoResponse>($"Estado de contrato con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (current.Estatus < EstatusVigente)
            {
                return Failure<EstadoContratoResponse>("Primero autoriza el contrato antes de liberar remanentes.");
            }

            if (current.Estatus >= EstatusConcluido)
            {
                return Failure<EstadoContratoResponse>("El contrato ya esta cerrado.");
            }

            var saldo = await _context.VwEgreCompNoDevs
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidContrato == id);

            if (saldo == null)
            {
                return Failure<EstadoContratoResponse>("No se encontro informacion de remanente para este contrato.");
            }

            var remanente = decimal.Round(saldo.Total.GetValueOrDefault(), 2);
            if (remanente <= 0m)
            {
                current.Estatus = EstatusConcluido;
                current.FechaModificacion = DateTime.Now;
                current.UsuarioModificacion = usuarioActual;
                await _context.SaveChangesAsync();
                return await RefreshedAsync(id, "Contrato cerrado. No habia remanente pendiente por liberar.");
            }

            if (!saldo.FkidAnioSis.HasValue || saldo.FkidAnioSis.Value <= 0)
            {
                return Failure<EstadoContratoResponse>("No se pudo resolver el anio presupuestal del contrato.");
            }

            var positiveDetails = current.ContratoDetalles
                .Where(x => x.Activo && DetailTotal(x) > 0m)
                .ToList();

            if (positiveDetails.Count == 0)
            {
                return Failure<EstadoContratoResponse>("El contrato no tiene partidas positivas para calcular remanente.");
            }

            var releaseDetails = BuildReleaseDetails(current, positiveDetails, remanente, usuarioActual);
            var tipoGastoId = await (
                from authorization in _context.AutorizacionSuficiencia.AsNoTracking()
                join request in _context.SolicitudSuficiencia.AsNoTracking()
                    on authorization.FkidSolicitudSuficienciaPres equals request.PkidSolicitudSuficiencia
                join requisition in _context.Requisicions.AsNoTracking()
                    on request.FkidRequisicionOrco equals requisition.PkidRequisicion
                where authorization.PkidAutorizacionSuficiencia == current.FkidAutorizacionSuficienciaPres
                select requisition.FkidTipoGastoPres).FirstOrDefaultAsync();
            if (!tipoGastoId.HasValue || tipoGastoId.Value <= 0)
            {
                return Failure<EstadoContratoResponse>("No se pudo resolver el Tipo de Gasto del contrato.");
            }

            var matrizValidation = await ValidateMatrizAsync(
                saldo.FkidAnioSis.Value, saldo.FkidProgramaPres, tipoGastoId.Value, releaseDetails);
            if (matrizValidation != null)
            {
                return matrizValidation;
            }

            var strategy = _context.Database.CreateExecutionStrategy();
            try
            {
                return await strategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync();

                    var now = DateTime.Now;
                    var poliza = new Poliza
                    {
                        FkidAnioSis = saldo.FkidAnioSis.Value,
                        FkidMesSis = current.FechaFinVigencia?.Month ?? DateTime.Today.Month,
                        FkidTipoPolizaSis = TipoPolizaLiberacionRemanente,
                        ClavePoliza = await BuildPolizaClaveAsync(id),
                        NombrePoliza = BuildPolizaNombre(current),
                        FechaPoliza = now,
                        EstaBalanceado = true,
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual,
                        PermitirModificar = false,
                        Autorizado = true,
                        FechaSolicitud = now,
                        FechaAutorizacion = now
                    };

                    _context.Polizas.Add(poliza);
                    await _context.SaveChangesAsync();

                    foreach (var detail in releaseDetails)
                    {
                        detail.FechaCreacion = now;
                        detail.UsuarioCreacion = usuarioActual;
                        _context.ContratoDetalles.Add(detail);
                    }

                    var matrices = await GetMatricesAsync(
                        saldo.FkidAnioSis.Value, saldo.FkidProgramaPres, tipoGastoId.Value, releaseDetails);
                    foreach (var group in releaseDetails.GroupBy(x => x.FkidPartidaConta))
                    {
                        var importe = decimal.Round(Math.Abs(group.Sum(DetailTotal)), 2);
                        if (importe <= 0m)
                        {
                            continue;
                        }

                        var matriz = matrices[group.Key];
                        _context.PolizaDetalles.Add(new PolizaDetalle
                        {
                            FkidCuentaContableConta = matriz.FkidCuentaContablePorEjercer,
                            FkidPolizaConta = poliza.PkidPoliza,
                            Descripcion = BuildPolizaDetalleDescripcion(current),
                            ImporteDebe = importe,
                            ImporteHaber = null,
                            FkidReferencia = current.PkidContrato,
                            FkidTipoDetallePolizaSis = await GetTipoDetalleOrNullAsync(TipoDetallePorEjercer),
                            Activo = true,
                            FechaCreacion = now,
                            UsuarioCreacion = usuarioActual
                        });

                        _context.PolizaDetalles.Add(new PolizaDetalle
                        {
                            FkidCuentaContableConta = matriz.FkidCuentaContableComprometido,
                            FkidPolizaConta = poliza.PkidPoliza,
                            Descripcion = BuildPolizaDetalleDescripcion(current),
                            ImporteDebe = null,
                            ImporteHaber = importe,
                            FkidReferencia = current.PkidContrato,
                            FkidTipoDetallePolizaSis = await GetTipoDetalleOrNullAsync(TipoDetalleComprometido),
                            Activo = true,
                            FechaCreacion = now,
                            UsuarioCreacion = usuarioActual
                        });
                    }

                    current.Estatus = EstatusConcluido;
                    current.FkidPolizaConta = poliza.PkidPoliza;
                    current.Observaciones = AppendObservation(current.Observaciones, $"Remanente liberado por {remanente:0.00}.");
                    current.FechaModificacion = now;
                    current.UsuarioModificacion = usuarioActual;

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    return await RefreshedAsync(id, $"Remanente liberado por {remanente:0.00}. Poliza {poliza.ClavePoliza} generada y balanceada.");
                });
            }
            catch (UserVisibleException ex)
            {
                return Failure<EstadoContratoResponse>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("liberar remanente", ex);
                return Failure<EstadoContratoResponse>("No fue posible liberar el remanente del contrato.", "ERROR");
            }
        }

        private async Task<PagedResult<EstadoContratoResponse>?> EnsureDetailsFromAutorizacionAsync(
            int contratoId,
            int autorizacionId,
            int usuarioActual)
        {
            var hasDetails = await _context.ContratoDetalles
                .AnyAsync(x => x.FkidContratoPres == contratoId && x.Activo);

            if (hasDetails)
            {
                return null;
            }

            var contrato = await _context.Contratos1
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidContrato == contratoId && x.Activo);

            if (contrato == null)
            {
                return Failure<EstadoContratoResponse>("No se encontro el contrato recien creado.", "NOT_FOUND");
            }

            var detallesAutorizados = await _context.AutorizacionSuficienciaDetalles
                .AsNoTracking()
                .Where(x => x.FkidAutorizacionSuficienciaPres == autorizacionId && x.Activo)
                .ToListAsync();

            if (detallesAutorizados.Count == 0)
            {
                return Failure<EstadoContratoResponse>("La autorizacion no tiene partidas para generar el contrato.");
            }

            var now = DateTime.Now;
            foreach (var detail in detallesAutorizados)
            {
                _context.ContratoDetalles.Add(new ContratoDetalle
                {
                    FkidEmpresaSis = contrato.FkidEmpresaSis,
                    FkidContratoPres = contratoId,
                    FkidAutorizacionSuficienciaDetallePres = detail.PkidAutorizacionSuficienciaDetalle,
                    FkidPartidaConta = detail.FkidPartidaConta,
                    Enero = detail.Enero,
                    Febrero = detail.Febrero,
                    Marzo = detail.Marzo,
                    Abril = detail.Abril,
                    Mayo = detail.Mayo,
                    Junio = detail.Junio,
                    Julio = detail.Julio,
                    Agosto = detail.Agosto,
                    Septiembre = detail.Septiembre,
                    Octubre = detail.Octubre,
                    Noviembre = detail.Noviembre,
                    Diciembre = detail.Diciembre,
                    Observaciones = string.IsNullOrWhiteSpace(detail.Observaciones)
                        ? "Partida generada desde autorizacion de suficiencia."
                        : detail.Observaciones,
                    Activo = true,
                    FechaCreacion = now,
                    UsuarioCreacion = usuarioActual
                });
            }

            await _context.SaveChangesAsync();
            return null;
        }

        private async Task<PagedResult<EstadoContratoResponse>?> ValidateMatrizAsync(
            int anioId,
            int programaId,
            int tipoGastoId,
            IReadOnlyCollection<ContratoDetalle> releaseDetails)
        {
            var tipoPolizaExists = await _context.TipoPolizas
                .AsNoTracking()
                .AnyAsync(x => x.PkidTipoPoliza == TipoPolizaLiberacionRemanente && x.Activo);

            if (!tipoPolizaExists)
            {
                return Failure<EstadoContratoResponse>("No existe el tipo de poliza para liberacion de remanentes.");
            }

            var matrices = await GetMatricesAsync(anioId, programaId, tipoGastoId, releaseDetails);
            var missing = releaseDetails
                .Select(x => x.FkidPartidaConta)
                .Distinct()
                .Where(partida => !matrices.TryGetValue(partida, out var matriz) ||
                                  matriz.FkidCuentaContablePorEjercer <= 0 ||
                                  matriz.FkidCuentaContableComprometido <= 0)
                .ToList();

            return missing.Count == 0
                ? null
                : Failure<EstadoContratoResponse>(
                    $"Falta matriz de conversion con cuentas Por ejercer/Comprometido para partida(s): {string.Join(", ", missing)}.");
        }

        private async Task<Dictionary<int, MatrizConversion>> GetMatricesAsync(
            int anioId,
            int programaId,
            int tipoGastoId,
            IReadOnlyCollection<ContratoDetalle> details)
        {
            var partidas = details
                .Select(x => x.FkidPartidaConta)
                .Distinct()
                .ToList();

            return await _context.MatrizConversions
                .AsNoTracking()
                .Where(x =>
                    x.Activo &&
                    x.FkidAnioSis == anioId &&
                    x.FkidProgramaPres == programaId &&
                    x.FkidTipoGastoPres == tipoGastoId &&
                    partidas.Contains(x.FkidPartidaSis))
                .ToDictionaryAsync(x => x.FkidPartidaSis);
        }

        private static List<ContratoDetalle> BuildReleaseDetails(
            Contrato1 contrato,
            IReadOnlyCollection<ContratoDetalle> sourceDetails,
            decimal remanente,
            int usuarioActual)
        {
            var totalSource = sourceDetails.Sum(DetailTotal);
            if (totalSource <= 0m)
            {
                return [];
            }

            var ratio = Math.Min(1m, remanente / totalSource);
            var details = sourceDetails
                .Select(source => new ContratoDetalle
                {
                    FkidEmpresaSis = contrato.FkidEmpresaSis,
                    FkidContratoPres = contrato.PkidContrato,
                    FkidAutorizacionSuficienciaDetallePres = source.FkidAutorizacionSuficienciaDetallePres,
                    FkidPartidaConta = source.FkidPartidaConta,
                    Enero = ReleaseAmount(source.Enero, ratio),
                    Febrero = ReleaseAmount(source.Febrero, ratio),
                    Marzo = ReleaseAmount(source.Marzo, ratio),
                    Abril = ReleaseAmount(source.Abril, ratio),
                    Mayo = ReleaseAmount(source.Mayo, ratio),
                    Junio = ReleaseAmount(source.Junio, ratio),
                    Julio = ReleaseAmount(source.Julio, ratio),
                    Agosto = ReleaseAmount(source.Agosto, ratio),
                    Septiembre = ReleaseAmount(source.Septiembre, ratio),
                    Octubre = ReleaseAmount(source.Octubre, ratio),
                    Noviembre = ReleaseAmount(source.Noviembre, ratio),
                    Diciembre = ReleaseAmount(source.Diciembre, ratio),
                    Observaciones = "Liberacion de remanente del contrato.",
                    Activo = true,
                    UsuarioCreacion = usuarioActual
                })
                .Where(x => Math.Abs(DetailTotal(x)) > 0m)
                .ToList();

            if (details.Count == 0)
            {
                return details;
            }

            var targetTotal = -decimal.Round(remanente, 2);
            var currentTotal = decimal.Round(details.Sum(DetailTotal), 2);
            var delta = targetTotal - currentTotal;
            if (delta != 0m)
            {
                ApplyDelta(details, delta);
            }

            return details;
        }

        private static decimal DetailTotal(ContratoDetalle detail) =>
            detail.Enero.GetValueOrDefault() +
            detail.Febrero.GetValueOrDefault() +
            detail.Marzo.GetValueOrDefault() +
            detail.Abril.GetValueOrDefault() +
            detail.Mayo.GetValueOrDefault() +
            detail.Junio.GetValueOrDefault() +
            detail.Julio.GetValueOrDefault() +
            detail.Agosto.GetValueOrDefault() +
            detail.Septiembre.GetValueOrDefault() +
            detail.Octubre.GetValueOrDefault() +
            detail.Noviembre.GetValueOrDefault() +
            detail.Diciembre.GetValueOrDefault();

        private static decimal? ReleaseAmount(decimal? source, decimal ratio)
        {
            var value = source.GetValueOrDefault();
            return value == 0m ? 0m : -decimal.Round(value * ratio, 2);
        }

        private static void ApplyDelta(IReadOnlyList<ContratoDetalle> details, decimal delta)
        {
            var target = details.FirstOrDefault(x => x.Diciembre.GetValueOrDefault() != 0m) ?? details[0];
            target.Diciembre = target.Diciembre.GetValueOrDefault() + delta;
        }

        private async Task<int?> GetTipoDetalleOrNullAsync(int id)
        {
            var exists = await _context.TipoDetallePolizas
                .AsNoTracking()
                .AnyAsync(x => x.PkIdTipoDetallePoliza == id && x.Activo);

            return exists ? id : null;
        }

        private async Task<string> BuildPolizaClaveAsync(int contratoId)
        {
            var baseClave = $"LR{contratoId}";
            if (baseClave.Length > 8)
            {
                baseClave = $"LR{contratoId % 1000000:000000}";
            }

            for (var suffix = 0; suffix < 100; suffix++)
            {
                var suffixText = suffix == 0 ? string.Empty : suffix.ToString();
                var maxBaseLength = Math.Max(1, 10 - suffixText.Length);
                var candidate = baseClave.Length > maxBaseLength
                    ? baseClave[..maxBaseLength] + suffixText
                    : baseClave + suffixText;

                var exists = await _context.Polizas
                    .AsNoTracking()
                    .AnyAsync(x => x.Activo && x.ClavePoliza == candidate);

                if (!exists)
                {
                    return candidate;
                }
            }

            return Guid.NewGuid().ToString("N")[..10].ToUpperInvariant();
        }

        private static string BuildPolizaNombre(Contrato1 contrato)
        {
            var numero = string.IsNullOrWhiteSpace(contrato.NumeroContrato)
                ? contrato.PkidContrato.ToString()
                : contrato.NumeroContrato.Trim();

            return $"Liberacion de remanente del contrato {numero}";
        }

        private static string BuildPolizaDetalleDescripcion(Contrato1 contrato)
        {
            var numero = string.IsNullOrWhiteSpace(contrato.NumeroContrato)
                ? contrato.PkidContrato.ToString()
                : contrato.NumeroContrato.Trim();

            return $"Liberacion de remanente contrato {numero}";
        }

        private static string AppendObservation(string? current, string addition)
        {
            return string.IsNullOrWhiteSpace(current)
                ? addition
                : $"{current.Trim()} | {addition}";
        }

        private async Task<PagedResult<EstadoContratoResponse>> RefreshedAsync(int id, string message)
        {
            var result = await GetByIdAsync(id);
            result.Message = message;
            return result;
        }

        private static int ResolveResultId(PagedResult<EstadoContratoResponse> result, int fallback)
        {
            if (result.Data?.PkidContrato > 0)
            {
                return result.Data.PkidContrato;
            }

            var itemId = result.Items?.FirstOrDefault()?.PkidContrato ?? 0;
            return itemId > 0 ? itemId : fallback;
        }

        private async Task<PagedResult<EstadoContratoResponse>?> NormalizeAndValidateAsync(
            EstadoContratoResponse response,
            int? currentId)
        {
            if (response == null)
            {
                return Failure<EstadoContratoResponse>("El contrato no contiene datos.");
            }

            if (response.FkidAutorizacionSuficienciaPres <= 0)
            {
                return Failure<EstadoContratoResponse>("Debe seleccionar una autorizacion de suficiencia.");
            }

            var autorizacion = await _context.AutorizacionSuficiencia
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.PkidAutorizacionSuficiencia == response.FkidAutorizacionSuficienciaPres &&
                    x.Activo);

            if (autorizacion == null)
            {
                return Failure<EstadoContratoResponse>("La autorizacion de suficiencia no existe o esta inactiva.");
            }

            if (autorizacion.Estatus < 2)
            {
                return Failure<EstadoContratoResponse>("La autorizacion de suficiencia debe estar autorizada antes de generar contrato.");
            }

            var duplicate = await _context.Contratos1
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidAutorizacionSuficienciaPres == response.FkidAutorizacionSuficienciaPres &&
                    x.PkidContrato != (currentId ?? response.PkidContrato));

            if (duplicate)
            {
                return Failure<EstadoContratoResponse>(
                    "Ya existe un contrato activo para esta autorizacion de suficiencia.",
                    "DUPLICATE");
            }

            if (response.FkidProveedorSis <= 0)
            {
                return Failure<EstadoContratoResponse>("Debe seleccionar un proveedor.");
            }

            var proveedorExists = await _context.Proveedors
                .AsNoTracking()
                .AnyAsync(x => x.PkidProveedor == response.FkidProveedorSis && x.Activo);

            if (!proveedorExists)
            {
                return Failure<EstadoContratoResponse>("El proveedor seleccionado no existe o esta inactivo.");
            }

            if (response.FkidPolizaConta.HasValue && response.FkidPolizaConta.Value > 0)
            {
                var polizaExists = await _context.Polizas
                    .AsNoTracking()
                    .AnyAsync(x => x.PkidPoliza == response.FkidPolizaConta.Value && x.Activo);

                if (!polizaExists)
                {
                    return Failure<EstadoContratoResponse>("La poliza seleccionada no existe o esta inactiva.");
                }
            }

            if (string.IsNullOrWhiteSpace(response.NumeroContrato))
            {
                return Failure<EstadoContratoResponse>("El numero de contrato es requerido.");
            }

            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<EstadoContratoResponse>("La descripcion del contrato es requerida.");
            }

            if (response.MontoTotal <= 0m)
            {
                return Failure<EstadoContratoResponse>("El monto total debe ser mayor a cero.");
            }

            if (response.FechaContrato == default)
            {
                response.FechaContrato = DateOnly.FromDateTime(DateTime.Today);
            }

            if (response.FechaInicioVigencia.HasValue &&
                response.FechaFinVigencia.HasValue &&
                response.FechaFinVigencia.Value < response.FechaInicioVigencia.Value)
            {
                return Failure<EstadoContratoResponse>("La fecha fin de vigencia no puede ser anterior al inicio.");
            }

            response.FkidEmpresaSis = autorizacion.FkidEmpresaSis;
            response.NumeroContrato = response.NumeroContrato.Trim();
            response.Descripcion = response.Descripcion.Trim();
            response.PlazoEjecucion ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.Estatus = response.Estatus <= 0 ? 1 : response.Estatus;
            response.Activo = true;

            return null;
        }

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

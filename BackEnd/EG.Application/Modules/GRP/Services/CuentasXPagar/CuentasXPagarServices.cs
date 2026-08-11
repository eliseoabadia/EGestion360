using EG.Application.Services.Adquisicion;
using EG.Application.Interfaces.CuentasXPagar;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.CuentasXPagar;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.CuentasXPagar
{
    public class ContratoAppService(
        GenericService<Contrato1, ContratoDto, ContratoResponse> service,
        GenericService<VwContrato2, ContratoDto, ContratoResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Contrato1, VwContrato2, ContratoDto, ContratoResponse>(
            service,
            serviceView,
            context,
            "PkidContrato",
            "Contrato",
            (dto, id) => dto.PkidContrato = id,
            "PRES.SP_MantenimientoContrato",
            response => response.PkidContrato,
            BuildParameters)
    {
        public override Task<PagedResult<ContratoResponse>> CreateAsync(
            ContratoResponse response,
            int usuarioActual) =>
            Task.FromResult(ReadOnlyContract<ContratoResponse>());

        public override Task<PagedResult<ContratoResponse>> UpdateAsync(
            int id,
            ContratoResponse response,
            int usuarioActual) =>
            Task.FromResult(ReadOnlyContract<ContratoResponse>());

        public override Task<PagedResult<bool>> DeleteAsync(int id) =>
            Task.FromResult(ReadOnlyContract<bool>());

        private static PagedResult<T> ReadOnlyContract<T>() => new()
        {
            Success = false,
            Code = "USE_ESTADO_CONTRATO",
            Message = "Los contratos se administran exclusivamente desde Estado de Contrato para conservar autorizacion, partidas y poliza.",
            TotalCount = 0
        };

        private static SqlParameter[] BuildParameters(int action, int? id, ContratoResponse? response, int? usuarioActual)
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
                StoredProcedureExecutor.Param("@FechaContrato", SpDate.ToDateTime(response?.FechaContrato)),
                StoredProcedureExecutor.Param("@FechaInicioVigencia", SpDate.ToDateTime(response?.FechaInicioVigencia)),
                StoredProcedureExecutor.Param("@FechaFinVigencia", SpDate.ToDateTime(response?.FechaFinVigencia)),
                StoredProcedureExecutor.Param("@MontoTotal", response?.MontoTotal),
                StoredProcedureExecutor.Param("@PlazoEjecucion", response?.PlazoEjecucion),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class ContratoDetalleAppService(
        GenericService<ContratoDetalle, ContratoDetalleDto, ContratoDetalleResponse> service,
        GenericService<VwContratoDetalle, ContratoDetalleDto, ContratoDetalleResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<ContratoDetalle, VwContratoDetalle, ContratoDetalleDto, ContratoDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidContratoDetalle",
            "Detalle de contrato",
            (dto, id) => dto.PkidContratoDetalle = id,
            "PRES.SP_MantenimientoContrato",
            response => response.PkidContratoDetalle,
            BuildParameters)
    {
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

        public override Task<PagedResult<ContratoDetalleResponse>> CreateAsync(
            ContratoDetalleResponse response,
            int usuarioActual) =>
            Task.FromResult(ReadOnlyDetail<ContratoDetalleResponse>());

        public override Task<PagedResult<ContratoDetalleResponse>> UpdateAsync(
            int id,
            ContratoDetalleResponse response,
            int usuarioActual) =>
            Task.FromResult(ReadOnlyDetail<ContratoDetalleResponse>());

        public override Task<PagedResult<bool>> DeleteAsync(int id) =>
            Task.FromResult(ReadOnlyDetail<bool>());

        private static PagedResult<T> ReadOnlyDetail<T>() => new()
        {
            Success = false,
            Code = "CONTRACT_DETAILS_LOCKED",
            Message = "Las partidas del contrato se generan desde la autorizacion de suficiencia y no admiten captura manual.",
            TotalCount = 0
        };

        private static SqlParameter[] BuildParameters(int action, int? id, ContratoDetalleResponse? response, int? usuarioActual)
        {
            return CuentasXPagarSpParameters.Monthly(
                action,
                ("@PKIdContrato", response?.FkidContratoPres),
                ("@PKIdContratoDetalle", id ?? response?.PkidContratoDetalle),
                response?.FkidEmpresaSis,
                response?.FkidPartidaConta,
                response?.Enero,
                response?.Febrero,
                response?.Marzo,
                response?.Abril,
                response?.Mayo,
                response?.Junio,
                response?.Julio,
                response?.Agosto,
                response?.Septiembre,
                response?.Octubre,
                response?.Noviembre,
                response?.Diciembre,
                response?.Observaciones,
                usuarioActual,
                StoredProcedureExecutor.Param("@FKIdAutorizacionSuficienciaDetalle_PRES", response?.FkidAutorizacionSuficienciaDetallePres));
        }
    }

    public class FacturaAppService : StoredProcedureCrudAppService<Factura, VwFactura, FacturaDto, FacturaResponse>
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public FacturaAppService(
            GenericService<Factura, FacturaDto, FacturaResponse> service,
            GenericService<VwFactura, FacturaDto, FacturaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                context,
                "PkidFactura",
                "Factura",
                (dto, id) => dto.PkidFactura = id,
                "PRES.SP_MantenimientoFactura",
                response => response.PkidFactura,
                BuildParameters)
        {
            _context = context;
            _userContext = userContext;
        }

        public override Task<PagedResult<FacturaResponse>> GetAllAsync() =>
            GetAllPaginadoAsync(CuentasXPagarScope.AllRowsRequest("FechaEmision"));

        public override async Task<PagedResult<FacturaResponse>> GetByIdAsync(int id)
        {
            if (!await CurrentIds().AnyAsync(x => x == id))
                return Failure<FacturaResponse>("Factura no encontrada en la empresa y ejercicio activos.", "NOT_FOUND");
            return await base.GetByIdAsync(id);
        }

        public override async Task<PagedResult<FacturaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            CuentasXPagarScope.Restrict(request, "PkidFactura", await CurrentIds().ToArrayAsync());
            return await base.GetAllPaginadoAsync(request);
        }

        private IQueryable<int> CurrentIds()
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var anioId = _userContext.GetCurrentAnioPresupuestalId();
            return from factura in _context.Facturas.AsNoTracking()
                   join contrato in _context.Contratos1.AsNoTracking() on factura.FkidContratoPres equals contrato.PkidContrato
                   join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking() on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                   join solicitud in _context.SolicitudSuficiencia.AsNoTracking() on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                   join requisicion in _context.Requisicions.AsNoTracking() on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                   where factura.Activo && factura.FkidEmpresaSis == empresaId && contrato.Activo && autorizacion.Activo &&
                         solicitud.Activo && requisicion.Activo && requisicion.FkidAnioSis == anioId
                   select factura.PkidFactura;
        }

        public override async Task<PagedResult<FacturaResponse>> CreateAsync(FacturaResponse response, int usuarioActual)
        {
            var contextFailure = ApplyEmpresaContext<FacturaResponse>(response);
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);
            response.Estatus = 3;
            var validation = await ValidateFacturaAsync(response, requireDetails: true);
            if (validation != null)
                return validation;

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var poliza = await CuentasXPagarBudgetPosting.CreateAsync(
                    _context, response.FkidContratoPres, response.FechaEmision,
                    CuentasXPagarBudgetStage.Devengado,
                    response.Detalles.Select(x => (x.FkidPartidaConta, x.MontoAplicado)), usuarioActual);
                response.FkidPolizaConta = poliza.PkidPoliza;
                var result = await base.CreateAsync(response, usuarioActual);
                response.PkidFactura = result.Data?.PkidFactura ?? result.Items?.FirstOrDefault()?.PkidFactura ?? response.PkidFactura;
                if (!result.Success || response.PkidFactura <= 0)
                {
                    await transaction.RollbackAsync();
                    return result;
                }

                foreach (var detalle in response.Detalles)
                {
                    await StoredProcedureExecutor.ExecuteResultAsync(
                        _context,
                        "[PRES].[SP_MantenimientoFactura]",
                        StoredProcedureExecutor.Param("@Action", 5),
                        StoredProcedureExecutor.Param("@PKIdFactura", response.PkidFactura),
                        StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                        StoredProcedureExecutor.Param("@FKIdContratoDetalle_PRES", detalle.FkidContratoDetallePres),
                        StoredProcedureExecutor.Param("@FKIdPartida_CONTA", detalle.FkidPartidaConta),
                        StoredProcedureExecutor.Param("@MontoAplicado", detalle.MontoAplicado),
                        StoredProcedureExecutor.Param("@Observaciones", detalle.Observaciones),
                        StoredProcedureExecutor.Param("@IdUser", usuarioActual));
                }

                await transaction.CommitAsync();
                return await GetByIdAsync(response.PkidFactura);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return Failure<FacturaResponse>($"No fue posible registrar la factura completa: {ex.GetBaseException().Message}", "TRANSACTION_FAILED");
            }
            });
        }

        public override async Task<PagedResult<FacturaResponse>> UpdateAsync(int id, FacturaResponse response, int usuarioActual)
        {
            var contextFailure = ApplyEmpresaContext<FacturaResponse>(response);
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);

            var current = await _context.Facturas.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidFactura == id && x.Activo && x.FkidEmpresaSis == response.FkidEmpresaSis);
            if (current == null)
                return Failure<FacturaResponse>("Factura no encontrada.", "NOT_FOUND");

            if (current.Estatus >= 2)
                return Failure<FacturaResponse>("La factura ya avanzo a autorizacion y no puede modificarse.", "LOCKED");

            response.Estatus = current.Estatus;
            var validation = await ValidateFacturaAsync(response, requireDetails: false);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<bool>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            var current = await _context.Facturas.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidFactura == id && x.Activo && x.FkidEmpresaSis == empresaId.Value);
            if (current == null)
                return Failure<bool>("Factura no encontrada.", "NOT_FOUND");

            if (current.Estatus >= 2)
                return Failure<bool>("La factura ya avanzo a autorizacion y no puede eliminarse.", "LOCKED");

            return await base.DeleteAsync(id);
        }

        private PagedResult<T>? ApplyEmpresaContext<T>(FacturaResponse response)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<T>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            response.FkidEmpresaSis = empresaId.Value;
            return null;
        }

        private static void Normalize(FacturaResponse response)
        {
            response.NumFactura = response.NumFactura?.Trim() ?? string.Empty;
            response.SerieFactura = response.SerieFactura?.Trim();
            response.Uuid = response.Uuid?.Trim();
            response.FlDocto = response.FlDocto?.Trim();
            response.Observaciones = response.Observaciones?.Trim();
            response.Total = response.Total > 0
                ? response.Total
                : (response.Subtotal ?? 0m) + (response.Iva ?? 0m) - (response.Retencion ?? 0m);
        }

        private async Task<PagedResult<FacturaResponse>?> ValidateFacturaAsync(FacturaResponse response, bool requireDetails)
        {
            if (response.FkidContratoPres <= 0 || response.Total <= 0)
                return Failure<FacturaResponse>("Debe seleccionar un contrato autorizado y capturar un total mayor a cero.", "VALIDATION");

            var flow = await (
                from contrato in _context.Contratos1.AsNoTracking()
                join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking()
                    on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                join solicitud in _context.SolicitudSuficiencia.AsNoTracking()
                    on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                join requisicion in _context.Requisicions.AsNoTracking()
                    on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                where contrato.PkidContrato == response.FkidContratoPres && contrato.Activo && contrato.Estatus == 2 &&
                      contrato.FkidEmpresaSis == response.FkidEmpresaSis && autorizacion.Activo && autorizacion.Estatus == 2 &&
                      solicitud.Activo && solicitud.Estatus == 3 && requisicion.Activo
                select new { requisicion.FkidAnioSis, contrato.FechaContrato, contrato.MontoTotal })
                .FirstOrDefaultAsync();
            if (flow == null)
                return Failure<FacturaResponse>("El contrato no existe, no esta autorizado o no pertenece a la empresa activa.", "INVALID_CONTRACT");
            if (flow.FkidAnioSis != _userContext.GetCurrentAnioPresupuestalId())
                return Failure<FacturaResponse>("El contrato no pertenece al ejercicio presupuestal activo.", "YEAR_MISMATCH");

            var anio = await _context.Anios.AsNoTracking()
                .Where(x => x.PkidAnio == flow.FkidAnioSis && x.Activo)
                .Select(x => x.Clave)
                .FirstOrDefaultAsync();
            if (response.FechaEmision.Year != anio || response.FechaEmision < flow.FechaContrato)
                return Failure<FacturaResponse>("La fecha de factura debe pertenecer al ejercicio y ser igual o posterior al contrato.", "INVALID_DATE");

            if (!string.IsNullOrWhiteSpace(response.Uuid) && await _context.Facturas.AsNoTracking().AnyAsync(x =>
                    x.Activo && x.Uuid == response.Uuid && x.PkidFactura != response.PkidFactura))
                return Failure<FacturaResponse>("El UUID de la factura ya se encuentra registrado.", "DUPLICATE");

            if (!requireDetails)
                return null;
            var detalles = response.Detalles.Where(x => x.MontoAplicado > 0).ToList();
            if (detalles.Count == 0 || Math.Abs(detalles.Sum(x => x.MontoAplicado) - response.Total) > 0.01m)
                return Failure<FacturaResponse>("Los detalles de la factura deben existir y sumar exactamente el total.", "DETAIL_TOTAL_MISMATCH");
            var ids = detalles.Select(x => x.FkidContratoDetallePres).Distinct().ToList();
            var validos = await _context.ContratoDetalles.AsNoTracking()
                .CountAsync(x => ids.Contains(x.PkidContratoDetalle) && x.FkidContratoPres == response.FkidContratoPres && x.Activo);
            if (validos != ids.Count)
                return Failure<FacturaResponse>("Uno o mas detalles no pertenecen al contrato seleccionado.", "INVALID_DETAIL");
            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, FacturaResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdFactura", id ?? response?.PkidFactura),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdContrato_PRES", response?.FkidContratoPres),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@NumFactura", response?.NumFactura),
                StoredProcedureExecutor.Param("@SerieFactura", response?.SerieFactura),
                StoredProcedureExecutor.Param("@FechaEmision", SpDate.ToDateTime(response?.FechaEmision)),
                StoredProcedureExecutor.Param("@FechaRecepcion", SpDate.ToDateTime(response?.FechaRecepcion)),
                StoredProcedureExecutor.Param("@Subtotal", response?.Subtotal),
                StoredProcedureExecutor.Param("@IVA", response?.Iva),
                StoredProcedureExecutor.Param("@Retencion", response?.Retencion),
                StoredProcedureExecutor.Param("@Total", response?.Total),
                StoredProcedureExecutor.Param("@UUID", response?.Uuid),
                StoredProcedureExecutor.Param("@FL_Docto", response?.FlDocto),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class FacturaDetalleAppService(
        GenericService<FacturaDetalle, FacturaDetalleDto, FacturaDetalleResponse> service,
        GenericService<VwFacturaDetalle, FacturaDetalleDto, FacturaDetalleResponse> serviceView,
        EGestionContext context,
        IUserContextService userContext)
        : StoredProcedureCrudAppService<FacturaDetalle, VwFacturaDetalle, FacturaDetalleDto, FacturaDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidFacturaDetalle",
            "Detalle de factura",
            (dto, id) => dto.PkidFacturaDetalle = id,
            "PRES.SP_MantenimientoFactura",
            response => response.PkidFacturaDetalle,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;
        private readonly IUserContextService _userContext = userContext;
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

        public override async Task<PagedResult<FacturaDetalleResponse>> CreateAsync(FacturaDetalleResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, null);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<FacturaDetalleResponse>> UpdateAsync(int id, FacturaDetalleResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            var editable = await _context.FacturaDetalles.AsNoTracking().AnyAsync(x =>
                x.PkidFacturaDetalle == id && x.Activo && x.FkidEmpresaSis == company &&
                x.FkidFacturaPresNavigation.Activo && x.FkidFacturaPresNavigation.Estatus < 2 &&
                x.FkidFacturaPresNavigation.FkidEmpresaSis == company);
            return editable ? await base.DeleteAsync(id) : Failure<bool>("El detalle no existe o la factura ya no es editable.", "LOCKED");
        }

        private async Task<PagedResult<FacturaDetalleResponse>?> ValidateAsync(FacturaDetalleResponse response, int? id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            response.FkidEmpresaSis = company;
            if (response.MontoAplicado <= 0)
                return Failure<FacturaDetalleResponse>("El monto aplicado debe ser mayor a cero.", "VALIDATION");
            var factura = await _context.Facturas.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidFactura == response.FkidFacturaPres && x.Activo && x.Estatus < 2 && x.FkidEmpresaSis == company);
            if (factura == null)
                return Failure<FacturaDetalleResponse>("La factura no existe o ya no es editable.", "LOCKED");
            var detail = await _context.ContratoDetalles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidContratoDetalle == response.FkidContratoDetallePres && x.FkidContratoPres == factura.FkidContratoPres && x.Activo);
            if (detail == null || detail.FkidPartidaConta != response.FkidPartidaConta)
                return Failure<FacturaDetalleResponse>("El detalle y la partida no corresponden al contrato de la factura.", "INVALID_DETAIL");
            if (id.HasValue && !await _context.FacturaDetalles.AsNoTracking().AnyAsync(x => x.PkidFacturaDetalle == id.Value && x.FkidFacturaPres == factura.PkidFactura && x.Activo))
                return Failure<FacturaDetalleResponse>("El detalle no pertenece a la factura.", "NOT_FOUND");
            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, FacturaDetalleResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdFactura", response?.FkidFacturaPres),
                StoredProcedureExecutor.Param("@PKIdFacturaDetalle", id ?? response?.PkidFacturaDetalle),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdContratoDetalle_PRES", response?.FkidContratoDetallePres),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response?.FkidPartidaConta),
                StoredProcedureExecutor.Param("@MontoAplicado", response?.MontoAplicado),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class CLCAppService : StoredProcedureCrudAppService<Clc, VwClc, CLCDto, CLCResponse>
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public CLCAppService(
            GenericService<Clc, CLCDto, CLCResponse> service,
            GenericService<VwClc, CLCDto, CLCResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                context,
                "PkidClc",
                "CLC",
                (dto, id) => dto.PkidClc = id,
                "PRES.SP_MantenimientoCLC",
                response => response.PkidClc,
                BuildParameters)
        {
            _context = context;
            _userContext = userContext;
        }

        public override Task<PagedResult<CLCResponse>> GetAllAsync() =>
            GetAllPaginadoAsync(CuentasXPagarScope.AllRowsRequest("FechaSolicitud"));

        public override async Task<PagedResult<CLCResponse>> GetByIdAsync(int id)
        {
            if (!await CurrentIds().AnyAsync(x => x == id))
                return Failure<CLCResponse>("CLC no encontrada en la empresa y ejercicio activos.", "NOT_FOUND");
            return await base.GetByIdAsync(id);
        }

        public override async Task<PagedResult<CLCResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            CuentasXPagarScope.Restrict(request, "PkidClc", await CurrentIds().ToArrayAsync());
            return await base.GetAllPaginadoAsync(request);
        }

        private IQueryable<int> CurrentIds()
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var anioId = _userContext.GetCurrentAnioPresupuestalId();
            return from clc in _context.Clcs.AsNoTracking()
                   join contrato in _context.Contratos1.AsNoTracking() on clc.FkidContratoPres equals contrato.PkidContrato
                   join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking() on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                   join solicitud in _context.SolicitudSuficiencia.AsNoTracking() on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                   join requisicion in _context.Requisicions.AsNoTracking() on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                   where clc.Activo && clc.FkidEmpresaSis == empresaId && contrato.Activo && autorizacion.Activo &&
                         solicitud.Activo && requisicion.Activo && requisicion.FkidAnioSis == anioId
                   select clc.PkidClc;
        }

        public override async Task<PagedResult<CLCResponse>> CreateAsync(CLCResponse response, int usuarioActual)
        {
            var contextFailure = ApplyEmpresaContext<CLCResponse>(response);
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);
            response.Estatus = 3;
            response.FechaAutorizacion ??= response.FechaSolicitud;
            var validation = await ValidateClcAsync(response, requireChildren: true);
            if (validation != null)
                return validation;

            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var poliza = await CuentasXPagarBudgetPosting.CreateAsync(
                    _context, response.FkidContratoPres, response.FechaSolicitud,
                    CuentasXPagarBudgetStage.Ejercido,
                    response.Detalles.Select(x => (x.FkidPartidaConta, MonthlyTotal(x))), usuarioActual);
                response.FkidPolizaConta = poliza.PkidPoliza;
                var result = await base.CreateAsync(response, usuarioActual);
                if (!result.Success || response.PkidClc <= 0)
                {
                    await transaction.RollbackAsync();
                    return result;
                }

                foreach (var detalle in response.Detalles)
                {
                    await StoredProcedureExecutor.ExecuteResultAsync(
                        _context, "[PRES].[SP_MantenimientoCLC]",
                        CuentasXPagarSpParameters.Monthly(
                            5, ("@PKIdCLC", response.PkidClc), ("@PKIdCLCDetalle", null), response.FkidEmpresaSis,
                            detalle.FkidPartidaConta, detalle.Enero, detalle.Febrero, detalle.Marzo, detalle.Abril,
                            detalle.Mayo, detalle.Junio, detalle.Julio, detalle.Agosto, detalle.Septiembre,
                            detalle.Octubre, detalle.Noviembre, detalle.Diciembre, detalle.Observaciones, usuarioActual,
                            StoredProcedureExecutor.Param("@FKIdContratoDetalle_PRES", detalle.FkidContratoDetallePres)));
                }

                foreach (var factura in response.Facturas)
                {
                    await StoredProcedureExecutor.ExecuteResultAsync(
                        _context, "[PRES].[SP_MantenimientoCLC]",
                        StoredProcedureExecutor.Param("@Action", 9),
                        StoredProcedureExecutor.Param("@PKIdCLC", response.PkidClc),
                        StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                        StoredProcedureExecutor.Param("@FKIdFactura_PRES", factura.FkidFacturaPres),
                        StoredProcedureExecutor.Param("@FKIdFacturaDetalle_PRES", factura.FkidFacturaDetallePres),
                        StoredProcedureExecutor.Param("@MontoAplicado", factura.MontoAplicado),
                        StoredProcedureExecutor.Param("@Observaciones", factura.Observaciones),
                        StoredProcedureExecutor.Param("@IdUser", usuarioActual));
                }

                var facturaIds = response.Facturas.Select(x => x.FkidFacturaPres).Distinct().ToList();
                var facturasAplicadas = await _context.Facturas
                    .Where(x => facturaIds.Contains(x.PkidFactura) && x.FkidEmpresaSis == response.FkidEmpresaSis && x.Activo)
                    .ToListAsync();
                foreach (var factura in facturasAplicadas)
                {
                    factura.Estatus = Math.Max(factura.Estatus, 3);
                    factura.FechaModificacion = DateTime.Now;
                    factura.UsuarioModificacion = usuarioActual;
                }
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();
                return await GetByIdAsync(response.PkidClc);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return Failure<CLCResponse>($"No fue posible registrar la CLC completa: {ex.GetBaseException().Message}", "TRANSACTION_FAILED");
            }
        }

        public override async Task<PagedResult<CLCResponse>> UpdateAsync(int id, CLCResponse response, int usuarioActual)
        {
            var contextFailure = ApplyEmpresaContext<CLCResponse>(response);
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);

            var current = await _context.Clcs.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidClc == id && x.Activo && x.FkidEmpresaSis == response.FkidEmpresaSis);
            if (current == null)
                return Failure<CLCResponse>("CLC no encontrada.", "NOT_FOUND");

            if (current.Estatus >= 3)
                return Failure<CLCResponse>("La CLC ya genero provision de pago y no puede modificarse.", "LOCKED");

            response.Estatus = current.Estatus;
            var validation = await ValidateClcAsync(response, requireChildren: false);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<bool>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            var current = await _context.Clcs.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidClc == id && x.Activo && x.FkidEmpresaSis == empresaId.Value);
            if (current == null)
                return Failure<bool>("CLC no encontrada.", "NOT_FOUND");

            if (current.Estatus >= 3)
                return Failure<bool>("La CLC ya genero provision de pago y no puede eliminarse.", "LOCKED");

            return await base.DeleteAsync(id);
        }

        private PagedResult<T>? ApplyEmpresaContext<T>(CLCResponse response)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<T>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            response.FkidEmpresaSis = empresaId.Value;
            return null;
        }

        private static void Normalize(CLCResponse response)
        {
            response.NumClc = response.NumClc?.Trim() ?? string.Empty;
            response.Observaciones = response.Observaciones?.Trim();
        }

        private async Task<PagedResult<CLCResponse>?> ValidateClcAsync(CLCResponse response, bool requireChildren)
        {
            if (response.FkidContratoPres <= 0 || response.ImporteTotal <= 0)
                return Failure<CLCResponse>("Debe seleccionar un contrato y capturar un importe mayor a cero.", "VALIDATION");

            var flow = await (
                from contrato in _context.Contratos1.AsNoTracking()
                join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking()
                    on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                join solicitud in _context.SolicitudSuficiencia.AsNoTracking()
                    on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                join requisicion in _context.Requisicions.AsNoTracking()
                    on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                where contrato.PkidContrato == response.FkidContratoPres && contrato.Activo && contrato.Estatus == 2 &&
                      contrato.FkidEmpresaSis == response.FkidEmpresaSis && autorizacion.Activo && autorizacion.Estatus == 2 &&
                      solicitud.Activo && solicitud.Estatus == 3 && requisicion.Activo
                select new { requisicion.FkidAnioSis, contrato.MontoTotal, contrato.FechaContrato })
                .FirstOrDefaultAsync();
            if (flow == null)
                return Failure<CLCResponse>("El contrato no esta autorizado o no pertenece a la empresa activa.", "INVALID_CONTRACT");
            if (flow.FkidAnioSis != _userContext.GetCurrentAnioPresupuestalId())
                return Failure<CLCResponse>("El contrato no pertenece al ejercicio presupuestal activo.", "YEAR_MISMATCH");
            var anio = await _context.Anios.AsNoTracking().Where(x => x.PkidAnio == flow.FkidAnioSis && x.Activo).Select(x => x.Clave).FirstOrDefaultAsync();
            if (response.FechaSolicitud.Year != anio || response.FechaSolicitud < flow.FechaContrato)
                return Failure<CLCResponse>("La fecha de CLC debe pertenecer al ejercicio y ser igual o posterior al contrato.", "INVALID_DATE");

            if (!requireChildren)
                return null;
            var detalles = response.Detalles.Where(x => MonthlyTotal(x) > 0).ToList();
            var facturas = response.Facturas.Where(x => x.MontoAplicado > 0).ToList();
            if (detalles.Count == 0 || facturas.Count == 0 ||
                Math.Abs(detalles.Sum(MonthlyTotal) - response.ImporteTotal) > 0.01m ||
                Math.Abs(facturas.Sum(x => x.MontoAplicado) - response.ImporteTotal) > 0.01m)
                return Failure<CLCResponse>("La CLC requiere detalles y facturas que sumen exactamente el importe total.", "DETAIL_TOTAL_MISMATCH");

            var detalleContratoIds = detalles.Select(x => x.FkidContratoDetallePres).Distinct().ToList();
            if (await _context.ContratoDetalles.AsNoTracking().CountAsync(x => detalleContratoIds.Contains(x.PkidContratoDetalle) && x.FkidContratoPres == response.FkidContratoPres && x.Activo) != detalleContratoIds.Count)
                return Failure<CLCResponse>("Uno o mas detalles no pertenecen al contrato.", "INVALID_DETAIL");
            var facturaIds = facturas.Select(x => x.FkidFacturaPres).Distinct().ToList();
            if (await _context.Facturas.AsNoTracking().CountAsync(x => facturaIds.Contains(x.PkidFactura) && x.FkidContratoPres == response.FkidContratoPres && x.FkidEmpresaSis == response.FkidEmpresaSis && x.Activo && x.Estatus == 3) != facturaIds.Count)
                return Failure<CLCResponse>("Una o mas facturas no pertenecen al contrato.", "INVALID_INVOICE");
            var facturaDetalleIds = facturas.Select(x => x.FkidFacturaDetallePres).Distinct().ToList();
            if (facturaDetalleIds.Count != facturas.Count ||
                await _context.FacturaDetalles.AsNoTracking().CountAsync(x => facturaDetalleIds.Contains(x.PkidFacturaDetalle) && facturaIds.Contains(x.FkidFacturaPres) && x.Activo) != facturaDetalleIds.Count)
                return Failure<CLCResponse>("Una o mas partidas no pertenecen a las facturas seleccionadas.", "INVALID_INVOICE_DETAIL");
            if (await _context.Clcfacturas.AsNoTracking().AnyAsync(x => x.Activo && facturaDetalleIds.Contains(x.FkidFacturaDetallePres)))
                return Failure<CLCResponse>("Una o mas partidas de factura ya se encuentran aplicadas en otra CLC activa.", "INVOICE_ALREADY_APPLIED");
            return null;
        }

        private static decimal MonthlyTotal(CLCDetalleResponse item) =>
            item.Total ?? item.Enero.GetValueOrDefault() + item.Febrero.GetValueOrDefault() +
            item.Marzo.GetValueOrDefault() + item.Abril.GetValueOrDefault() + item.Mayo.GetValueOrDefault() +
            item.Junio.GetValueOrDefault() + item.Julio.GetValueOrDefault() + item.Agosto.GetValueOrDefault() +
            item.Septiembre.GetValueOrDefault() + item.Octubre.GetValueOrDefault() +
            item.Noviembre.GetValueOrDefault() + item.Diciembre.GetValueOrDefault();

        private static SqlParameter[] BuildParameters(int action, int? id, CLCResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdCLC", id ?? response?.PkidClc),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdContrato_PRES", response?.FkidContratoPres),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@NumCLC", response?.NumClc),
                StoredProcedureExecutor.Param("@FechaSolicitud", SpDate.ToDateTime(response?.FechaSolicitud)),
                StoredProcedureExecutor.Param("@FechaAutorizacion", SpDate.ToDateTime(response?.FechaAutorizacion)),
                StoredProcedureExecutor.Param("@ImporteTotal", response?.ImporteTotal),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class CLCDetalleAppService(
        GenericService<Clcdetalle, CLCDetalleDto, CLCDetalleResponse> service,
        GenericService<VwClcdetalle, CLCDetalleDto, CLCDetalleResponse> serviceView,
        EGestionContext context,
        IUserContextService userContext)
        : StoredProcedureCrudAppService<Clcdetalle, VwClcdetalle, CLCDetalleDto, CLCDetalleResponse>(
            service,
            serviceView,
            context,
            "PkidClcdetalle",
            "Detalle de CLC",
            (dto, id) => dto.PkidClcdetalle = id,
            "PRES.SP_MantenimientoCLC",
            response => response.PkidClcdetalle,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;
        private readonly IUserContextService _userContext = userContext;
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

        public override async Task<PagedResult<CLCDetalleResponse>> CreateAsync(CLCDetalleResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, null);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<CLCDetalleResponse>> UpdateAsync(int id, CLCDetalleResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            var editable = await _context.Clcdetalles.AsNoTracking().AnyAsync(x =>
                x.PkidClcdetalle == id && x.Activo && x.FkidEmpresaSis == company &&
                x.FkidClcPresNavigation.Activo && x.FkidClcPresNavigation.Estatus < 3 &&
                x.FkidClcPresNavigation.FkidEmpresaSis == company);
            return editable ? await base.DeleteAsync(id) : Failure<bool>("El detalle no existe o la CLC ya no es editable.", "LOCKED");
        }

        private async Task<PagedResult<CLCDetalleResponse>?> ValidateAsync(CLCDetalleResponse response, int? id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            response.FkidEmpresaSis = company;
            var total = response.Total ?? response.Enero.GetValueOrDefault() + response.Febrero.GetValueOrDefault() +
                response.Marzo.GetValueOrDefault() + response.Abril.GetValueOrDefault() + response.Mayo.GetValueOrDefault() +
                response.Junio.GetValueOrDefault() + response.Julio.GetValueOrDefault() + response.Agosto.GetValueOrDefault() +
                response.Septiembre.GetValueOrDefault() + response.Octubre.GetValueOrDefault() +
                response.Noviembre.GetValueOrDefault() + response.Diciembre.GetValueOrDefault();
            if (total <= 0)
                return Failure<CLCDetalleResponse>("El importe del detalle debe ser mayor a cero.", "VALIDATION");
            var clc = await _context.Clcs.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidClc == response.FkidClcPres && x.Activo && x.Estatus < 3 && x.FkidEmpresaSis == company);
            if (clc == null)
                return Failure<CLCDetalleResponse>("La CLC no existe o ya no es editable.", "LOCKED");
            var detail = await _context.ContratoDetalles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidContratoDetalle == response.FkidContratoDetallePres && x.FkidContratoPres == clc.FkidContratoPres && x.Activo);
            if (detail == null || detail.FkidPartidaConta != response.FkidPartidaConta)
                return Failure<CLCDetalleResponse>("El detalle y la partida no corresponden al contrato de la CLC.", "INVALID_DETAIL");
            if (id.HasValue && !await _context.Clcdetalles.AsNoTracking().AnyAsync(x => x.PkidClcdetalle == id.Value && x.FkidClcPres == clc.PkidClc && x.Activo))
                return Failure<CLCDetalleResponse>("El detalle no pertenece a la CLC.", "NOT_FOUND");
            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, CLCDetalleResponse? response, int? usuarioActual)
        {
            return CuentasXPagarSpParameters.Monthly(
                action,
                ("@PKIdCLC", response?.FkidClcPres),
                ("@PKIdCLCDetalle", id ?? response?.PkidClcdetalle),
                response?.FkidEmpresaSis,
                response?.FkidPartidaConta,
                response?.Enero,
                response?.Febrero,
                response?.Marzo,
                response?.Abril,
                response?.Mayo,
                response?.Junio,
                response?.Julio,
                response?.Agosto,
                response?.Septiembre,
                response?.Octubre,
                response?.Noviembre,
                response?.Diciembre,
                response?.Observaciones,
                usuarioActual,
                StoredProcedureExecutor.Param("@FKIdContratoDetalle_PRES", response?.FkidContratoDetallePres));
        }
    }

    public class CLCFacturaAppService(
        GenericService<Clcfactura, CLCFacturaDto, CLCFacturaResponse> service,
        GenericService<VwClcfactura, CLCFacturaDto, CLCFacturaResponse> serviceView,
        EGestionContext context,
        IUserContextService userContext)
        : StoredProcedureCrudAppService<Clcfactura, VwClcfactura, CLCFacturaDto, CLCFacturaResponse>(
            service,
            serviceView,
            context,
            "PkidClcfactura",
            "Factura de CLC",
            (dto, id) => dto.PkidClcfactura = id,
            "PRES.SP_MantenimientoCLC",
            response => response.PkidClcfactura,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;
        private readonly IUserContextService _userContext = userContext;
        protected override int CreateAction => 9;
        protected override int UpdateAction => 10;
        protected override int DeleteAction => 11;

        public override async Task<PagedResult<CLCFacturaResponse>> CreateAsync(CLCFacturaResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, null);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<CLCFacturaResponse>> UpdateAsync(int id, CLCFacturaResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            var editable = await _context.Clcfacturas.AsNoTracking().AnyAsync(x =>
                x.PkidClcfactura == id && x.Activo && x.FkidEmpresaSis == company &&
                x.FkidClcPresNavigation.Activo && x.FkidClcPresNavigation.Estatus < 3 &&
                x.FkidClcPresNavigation.FkidEmpresaSis == company);
            return editable ? await base.DeleteAsync(id) : Failure<bool>("La relacion no existe o la CLC ya no es editable.", "LOCKED");
        }

        private async Task<PagedResult<CLCFacturaResponse>?> ValidateAsync(CLCFacturaResponse response, int? id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            response.FkidEmpresaSis = company;
            if (response.MontoAplicado <= 0)
                return Failure<CLCFacturaResponse>("El monto aplicado debe ser mayor a cero.", "VALIDATION");
            var clc = await _context.Clcs.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidClc == response.FkidClcPres && x.Activo && x.Estatus < 3 && x.FkidEmpresaSis == company);
            if (clc == null)
                return Failure<CLCFacturaResponse>("La CLC no existe o ya no es editable.", "LOCKED");
            var factura = await _context.Facturas.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidFactura == response.FkidFacturaPres && x.FkidContratoPres == clc.FkidContratoPres &&
                x.FkidEmpresaSis == company && x.Activo);
            if (factura == null || !await _context.FacturaDetalles.AsNoTracking().AnyAsync(x =>
                    x.PkidFacturaDetalle == response.FkidFacturaDetallePres && x.FkidFacturaPres == factura.PkidFactura && x.Activo))
                return Failure<CLCFacturaResponse>("La factura o su detalle no corresponden al contrato de la CLC.", "INVALID_INVOICE");
            if (id.HasValue && !await _context.Clcfacturas.AsNoTracking().AnyAsync(x => x.PkidClcfactura == id.Value && x.FkidClcPres == clc.PkidClc && x.Activo))
                return Failure<CLCFacturaResponse>("La relacion no pertenece a la CLC.", "NOT_FOUND");
            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, CLCFacturaResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdCLC", response?.FkidClcPres),
                StoredProcedureExecutor.Param("@PKIdCLCFactura", id ?? response?.PkidClcfactura),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdFactura_PRES", response?.FkidFacturaPres),
                StoredProcedureExecutor.Param("@FKIdFacturaDetalle_PRES", response?.FkidFacturaDetallePres),
                StoredProcedureExecutor.Param("@MontoAplicado", response?.MontoAplicado),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class ChequeAppService : StoredProcedureCrudAppService<Cheque, VwCheque, ChequeDto, ChequeResponse>, IChequeAppService
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public ChequeAppService(
            GenericService<Cheque, ChequeDto, ChequeResponse> service,
            GenericService<VwCheque, ChequeDto, ChequeResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                context,
                "PkidCheque",
                "Cheque",
                (dto, id) => dto.PkidCheque = id,
                "PRES.SP_MantenimientoCheque",
                response => response.PkidCheque,
                BuildParameters)
        {
            _context = context;
            _userContext = userContext;
        }

        public override Task<PagedResult<ChequeResponse>> GetAllAsync() =>
            GetAllPaginadoAsync(CuentasXPagarScope.AllRowsRequest("FechaEmision"));

        public override async Task<PagedResult<ChequeResponse>> GetByIdAsync(int id)
        {
            if (!await CurrentIds().AnyAsync(x => x == id))
                return Failure<ChequeResponse>("Cheque no encontrado en la empresa y ejercicio activos.", "NOT_FOUND");
            return await base.GetByIdAsync(id);
        }

        public override async Task<PagedResult<ChequeResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            CuentasXPagarScope.Restrict(request, "PkidCheque", await CurrentIds().ToArrayAsync());
            return await base.GetAllPaginadoAsync(request);
        }

        private IQueryable<int> CurrentIds()
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var anioId = _userContext.GetCurrentAnioPresupuestalId();
            return from cheque in _context.Cheques.AsNoTracking()
                   join clc in _context.Clcs.AsNoTracking() on cheque.FkidClcPres equals clc.PkidClc
                   join contrato in _context.Contratos1.AsNoTracking() on clc.FkidContratoPres equals contrato.PkidContrato
                   join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking() on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                   join solicitud in _context.SolicitudSuficiencia.AsNoTracking() on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                   join requisicion in _context.Requisicions.AsNoTracking() on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                   where cheque.Activo && cheque.FkidEmpresaSis == empresaId && clc.Activo && contrato.Activo &&
                         autorizacion.Activo && solicitud.Activo && requisicion.Activo && requisicion.FkidAnioSis == anioId
                   select cheque.PkidCheque;
        }

        public override async Task<PagedResult<ChequeResponse>> CreateAsync(ChequeResponse response, int usuarioActual)
        {
            var validation = await ValidateChequeAsync(response, null);
            if (validation != null)
                return validation;

            response.Estatus = 3;
            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var clcContratoId = await _context.Clcs.AsNoTracking()
                    .Where(x => x.PkidClc == response.FkidClcPres)
                    .Select(x => x.FkidContratoPres)
                    .FirstAsync();
                var poliza = await CuentasXPagarBudgetPosting.CreateAsync(
                    _context, clcContratoId, response.FechaEmision,
                    CuentasXPagarBudgetStage.Pagado,
                    response.Partidas.Select(x => (x.FkidPartidaConta, x.MontoPagado)), usuarioActual);
                response.FkidPolizaConta = poliza.PkidPoliza;
                var result = await base.CreateAsync(response, usuarioActual);
                if (!result.Success || response.PkidCheque <= 0)
                {
                    await transaction.RollbackAsync();
                    return result;
                }

                foreach (var partida in response.Partidas)
                {
                    await StoredProcedureExecutor.ExecuteResultAsync(
                        _context, "[PRES].[SP_MantenimientoCheque]",
                        StoredProcedureExecutor.Param("@Action", 5),
                        StoredProcedureExecutor.Param("@PKIdCheque", response.PkidCheque),
                        StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                        StoredProcedureExecutor.Param("@FKIdCLCDetalle_PRES", partida.FkidClcdetallePres),
                        StoredProcedureExecutor.Param("@FKIdPartida_CONTA", partida.FkidPartidaConta),
                        StoredProcedureExecutor.Param("@MontoPagado", partida.MontoPagado),
                        StoredProcedureExecutor.Param("@Observaciones", partida.Observaciones),
                        StoredProcedureExecutor.Param("@IdUser", usuarioActual));
                }

                var clc = await _context.Clcs.FirstAsync(x => x.PkidClc == response.FkidClcPres && x.Activo && x.FkidEmpresaSis == response.FkidEmpresaSis);
                clc.Estatus = 4;
                clc.FechaAutorizacion ??= response.FechaEmision;
                clc.FechaModificacion = DateTime.Now;
                clc.UsuarioModificacion = usuarioActual;
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();
                return await GetByIdAsync(response.PkidCheque);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return Failure<ChequeResponse>($"No fue posible registrar la provision completa: {ex.GetBaseException().Message}", "TRANSACTION_FAILED");
            }
        }

        public override async Task<PagedResult<ChequeResponse>> UpdateAsync(int id, ChequeResponse response, int usuarioActual)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<ChequeResponse>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            var current = await _context.Cheques.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidCheque == id && x.Activo && x.FkidEmpresaSis == empresaId.Value);
            if (current == null)
                return Failure<ChequeResponse>("Cheque o transferencia no encontrado.", "NOT_FOUND");

            if (current.Estatus >= 2)
                return Failure<ChequeResponse>("La provision de pago ya fue autorizada y no puede modificarse.", "LOCKED");

            var validation = await ValidateChequeAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<bool>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            var current = await _context.Cheques.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidCheque == id && x.Activo && x.FkidEmpresaSis == empresaId.Value);
            if (current == null)
                return Failure<bool>("Cheque o transferencia no encontrado.", "NOT_FOUND");

            if (current.Estatus >= 2)
                return Failure<bool>("La provision de pago ya fue autorizada y no puede eliminarse.", "LOCKED");

            return await base.DeleteAsync(id);
        }

        public async Task<PagedResult<ChequeResponse>> RegresarASolicitudSuficienciaAsync(int id, string motivo)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<ChequeResponse>("No se encontró la empresa activa en la sesión.", "EMPRESA_REQUIRED");

            motivo = motivo?.Trim() ?? string.Empty;
            if (motivo.Length < 10)
                return Failure<ChequeResponse>("Capture un motivo de al menos 10 caracteres para regresar el cheque.", "VALIDATION");

            var cheque = await _context.Cheques.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidCheque == id && x.FkidEmpresaSis == empresaId.Value);

            if (cheque == null)
                return Failure<ChequeResponse>("Cheque o transferencia no encontrado.", "NOT_FOUND");

            if (cheque.Estatus < 2)
                return Failure<ChequeResponse>("El cheque todavía es editable; el regreso completo aplica después de su autorización.", "BUSINESS_RULE");

            try
            {
                var executionStrategy = _context.Database.CreateExecutionStrategy();
                await executionStrategy.ExecuteAsync(async () =>
                {
                    var parameters = new[]
                    {
                        StoredProcedureExecutor.Param("@PKIdCheque", id),
                        StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", empresaId.Value),
                        StoredProcedureExecutor.Param("@Motivo", motivo),
                        StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId())
                    };

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC PRES.SP_RegresarChequeASolicitudSuficiencia @PKIdCheque, @FKIdEmpresa_SIS, @Motivo, @IdUser",
                        parameters);
                });

                return new PagedResult<ChequeResponse>
                {
                    Success = true,
                    Code = "SUCCESS",
                    Message = "Cheque regresado hasta la requisición. Se canceló la cadena posterior, se reabrió el origen y se generaron las pólizas de reversión.",
                    TotalCount = 0
                };
            }
            catch (SqlException ex)
            {
                var message = ex.Message.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault()
                    ?? "No fue posible regresar el cheque hasta la requisición.";
                return Failure<ChequeResponse>(message, "BUSINESS_RULE");
            }
            catch (Exception ex)
            {
                LogException("regresar hasta la requisición", ex);
                return Failure<ChequeResponse>("No fue posible regresar el cheque hasta la requisición.", "ERROR");
            }
        }

        private async Task<PagedResult<ChequeResponse>?> ValidateChequeAsync(ChequeResponse response, int? currentId)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                return Failure<ChequeResponse>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

            if (response.FkidClcPres <= 0)
                return Failure<ChequeResponse>("Debe seleccionar una CLC para generar la provision de pago.", "VALIDATION");

            if (response.FkidCuentaBancariaTes <= 0)
                return Failure<ChequeResponse>("Debe seleccionar una cuenta bancaria para la provision de pago.", "VALIDATION");

            response.FkidEmpresaSis = empresaId.Value;
            response.NumeroCheque = response.NumeroCheque?.Trim() ?? string.Empty;
            response.Concepto = response.Concepto?.Trim() ?? string.Empty;
            response.Observaciones = response.Observaciones?.Trim();

            var clc = await _context.Clcs.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidClc == response.FkidClcPres && x.Activo && x.FkidEmpresaSis == empresaId.Value);
            if (clc == null)
                return Failure<ChequeResponse>("La CLC seleccionada no existe o no esta activa.", "NOT_FOUND");
            if (clc.Estatus != 3)
                return Failure<ChequeResponse>("La CLC debe estar autorizada y pendiente de pago para generar el cheque.", "INVALID_STATUS");

            var anioId = await (
                from contrato in _context.Contratos1.AsNoTracking()
                join autorizacion in _context.AutorizacionSuficiencia.AsNoTracking()
                    on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                join solicitud in _context.SolicitudSuficiencia.AsNoTracking()
                    on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                join requisicion in _context.Requisicions.AsNoTracking()
                    on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                where contrato.PkidContrato == clc.FkidContratoPres && contrato.Activo && contrato.Estatus == 2 &&
                      autorizacion.Activo && autorizacion.Estatus == 2 && solicitud.Activo && solicitud.Estatus == 3 && requisicion.Activo
                select (int?)requisicion.FkidAnioSis).FirstOrDefaultAsync();
            if (anioId != _userContext.GetCurrentAnioPresupuestalId())
                return Failure<ChequeResponse>("La CLC no pertenece al ejercicio presupuestal activo.", "YEAR_MISMATCH");
            var anioClave = await _context.Anios.AsNoTracking().Where(x => x.PkidAnio == anioId && x.Activo).Select(x => x.Clave).FirstOrDefaultAsync();
            if (response.FechaEmision.Year != anioClave || response.FechaEmision < clc.FechaSolicitud)
                return Failure<ChequeResponse>("La fecha de emision debe pertenecer al ejercicio y ser posterior a la CLC.", "INVALID_DATE");

            if (!await _context.CuentaBancaria.AsNoTracking().AnyAsync(x =>
                    x.PkidCuentaBancaria == response.FkidCuentaBancariaTes && x.FkidEmpresaSis == empresaId.Value && x.Activo))
                return Failure<ChequeResponse>("La cuenta bancaria no pertenece a la empresa activa.", "INVALID_BANK_ACCOUNT");

            var clcDetalle = await _context.Clcdetalles.AsNoTracking()
                .Where(x => x.FkidClcPres == clc.PkidClc && x.FkidEmpresaSis == empresaId.Value && x.Activo)
                .Select(x => new { x.PkidClcdetalle, x.FkidPartidaConta, x.Total })
                .ToListAsync();
            var totalFacturas = await _context.Clcfacturas.AsNoTracking()
                .Where(x => x.FkidClcPres == clc.PkidClc && x.FkidEmpresaSis == empresaId.Value && x.Activo)
                .SumAsync(x => (decimal?)x.MontoAplicado) ?? 0m;
            if (clcDetalle.Count == 0 || totalFacturas <= 0 ||
                Math.Abs(clcDetalle.Sum(x => x.Total ?? 0m) - clc.ImporteTotal) > 0.01m ||
                Math.Abs(totalFacturas - clc.ImporteTotal) > 0.01m)
                return Failure<ChequeResponse>("La CLC debe tener detalles y facturas completos antes de generar la provision.", "CLC_NOT_READY");

            var partidas = response.Partidas.Where(x => x.MontoPagado > 0).ToList();
            if (partidas.Count == 0 || Math.Abs(partidas.Sum(x => x.MontoPagado) - response.ImporteTotal) > 0.01m ||
                Math.Abs(response.ImporteTotal - clc.ImporteTotal) > 0.01m)
                return Failure<ChequeResponse>("Las partidas del cheque deben sumar exactamente el total de la CLC.", "DETAIL_TOTAL_MISMATCH");
            var detalleMap = clcDetalle.ToDictionary(x => x.PkidClcdetalle);
            if (partidas.Any(x => !detalleMap.TryGetValue(x.FkidClcdetallePres, out var d) || d.FkidPartidaConta != x.FkidPartidaConta))
                return Failure<ChequeResponse>("Una o mas partidas no corresponden al detalle de la CLC.", "INVALID_DETAIL");

            var alreadyExists = await _context.Cheques.AsNoTracking()
                .AnyAsync(x => x.Activo && x.FkidEmpresaSis == empresaId.Value && x.FkidClcPres == response.FkidClcPres && (!currentId.HasValue || x.PkidCheque != currentId.Value));

            if (alreadyExists)
                return Failure<ChequeResponse>("Ya existe una provision de pago activa para esa CLC.", "DUPLICATE");

            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, ChequeResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdCheque", id ?? response?.PkidCheque),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdCLC_PRES", response?.FkidClcPres),
                StoredProcedureExecutor.Param("@FKIdCuentaBancaria_TES", response?.FkidCuentaBancariaTes),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@FechaEmision", SpDate.ToDateTime(response?.FechaEmision)),
                StoredProcedureExecutor.Param("@NumeroCheque", response?.NumeroCheque),
                StoredProcedureExecutor.Param("@Concepto", response?.Concepto),
                StoredProcedureExecutor.Param("@ImporteTotal", response?.ImporteTotal),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@Estatus", response?.Estatus),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class ChequePartidaAppService(
        GenericService<ChequePartida, ChequePartidaDto, ChequePartidaResponse> service,
        GenericService<VwChequePartida, ChequePartidaDto, ChequePartidaResponse> serviceView,
        EGestionContext context,
        IUserContextService userContext)
        : StoredProcedureCrudAppService<ChequePartida, VwChequePartida, ChequePartidaDto, ChequePartidaResponse>(
            service,
            serviceView,
            context,
            "PkidChequePartida",
            "Partida de cheque",
            (dto, id) => dto.PkidChequePartida = id,
            "PRES.SP_MantenimientoCheque",
            response => response.PkidChequePartida,
            BuildParameters)
    {
        private readonly EGestionContext _context = context;
        private readonly IUserContextService _userContext = userContext;
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

        public override async Task<PagedResult<ChequePartidaResponse>> CreateAsync(ChequePartidaResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, null);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<ChequePartidaResponse>> UpdateAsync(int id, ChequePartidaResponse response, int usuarioActual)
        {
            var validation = await ValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            var editable = await _context.ChequePartidas.AsNoTracking().AnyAsync(x =>
                x.PkidChequePartida == id && x.Activo && x.FkidEmpresaSis == company &&
                x.FkidChequePresNavigation.Activo && x.FkidChequePresNavigation.Estatus < 2 &&
                x.FkidChequePresNavigation.FkidEmpresaSis == company);
            return editable ? await base.DeleteAsync(id) : Failure<bool>("La partida no existe o el cheque ya no es editable.", "LOCKED");
        }

        private async Task<PagedResult<ChequePartidaResponse>?> ValidateAsync(ChequePartidaResponse response, int? id)
        {
            var company = _userContext.GetCurrentEmpresaId();
            response.FkidEmpresaSis = company;
            if (response.MontoPagado <= 0)
                return Failure<ChequePartidaResponse>("El monto pagado debe ser mayor a cero.", "VALIDATION");
            var cheque = await _context.Cheques.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidCheque == response.FkidChequePres && x.Activo && x.Estatus < 2 && x.FkidEmpresaSis == company);
            if (cheque == null)
                return Failure<ChequePartidaResponse>("El cheque no existe o ya no es editable.", "LOCKED");
            var detalle = await _context.Clcdetalles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidClcdetalle == response.FkidClcdetallePres && x.FkidClcPres == cheque.FkidClcPres &&
                x.FkidEmpresaSis == company && x.Activo);
            if (detalle == null || detalle.FkidPartidaConta != response.FkidPartidaConta)
                return Failure<ChequePartidaResponse>("La partida no corresponde al detalle de la CLC.", "INVALID_DETAIL");
            if (id.HasValue && !await _context.ChequePartidas.AsNoTracking().AnyAsync(x => x.PkidChequePartida == id.Value && x.FkidChequePres == cheque.PkidCheque && x.Activo))
                return Failure<ChequePartidaResponse>("La partida no pertenece al cheque.", "NOT_FOUND");
            return null;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, ChequePartidaResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdCheque", response?.FkidChequePres),
                StoredProcedureExecutor.Param("@PKIdChequePartida", id ?? response?.PkidChequePartida),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdCLCDetalle_PRES", response?.FkidClcdetallePres),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response?.FkidPartidaConta),
                StoredProcedureExecutor.Param("@MontoPagado", response?.MontoPagado),
                StoredProcedureExecutor.Param("@Observaciones", response?.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };
        }
    }

    public class DepositoAppService : StoredProcedureCrudAppService<Deposito, VwDeposito, DepositoDto, DepositoResponse>, IDepositoAppService
    {
        private const string StoredProcedure = "PRES.SP_MantenimientoDeposito";
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public DepositoAppService(
            GenericService<Deposito, DepositoDto, DepositoResponse> service,
            GenericService<VwDeposito, DepositoDto, DepositoResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                context,
                "PkidDeposito",
                "Deposito",
                (dto, id) => dto.PkidDeposito = id,
                StoredProcedure,
                response => response.PkidDeposito,
                BuildParameters)
        {
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<DepositoResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            await HydratePolizaStatusAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<DepositoResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success)
                await HydratePolizaStatusAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<DepositoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            if (result.Success)
                await HydratePolizaStatusAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<DepositoResponse>> CreateAsync(DepositoResponse response, int usuarioActual)
        {
            var contextFailure = ValidateEmpresaContext<DepositoResponse>();
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);
            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<DepositoResponse>> UpdateAsync(int id, DepositoResponse response, int usuarioActual)
        {
            var contextFailure = ValidateEmpresaContext<DepositoResponse>();
            if (contextFailure != null)
                return contextFailure;

            var existing = await GetByIdAsync(id);
            if (!existing.Success)
                return Failure<DepositoResponse>(existing.Message, existing.Code ?? "NOT_FOUND");

            if (existing.Data?.EstaAutorizado == true)
                return Failure<DepositoResponse>("El deposito ya tiene la poliza autorizada y no puede modificarse.", "LOCKED");

            Normalize(response);
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var contextFailure = ValidateEmpresaContext<bool>();
            if (contextFailure != null)
                return contextFailure;

            var existing = await GetByIdAsync(id);
            if (!existing.Success)
                return Failure<bool>(existing.Message, existing.Code ?? "NOT_FOUND");

            if (existing.Data?.EstaAutorizado == true)
                return Failure<bool>("El deposito ya tiene la poliza autorizada y no puede eliminarse.", "LOCKED");

            try
            {
                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(3, id, null, _userContext.GetCurrentUserId()));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = [true],
                    TotalCount = 1
                };
            }
            catch (UserVisibleException ex)
            {
                return Failure<bool>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("eliminar", ex);
                return Failure<bool>("No fue posible eliminar el deposito.");
            }
        }

        public async Task<PagedResult<DepositoResponse>> AutorizarAsync(int id)
        {
            var contextFailure = ValidateEmpresaContext<DepositoResponse>();
            if (contextFailure != null)
                return contextFailure;

            var current = await GetByIdAsync(id);
            if (!current.Success || current.Data == null)
                return Failure<DepositoResponse>(current.Message, current.Code ?? "NOT_FOUND");

            if (current.Data.EstaAutorizado)
                return Failure<DepositoResponse>("La poliza del deposito ya fue autorizada.", "LOCKED");

            if (current.Data.FkidPolizaConta <= 0)
                return Failure<DepositoResponse>("El deposito no tiene una poliza asociada.");

            var poliza = await _context.Polizas.FirstOrDefaultAsync(x => x.PkidPoliza == current.Data.FkidPolizaConta && x.Activo);
            if (poliza == null)
                return Failure<DepositoResponse>("No se encontro la poliza del deposito.", "NOT_FOUND");

            if (!poliza.EstaBalanceado)
                return Failure<DepositoResponse>("La poliza debe estar balanceada antes de autorizar.");

            poliza.Autorizado = true;
            poliza.PermitirModificar = false;
            poliza.FechaAutorizacion = DateTime.Now;
            poliza.UsuarioModificacion = _userContext.GetCurrentUserId();
            poliza.FechaModificacion = DateTime.Now;

            await _context.SaveChangesAsync();

            var refreshed = await GetByIdAsync(id);
            refreshed.Message = "Deposito y poliza autorizados correctamente.";
            return refreshed;
        }

        public async Task<PagedResult<DepositoPolizaResponse>> GetPolizaAsync(int id)
        {
            var header = await (
                from deposito in _context.Depositos.AsNoTracking()
                join poliza in _context.Polizas.AsNoTracking() on deposito.FkidPolizaConta equals poliza.PkidPoliza
                where deposito.PkidDeposito == id && deposito.Activo && poliza.Activo
                select new DepositoPolizaResponse
                {
                    PkidDeposito = deposito.PkidDeposito,
                    PkidPoliza = poliza.PkidPoliza,
                    ClavePoliza = poliza.ClavePoliza,
                    NombrePoliza = poliza.NombrePoliza,
                    FechaPoliza = poliza.FechaPoliza,
                    EstaBalanceado = poliza.EstaBalanceado,
                    Autorizado = poliza.Autorizado,
                    PermitirModificar = poliza.PermitirModificar
                }).FirstOrDefaultAsync();

            if (header == null)
                return Failure<DepositoPolizaResponse>("No se encontro la poliza del deposito.", "NOT_FOUND");

            header.Detalles = await (
                from detalle in _context.PolizaDetalles.AsNoTracking()
                join cuenta in _context.CuentaContables.AsNoTracking()
                    on detalle.FkidCuentaContableConta equals cuenta.PkidCuentaContable
                where detalle.FkidPolizaConta == header.PkidPoliza
                   && detalle.FkidReferencia == id
                   && detalle.Activo
                orderby detalle.FkidTipoDetallePolizaSis, detalle.PkidPolizaDetalle
                select new DepositoPolizaDetalleResponse
                {
                    PkidPolizaDetalle = detalle.PkidPolizaDetalle,
                    FkidCuentaContableConta = detalle.FkidCuentaContableConta,
                    Cuenta = cuenta.Cuenta,
                    CuentaDescripcion = cuenta.Descripcion,
                    Descripcion = detalle.Descripcion,
                    ImporteDebe = detalle.ImporteDebe ?? 0m,
                    ImporteHaber = detalle.ImporteHaber ?? 0m,
                    FkidTipoDetallePolizaSis = detalle.FkidTipoDetallePolizaSis
                }).ToListAsync();

            header.TotalDebe = header.Detalles.Sum(x => x.ImporteDebe);
            header.TotalHaber = header.Detalles.Sum(x => x.ImporteHaber);

            return new PagedResult<DepositoPolizaResponse>
            {
                Success = true,
                Message = "Poliza obtenida correctamente.",
                Code = "SUCCESS",
                Data = header,
                Items = [header],
                TotalCount = 1
            };
        }

        public Task<PagedResult<LookupItem>> GetIngresoAutorizadoLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio)
        {
            var query = _context.VwIngresoAutorizados.AsNoTracking().Where(x => x.Activo && x.FechaAutorizacion.HasValue);

            if (idAnio.HasValue && idAnio.Value > 0)
                query = query.Where(x => x.FkidAnioSis == idAnio.Value);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term) ||
                    EF.Functions.Like(x.ProgramaClaveNombre ?? string.Empty, term) ||
                    EF.Functions.Like(x.OrigenClaveNombre ?? string.Empty, term));
            }

            return ToLookupResultAsync(
                query.OrderByDescending(x => x.Fecha).ThenBy(x => x.ProgramaClave),
                page,
                pageSize,
                x => new LookupItem
                {
                    Id = x.PkidIngresoAutorizado,
                    Text = $"{BuildText(x.ProgramaClave, x.Descripcion)} | {x.Total.GetValueOrDefault():0.00}"
                });
        }

        public Task<PagedResult<LookupItem>> GetCLCFacturaLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.Clcfacturas.AsNoTracking().Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter) && int.TryParse(filter.Trim(), out var id))
                query = query.Where(x => x.PkidClcfactura == id || x.FkidClcPres == id || x.FkidFacturaPres == id);

            return ToLookupResultAsync(
                query.OrderByDescending(x => x.Fecha).ThenByDescending(x => x.PkidClcfactura),
                page,
                pageSize,
                x => new LookupItem
                {
                    Id = x.PkidClcfactura,
                    Text = $"CLC factura #{x.PkidClcfactura} | CLC {x.FkidClcPres} | {x.MontoAplicado:0.00}"
                });
        }

        public Task<PagedResult<LookupItem>> GetTipoDoctoPagoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.TipoDoctoPagos.AsNoTracking().Where(x => x.Activo);
            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x => EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Descripcion),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidTipoDoctoPago, Text = x.Descripcion ?? string.Empty });
        }

        public Task<PagedResult<LookupItem>> GetCuentaContableLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            var query = _context.CuentaContables.AsNoTracking().Where(x => x.Activo && x.IsCuentaDetalle == 1);

            if (empresaId.HasValue && empresaId.Value > 0)
                query = query.Where(x => x.FkidEmpresaSis == empresaId.Value);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Cuenta ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Cuenta),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidCuentaContable, Text = BuildText(x.Cuenta, x.Descripcion) });
        }

        private async Task HydratePolizaStatusAsync(IEnumerable<DepositoResponse>? rows)
        {
            var items = rows?.Where(x => x.FkidPolizaConta > 0).ToList() ?? [];
            if (items.Count == 0)
                return;

            var ids = items.Select(x => x.FkidPolizaConta).Distinct().ToList();
            var polizas = await _context.Polizas.AsNoTracking()
                .Where(x => ids.Contains(x.PkidPoliza))
                .Select(x => new
                {
                    x.PkidPoliza,
                    x.Autorizado,
                    x.EstaBalanceado,
                    x.FechaAutorizacion
                })
                .ToDictionaryAsync(x => x.PkidPoliza);

            foreach (var item in items)
            {
                if (!polizas.TryGetValue(item.FkidPolizaConta, out var poliza))
                    continue;

                item.PolizaAutorizada = poliza.Autorizado;
                item.PolizaBalanceada = poliza.EstaBalanceado;
                item.FechaAutorizacionPoliza = poliza.FechaAutorizacion;
            }
        }

        private PagedResult<T>? ValidateEmpresaContext<T>()
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            return empresaId.HasValue && empresaId.Value > 0
                ? null
                : Failure<T>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");
        }

        private static void Normalize(DepositoResponse response)
        {
            response.NumeroReferencia = response.NumeroReferencia?.Trim();
            response.ConceptoCheque = response.ConceptoCheque?.Trim();
            response.NombreAportante = response.NombreAportante?.Trim();
            response.Importe = response.Enero + response.Febrero + response.Marzo + response.Abril +
                response.Mayo + response.Junio + response.Julio + response.Agosto +
                response.Septiembre + response.Octubre + response.Noviembre + response.Diciembre;
            response.Total = response.Importe;
        }

        private static SqlParameter[] BuildParameters(int action, int? id, DepositoResponse? response, int? usuarioActual)
        {
            return
            [
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdDeposito", id ?? response?.PkidDeposito),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response?.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdIngresoAutorizado_PRES", response?.FkidIngresoAutorizadoPres),
                StoredProcedureExecutor.Param("@FKIdTipoDoctoPago_CONTA", response?.FkidTipoDoctoPagoConta),
                StoredProcedureExecutor.Param("@Importe", response?.Importe),
                StoredProcedureExecutor.Param("@NumeroReferencia", response?.NumeroReferencia),
                StoredProcedureExecutor.Param("@ConceptoCheque", response?.ConceptoCheque),
                StoredProcedureExecutor.Param("@FechaEmision", SpDate.ToDateTime(response?.FechaEmision)),
                StoredProcedureExecutor.Param("@NombreAportante", response?.NombreAportante),
                StoredProcedureExecutor.Param("@FKIdCuentaCargo_CONTA", response?.FkidCuentaCargoConta),
                StoredProcedureExecutor.Param("@FKIdCuentaAbono_CONTA", response?.FkidCuentaAbonoConta),
                StoredProcedureExecutor.Param("@FKIdCLCFactura_PRES", response?.FkidClcfacturaPres),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
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
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@Id", id)
            ];
        }

        private static async Task<PagedResult<LookupItem>> ToLookupResultAsync<T>(
            IQueryable<T> query,
            int page,
            int pageSize,
            Func<T, LookupItem> map)
        {
            var currentPage = Math.Max(1, page);
            var currentPageSize = pageSize <= 0 ? 25 : pageSize;
            var totalCount = await query.CountAsync();
            var rows = await query.Skip((currentPage - 1) * currentPageSize).Take(currentPageSize).ToListAsync();

            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = "Catalogo obtenido correctamente.",
                Code = "SUCCESS",
                Items = rows.Select(map).ToList(),
                TotalCount = totalCount
            };
        }

        private static string BuildText(string? clave, string? descripcion)
            => string.IsNullOrWhiteSpace(clave)
                ? descripcion ?? string.Empty
                : string.IsNullOrWhiteSpace(descripcion) ? clave : $"{clave} - {descripcion}";
    }

    internal static class CuentasXPagarScope
    {
        public static PagedRequest AllRowsRequest(string sortLabel) => new()
        {
            Page = 1,
            PageSize = int.MaxValue,
            Filtro = string.Empty,
            SearchString = string.Empty,
            SortLabel = sortLabel,
            SortDirection = "Descending"
        };

        public static void Restrict(PagedRequest request, string idProperty, int[] ids)
        {
            request.AdditionalFilters ??= new Dictionary<string, object>();
            request.AdditionalFilters[$"{idProperty}__in"] = ids;
        }
    }

    internal enum CuentasXPagarBudgetStage
    {
        Devengado,
        Ejercido,
        Pagado
    }

    internal static class CuentasXPagarBudgetPosting
    {
        public static async Task<Poliza> CreateAsync(
            EGestionContext context,
            int contratoId,
            DateOnly fecha,
            CuentasXPagarBudgetStage stage,
            IEnumerable<(int PartidaId, decimal Importe)> sourceDetails,
            int usuarioActual)
        {
            var scope = await (
                from contrato in context.Contratos1.AsNoTracking()
                join autorizacion in context.AutorizacionSuficiencia.AsNoTracking()
                    on contrato.FkidAutorizacionSuficienciaPres equals autorizacion.PkidAutorizacionSuficiencia
                join solicitud in context.SolicitudSuficiencia.AsNoTracking()
                    on autorizacion.FkidSolicitudSuficienciaPres equals solicitud.PkidSolicitudSuficiencia
                join requisicion in context.Requisicions.AsNoTracking()
                    on solicitud.FkidRequisicionOrco equals requisicion.PkidRequisicion
                where contrato.PkidContrato == contratoId && contrato.Activo && contrato.Estatus == 2 &&
                      autorizacion.Activo && autorizacion.Estatus == 2 && solicitud.Activo && solicitud.Estatus == 3 && requisicion.Activo
                select new
                {
                    requisicion.FkidAnioSis,
                    ProgramaId = requisicion.FkidProgramaPres,
                    TipoGastoId = requisicion.FkidTipoGastoPres
                }).FirstOrDefaultAsync();
            if (scope == null || !scope.FkidAnioSis.HasValue || !scope.ProgramaId.HasValue || !scope.TipoGastoId.HasValue)
                throw new InvalidOperationException("El contrato no tiene una clasificacion presupuestal autorizada.");

            var details = sourceDetails
                .Where(x => x.PartidaId > 0 && x.Importe > 0)
                .GroupBy(x => x.PartidaId)
                .Select(x => (PartidaId: x.Key, Importe: decimal.Round(x.Sum(y => y.Importe), 2)))
                .ToList();
            if (details.Count == 0)
                throw new InvalidOperationException("No existen importes presupuestales para generar la poliza.");

            var matrices = await context.MatrizConversions.AsNoTracking()
                .Where(x => x.Activo && x.FkidAnioSis == scope.FkidAnioSis &&
                            x.FkidProgramaPres == scope.ProgramaId.Value &&
                            x.FkidTipoGastoPres == scope.TipoGastoId.Value &&
                            details.Select(d => d.PartidaId).Contains(x.FkidPartidaSis))
                .ToListAsync();
            foreach (var detail in details)
            {
                var count = matrices.Count(x => x.FkidPartidaSis == detail.PartidaId);
                if (count != 1)
                    throw new InvalidOperationException($"La matriz de conversion para la partida {detail.PartidaId} debe existir una sola vez; se encontraron {count} registros activos.");
            }

            var now = DateTime.Now;
            var stageName = stage.ToString().ToUpperInvariant();
            var poliza = new Poliza
            {
                FkidAnioSis = scope.FkidAnioSis.Value,
                FkidMesSis = fecha.Month,
                FkidTipoPolizaSis = 4,
                ClavePoliza = $"{stageName[..Math.Min(3, stageName.Length)]}-{fecha:yyyyMMdd}-{Guid.NewGuid():N}"[..30],
                NombrePoliza = $"{stageName} CUENTAS POR PAGAR",
                FechaPoliza = fecha.ToDateTime(TimeOnly.MinValue),
                EstaBalanceado = true,
                Activo = true,
                FechaCreacion = now,
                UsuarioCreacion = usuarioActual,
                PermitirModificar = false,
                Autorizado = true,
                FechaSolicitud = now,
                FechaAutorizacion = now
            };
            context.Polizas.Add(poliza);
            await context.SaveChangesAsync();

            foreach (var detail in details)
            {
                var matrix = matrices.Single(x => x.FkidPartidaSis == detail.PartidaId);
                var debitAccount = stage switch
                {
                    CuentasXPagarBudgetStage.Devengado => matrix.FkidCuentaContableDevengado,
                    CuentasXPagarBudgetStage.Ejercido => matrix.FkidCuentaContableEjercido,
                    _ => matrix.FkidCuentaContablePagado
                };
                var creditAccount = stage switch
                {
                    CuentasXPagarBudgetStage.Devengado => matrix.FkidCuentaContableComprometido,
                    CuentasXPagarBudgetStage.Ejercido => matrix.FkidCuentaContableDevengado,
                    _ => matrix.FkidCuentaContableEjercido
                };
                context.PolizaDetalles.AddRange(
                    new PolizaDetalle
                    {
                        FkidCuentaContableConta = debitAccount,
                        FkidPolizaConta = poliza.PkidPoliza,
                        Descripcion = $"{stageName} PARTIDA {detail.PartidaId}",
                        ImporteDebe = detail.Importe,
                        ImporteHaber = null,
                        FkidTipoDetallePolizaSis = 1,
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual
                    },
                    new PolizaDetalle
                    {
                        FkidCuentaContableConta = creditAccount,
                        FkidPolizaConta = poliza.PkidPoliza,
                        Descripcion = $"{stageName} PARTIDA {detail.PartidaId}",
                        ImporteDebe = null,
                        ImporteHaber = detail.Importe,
                        FkidTipoDetallePolizaSis = 2,
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual
                    });
            }
            await context.SaveChangesAsync();
            return poliza;
        }
    }

    internal static class CuentasXPagarSpParameters
    {
        public static SqlParameter[] Monthly(
            int action,
            (string Name, object? Value) parentId,
            (string Name, object? Value) detailId,
            int? empresaId,
            int? partidaId,
            decimal? enero,
            decimal? febrero,
            decimal? marzo,
            decimal? abril,
            decimal? mayo,
            decimal? junio,
            decimal? julio,
            decimal? agosto,
            decimal? septiembre,
            decimal? octubre,
            decimal? noviembre,
            decimal? diciembre,
            string? observaciones,
            int? usuarioActual,
            params SqlParameter[] extraParameters)
        {
            var parameters = new List<SqlParameter>
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param(parentId.Name, parentId.Value),
                StoredProcedureExecutor.Param(detailId.Name, detailId.Value),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", empresaId),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", partidaId),
                StoredProcedureExecutor.Param("@Enero", enero),
                StoredProcedureExecutor.Param("@Febrero", febrero),
                StoredProcedureExecutor.Param("@Marzo", marzo),
                StoredProcedureExecutor.Param("@Abril", abril),
                StoredProcedureExecutor.Param("@Mayo", mayo),
                StoredProcedureExecutor.Param("@Junio", junio),
                StoredProcedureExecutor.Param("@Julio", julio),
                StoredProcedureExecutor.Param("@Agosto", agosto),
                StoredProcedureExecutor.Param("@Septiembre", septiembre),
                StoredProcedureExecutor.Param("@Octubre", octubre),
                StoredProcedureExecutor.Param("@Noviembre", noviembre),
                StoredProcedureExecutor.Param("@Diciembre", diciembre),
                StoredProcedureExecutor.Param("@Observaciones", observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual)
            };

            parameters.AddRange(extraParameters);
            return parameters.ToArray();
        }
    }

    internal static class SpDate
    {
        public static DateTime? ToDateTime(DateOnly? value)
        {
            return value.HasValue && value.Value != default
                ? value.Value.ToDateTime(TimeOnly.MinValue)
                : null;
        }
    }
}

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

    public class FacturaAppService(
        GenericService<Factura, FacturaDto, FacturaResponse> service,
        GenericService<VwFactura, FacturaDto, FacturaResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Factura, VwFactura, FacturaDto, FacturaResponse>(
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
        EGestionContext context)
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
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

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

    public class CLCAppService(
        GenericService<Clc, CLCDto, CLCResponse> service,
        GenericService<VwClc, CLCDto, CLCResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Clc, VwClc, CLCDto, CLCResponse>(
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
        EGestionContext context)
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
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

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
        EGestionContext context)
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
        protected override int CreateAction => 9;
        protected override int UpdateAction => 10;
        protected override int DeleteAction => 11;

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

    public class ChequeAppService(
        GenericService<Cheque, ChequeDto, ChequeResponse> service,
        GenericService<VwCheque, ChequeDto, ChequeResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Cheque, VwCheque, ChequeDto, ChequeResponse>(
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
        EGestionContext context)
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
        protected override int CreateAction => 5;
        protected override int UpdateAction => 6;
        protected override int DeleteAction => 7;

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

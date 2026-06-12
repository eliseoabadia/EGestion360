using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.CuentasXPagar;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;

namespace EG.Application.Services.CuentasXPagar
{
    public class ContratoAppService(
        GenericService<Contrato, ContratoDto, ContratoResponse> service,
        GenericService<VwContrato, ContratoDto, ContratoResponse> serviceView,
        EGestionContext context)
        : StoredProcedureCrudAppService<Contrato, VwContrato, ContratoDto, ContratoResponse>(
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

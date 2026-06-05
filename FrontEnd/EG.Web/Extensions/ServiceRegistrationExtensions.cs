using EG.Common.Helper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts;
using EG.Web.Contracts.SoporteDocumental;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Services;
using EG.Web.Services.SoporteDocumental;
using Microsoft.JSInterop;

namespace EG.Web.Extensions;

public static class ApiServiceExtensions
{
    public static IServiceCollection AddApiServices(this IServiceCollection services)
    {
        RegisterCrud<DepartamentoResponse>(services, "api/Departamento");
        RegisterCrud<AreaResponse>(services, "api/Area");
        RegisterCrud<UsuarioResponse>(services, "api/Usuario");
        RegisterCrud<EstadoResponse>(services, "api/Estado");
        RegisterCrud<EmpresaResponse>(services, "api/Empresa");
        RegisterCrud<MenuItemsResponse>(services, "api/Menu");
        RegisterCrud<UsuarioSucursalResponse>(services, "api/UsuarioSucursal");
        RegisterCrud<VwUsuarioSucursalResponse>(services, "api/UsuarioSucursal");
        RegisterCrud<UsuarioAreaResponse>(services, "api/UsuarioArea");
        RegisterCrud<SucursalResponse>(services, "api/Sucursal");

        RegisterCrud<PeriodoConteoResponse>(services, "api/PeriodoConteo");
        RegisterCrud<ConteoResponse>(services, "api/Conteo");
        RegisterCrud<ConteoDetalleEscaneoResponse>(services, "api/ConteoDetalleEscaneo");
        RegisterCrud<ConteoDetalleResponse>(services, "api/ConteoDetalle");
        RegisterCrud<BienBusquedaResponse>(services, "api/ConteoDetalle");

        RegisterCrud<FamiliaResponse>(services, "api/Familia");
        RegisterCrud<UnidadeResponse>(services, "api/Unidades");
        RegisterCrud<MotivoEsResponse>(services, "api/MotivoEs");
        RegisterCrud<EstatusSolicitudResponse>(services, "api/EstatusSol");

        RegisterCrud<TipoCambioResponse>(services, "api/TipoCambio");
        RegisterCrud<TipoInversionResponse>(services, "api/TipoInversion");
        RegisterCrud<TipoMonedaResponse>(services, "api/TipoMoneda");
        RegisterCrud<TipoPagoResponse>(services, "api/TipoPago");
        RegisterCrud<TipoPagoSFResponse>(services, "api/TipoPagoSF");
        RegisterCrud<TipoSolicitudCLCResponse>(services, "api/TipoSolicitudCLC");
        RegisterCrud<TipoDoctoClcResponse>(services, "api/TipoDoctoClc");
        RegisterCrud<BancoResponse>(services, "api/Banco");
        RegisterCrud<CuentaBancariaResponse>(services, "api/CuentaBancaria");
        RegisterCrud<IntermediarioFinancieroResponse>(services, "api/IntermediarioFinanciero");
        RegisterCrud<InstrumentoResponse>(services, "api/Instrumento");
        RegisterCrud<InversionResponse>(services, "api/Inversion");
        RegisterCrud<InteresResponse>(services, "api/Interes");
        RegisterCrud<RetiroResponse>(services, "api/Retiro");
        RegisterCrud<TipoPlazoResponse>(services, "api/TipoPlazo");
        RegisterCrud<TipoRetiroResponse>(services, "api/TipoRetiro");
        RegisterCrud<PaiseDto>(services, "api/Paise");

        RegisterCrud<GfResponse>(services, "api/Gf");
        RegisterCrud<FnResponse>(services, "api/Fn");

        RegisterCrud<ModalidadResponse>(services, "api/Modalidad");
        RegisterCrud<TipoContratoResponse>(services, "api/TipoContrato");
        RegisterCrud<TipoDocumentoResponse>(services, "api/TipoDocumento");
        RegisterCrud<TipoGarantiaResponse>(services, "api/TipoGarantia");
        RegisterCrud<ProcedimientoContratacionResponse>(services, "api/ProcedimientoContratacion");
        RegisterCrud<EstatusRequisicionResponse>(services, "api/EstatusRequisicion");
        RegisterCrud<ArticuloResponse>(services, "api/Articulo");
        RegisterCrud<FraccionResponse>(services, "api/Fraccion");
        RegisterCrud<ProveedorResponse>(services, "api/Proveedor");
        RegisterCrud<PaaaResponse>(services, "api/Paaa");
        RegisterCrud<EstudioMercadoResponse>(services, "api/EstudioMercado");
        RegisterCrud<EstudioMercadoDetalleResponse>(services, "api/EstudioMercadoDetalle");
        RegisterCrud<CotizacionResponse>(services, "api/Cotizacion");
        RegisterCrud<CotizacionDetalleResponse>(services, "api/CotizacionDetalle");
        RegisterCrud<RequisicionResponse>(services, "api/Requisicion");
        RegisterCrud<RequisicionPartidaResponse>(services, "api/RequisicionPartida");
        RegisterCrud<RequisicionDetalleResponse>(services, "api/RequisicionDetalle");
        RegisterCrud<OrdenCompraResponse>(services, "api/OrdenCompra");
        RegisterCrud<OrdenCompraDetalleResponse>(services, "api/OrdenCompraDetalle");
        RegisterCrud<OrdenCompraPartidaResponse>(services, "api/OrdenCompraPartida");
        RegisterCrud<SolicitudSuficienciaResponse>(services, "api/SolicitudSuficiencia");
        RegisterCrud<SolicitudSuficienciaDetalleResponse>(services, "api/SolicitudSuficienciaDetalle");
        RegisterCrud<AutorizacionSuficienciaResponse>(services, "api/AutorizacionSuficiencia");
        RegisterCrud<AutorizacionSuficienciaDetalleResponse>(services, "api/AutorizacionSuficienciaDetalle");
        RegisterCrud<EgreAdecuacionResponse>(services, "api/EgreAdecuacion");
        RegisterCrud<EgreAdecuacionDetalleResponse>(services, "api/EgreAdecuacionDetalle");
        RegisterCrud<TipoAdecuacionResponse>(services, "api/TipoAdecuacion");
        RegisterCrud<EstatusAdecuacionResponse>(services, "api/EstatusAdecuacion");
        RegisterCrud<TipoMovimientoResponse>(services, "api/TipoMovimiento");
        RegisterCrud<EgresoDisponibleResponse>(services, "api/EgresoDisponible");

        RegisterCrud<ContaTipoDoctoPagoResponse>(services, "api/ContaTipoDoctoPago");
        RegisterCrud<GrupoBienResponse>(services, "api/GrupoBien");
        RegisterCrud<NivelResponse>(services, "api/Nivel");
        RegisterCrud<PartidaResponse>(services, "api/Partida");
        RegisterCrud<TipoBienResponse>(services, "api/TipoBien");
        RegisterCrud<TipoPatrimonioResponse>(services, "api/TipoPatrimonio");
        RegisterCrud<TipoAdquisicionResponse>(services, "api/TipoAdquisicion");
        RegisterCrud<MarcaResponse>(services, "api/Marca");
        RegisterCrud<PersonaResponse>(services, "api/Persona");
        RegisterCrud<EG.Domain.DTOs.Responses.Patrimonio.BienResponse>(services, "api/Bien");
        RegisterCrud<BajaResponse>(services, "api/Baja");
        RegisterCrud<TipoBajaResponse>(services, "api/TipoBaja");
        RegisterCrud<EstatusBajaResponse>(services, "api/EstatusBaja");
        RegisterCrud<BienDisponibleBajaResponse>(services, "api/BienDisponibleBaja");
        RegisterCrud<ResguardoResponse>(services, "api/Resguardo");
        RegisterCrud<ResguardoDetalleResponse>(services, "api/ResguardoDetalle");
        RegisterCrud<CalendarioInventarioResponse>(services, "api/CalendarioInventario");
        RegisterCrud<InventarioResponse>(services, "api/Inventario");
        RegisterCrud<InventarioDetalleResponse>(services, "api/InventarioDetalle");
        RegisterCrud<EstatusInventarioResponse>(services, "api/EstatusInventario");

        RegisterCrud<MatrizConversionResponse>(services, "api/MatrizConversion");
        RegisterCrud<UnidadResponsableResponse>(services, "api/UnidadResponsable");
        RegisterCrud<SubFuncionResponse>(services, "api/SubFuncion");
        RegisterCrud<ActividadInstitucionalResponse>(services, "api/ActividadInstitucional");
        RegisterCrud<ProgramaPresupuestalResponse>(services, "api/ProgramaPresupuestal");
        RegisterCrud<AniosResponse>(services, "api/Anios");
        RegisterCrud<SectorResponse>(services, "api/Sector");
        RegisterCrud<TipoRecursoResponse>(services, "api/TipoRecurso");
        RegisterCrud<FuenteFinanciamientoResponse>(services, "api/FuenteFinanciamiento");
        RegisterCrud<EgresoProyectadoResponse>(services, "api/EgresoProyectado");
        RegisterCrud<EgresoAutorizadoResponse>(services, "api/EgresoAutorizado");
        RegisterCrud<PgResponse>(services, "api/Pg");
        RegisterCrud<RamoResponse>(services, "api/Ramo");
        RegisterCrud<ProyectoResponse>(services, "api/Proyecto");
        RegisterCrud<TipoPolizaResponse>(services, "api/TipoPoliza");
        RegisterCrud<TipoDetallePolizaResponse>(services, "api/TipoDetallePoliza");
        RegisterCrud<PolizaResponse>(services, "api/Poliza");
        RegisterCrud<PolizaDetalleResponse>(services, "api/PolizaDetalle");
        RegisterCrud<MatrizIngresoResponse>(services, "api/MatrizIngreso");
        RegisterCrud<ConceptoResponse>(services, "api/Concepto");
        RegisterCrud<CuentaContableResponse>(services, "api/CuentaContable");
        RegisterCrud<ProgramaResponse>(services, "api/Programa");

        RegisterCrud<ContratoResponse>(services, "api/Contrato");
        RegisterCrud<ContratoDetalleResponse>(services, "api/ContratoDetalle");
        RegisterCrud<FacturaResponse>(services, "api/Factura");
        RegisterCrud<FacturaDetalleResponse>(services, "api/FacturaDetalle");
        RegisterCrud<CLCResponse>(services, "api/CLC");
        RegisterCrud<CLCDetalleResponse>(services, "api/CLCDetalle");
        RegisterCrud<CLCFacturaResponse>(services, "api/CLCFactura");
        RegisterCrud<ChequeResponse>(services, "api/Cheque");
        RegisterCrud<ChequePartidaResponse>(services, "api/ChequePartida");

        services.AddScoped<INotificacionService, NotificacionService>();
        services.AddScoped<IDocumentSupportService, DocumentSupportService>();

        return services;
    }

    private static void RegisterCrud<TResponse>(IServiceCollection services, string endpoint)
        where TResponse : class
    {
        services.AddScoped<IGenericCrudService<TResponse>>(sp =>
            new GenericCrudService<TResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                endpoint
            ));
    }
}

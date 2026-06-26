using EG.ApiCoreBS.Services;
using EG.ApiCoreBS.Services.Catalogos.ClavePrograma;
using EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen;
using EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria;
using EG.ApiCoreBS.Services.Contabilidad;
using EG.Application.Interfaces;
using EG.Application.Interfaces.Account;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.Almacen;
using EG.Application.Interfaces.ClavePrograma;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Interfaces.Contabilidad;
using EG.Application.Interfaces.CuentasXPagar;
using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Interfaces.Nomina;
using EG.Application.Interfaces.Patrimonio;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Application.Services;
using EG.Application.Services.Account;
using EG.Application.Services.Adquisicion;
using EG.Application.Services.Almacen;
using EG.Application.Services.ConteoCiclico;
using EG.Application.Services.CuentasXPagar;
using EG.Application.Services.General;
using EG.Application.Services.Nomina;
using EG.Application.Services.PBR;
using EG.Application.Services.PresupuestoComprometido;
using EG.Application.Services.PresupuestoModificado;
using EG.Application.Services.SoporteDocumental;
using EG.Application.Services.Configuracion.Catalogo.ClavePrograma;
using EG.Application.Services.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Configuracion.Catalogo.Patrimonio;
using EG.Application.Services.Patrimonio;
using EG.Business.Interfaces;
using EG.Business.Services;
using EG.Common.Util;
using EG.Domain.Interfaces;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.DTOs.Responses.PBR;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;
using EG.Infrastructure;
using System.Reflection;

namespace EG.ApiCoreBS.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static void AddApplicationServices(this IServiceCollection services, Assembly assembly)
        {
            // Repositories
            services.AddScoped<IRepositorySP<LoginInformationEmployeeResult>, RepositorySP<LoginInformationEmployeeResult>>();
            services.AddScoped<IRepositorySP<spGetClaimsByUserResult>, RepositorySP<spGetClaimsByUserResult>>();
            services.AddScoped<IRepositorySP<spEliminarUsuarioSucursalResult>, RepositorySP<spEliminarUsuarioSucursalResult>>();
            services.AddScoped<IRepositorySP<spNodeMenuResult>, RepositorySP<spNodeMenuResult>>();
            services.AddScoped<IRepository<PerfilUsuario>, Repository<PerfilUsuario>>();
            services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

            // Application services - Account
            services.AddScoped<IAuthAppService, AuthAppService>();
            services.AddScoped<INavigateAppService, NavigateAppService>();

            // Application services - General
            services.AddScoped<IEmpresaAppService, EmpresaAppService>();
            services.AddScoped<IDepartamentoAppService, DepartamentoAppService>();
            services.AddScoped<IEstadoAppService, EstadoAppService>();
            services.AddScoped<IPaisAppService, PaisAppService>();
            services.AddScoped<ISucursalAppService, SucursalAppService>();
            services.AddScoped<IUsuarioAppService, UsuarioAppService>();
            services.AddScoped<IUsuarioSucursalAppService, UsuarioSucursalAppService>();
            services.AddScoped<IAspNetRolesAppService, AspNetRolesAppService>();
            services.AddScoped<IAreaAppService, AreaAppService>();
            services.AddScoped<IDashboardAppService, DashboardAppService>();
            services.AddScoped<INotificacionAppService, NotificacionAppService>();
            services.AddScoped<IUserProfileAppService, UserProfileAppService>();
            services.AddScoped<IUsuarioAreaAppService, UsuarioAreaAppService>();
            services.AddScoped<ISoporteDocumentalAppService, SoporteDocumentalAppService>();

            // Application services - Adquisicion
            services.AddScoped<IPaaaAppService, PaaaAppService>();
            services.AddScoped<IEstudioMercadoService, EstudioMercadoService>();
            services.AddScoped<IEstudioMercadoDetalleService, EstudioMercadoDetalleService>();
            services.AddScoped<IArticuloAppService, ArticuloAppService>();
            services.AddScoped<IEstatusRequisicionAppService, EstatusRequisicionAppService>();
            services.AddScoped<IFraccionAppService, FraccionAppService>();
            services.AddScoped<IModalidadAppService, ModalidadAppService>();
            services.AddScoped<IProcedimientoContratacionAppService, ProcedimientoContratacionAppService>();
            services.AddScoped<IProveedorAppService, ProveedorAppService>();
            services.AddScoped<ICotizacionAppService, CotizacionAppService>();
            services.AddScoped<ICotizacionDetalleAppService, CotizacionDetalleAppService>();
            services.AddScoped<IRequisicionAppService, RequisicionAppService>();
            services.AddScoped<IRequisicionPartidaAppService, RequisicionPartidaAppService>();
            services.AddScoped<IRequisicionDetalleAppService, RequisicionDetalleAppService>();
            services.AddScoped<IOrdenCompraAppService, OrdenCompraAppService>();
            services.AddScoped<IOrdenCompraDetalleAppService, OrdenCompraDetalleAppService>();
            services.AddScoped<IOrdenCompraPartidaAppService, OrdenCompraPartidaAppService>();
            services.AddScoped<ISolicitudSuficienciaAppService, SolicitudSuficienciaAppService>();
            services.AddScoped<ISolicitudSuficienciaDetalleAppService, SolicitudSuficienciaDetalleAppService>();
            services.AddScoped<ITipoContratoAppService, TipoContratoAppService>();
            services.AddScoped<ITipoDocumentoAppService, TipoDocumentoAppService>();
            services.AddScoped<ITipoGarantiaAppService, TipoGarantiaAppService>();

            // Application services - Presupuesto comprometido
            services.AddScoped<IAdquisicionCrudAppService<AutorizacionSuficienciaResponse>, AutorizacionSuficienciaAppService>();
            services.AddScoped<IAdquisicionCrudAppService<AutorizacionSuficienciaDetalleResponse>, AutorizacionSuficienciaDetalleAppService>();

            // Application services - Presupuesto modificado
            services.AddScoped<IPresupuestoModificadoAppService, EgreAdecuacionAppService>();
            services.AddScoped<IAdquisicionCrudAppService<EgreAdecuacionResponse>>(sp => sp.GetRequiredService<IPresupuestoModificadoAppService>());
            services.AddScoped<IAdquisicionCrudAppService<EgreAdecuacionDetalleResponse>, EgreAdecuacionDetalleAppService>();
            services.AddScoped<IIngresoAdecuacionAppService, IngreAdecuacionAppService>();
            services.AddScoped<IAdquisicionCrudAppService<IngreAdecuacionResponse>>(sp => sp.GetRequiredService<IIngresoAdecuacionAppService>());
            services.AddScoped<IAdquisicionCrudAppService<IngreAdecuacionDetalleResponse>, IngreAdecuacionDetalleAppService>();

            // Application services - Cuentas por pagar
            services.AddScoped<IAdquisicionCrudAppService<ContratoResponse>, ContratoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<ContratoDetalleResponse>, ContratoDetalleAppService>();
            services.AddScoped<IAdquisicionCrudAppService<FacturaResponse>, FacturaAppService>();
            services.AddScoped<IAdquisicionCrudAppService<FacturaDetalleResponse>, FacturaDetalleAppService>();
            services.AddScoped<IAdquisicionCrudAppService<CLCResponse>, CLCAppService>();
            services.AddScoped<IAdquisicionCrudAppService<CLCDetalleResponse>, CLCDetalleAppService>();
            services.AddScoped<IAdquisicionCrudAppService<CLCFacturaResponse>, CLCFacturaAppService>();
            services.AddScoped<IAdquisicionCrudAppService<ChequeResponse>, ChequeAppService>();
            services.AddScoped<IAdquisicionCrudAppService<ChequePartidaResponse>, ChequePartidaAppService>();
            services.AddScoped<IDepositoAppService, DepositoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<DepositoResponse>>(sp => sp.GetRequiredService<IDepositoAppService>());

            // Application services - Patrimonio
            services.AddScoped<IFamiliaService, FamiliaService>();
            services.AddScoped<IGrupoBienService, GrupoBienService>();
            services.AddScoped<IMarcaService, MarcaService>();
            services.AddScoped<INivelService, NivelService>();
            services.AddScoped<IPartidaService, PartidaService>();
            services.AddScoped<IPersonaService, PersonaService>();
            services.AddScoped<ITipoAdquisicionService, TipoAdquisicionService>();
            services.AddScoped<ITipoBienService, TipoBienService>();
            services.AddScoped<ITipoPatrimonioService, TipoPatrimonioService>();
            services.AddScoped<IBienAppService, BienAppService>();
            services.AddScoped<IBajaAppService, BajaAppService>();
            services.AddScoped<ITipoBajaAppService, TipoBajaAppService>();
            services.AddScoped<IEstatusBajaAppService, EstatusBajaAppService>();
            services.AddScoped<IBienDisponibleBajaAppService, BienDisponibleBajaAppService>();
            services.AddScoped<IResguardoAppService, ResguardoAppService>();
            services.AddScoped<IResguardoDetalleAppService, ResguardoDetalleAppService>();
            services.AddScoped<ICalendarioInventarioAppService, CalendarioInventarioAppService>();
            services.AddScoped<IInventarioAppService, InventarioAppService>();
            services.AddScoped<IInventarioDetalleAppService, InventarioDetalleAppService>();
            services.AddScoped<IEstatusInventarioAppService, EstatusInventarioAppService>();

            // Application services - Presupuestales
            services.AddScoped<IProgramaAppServices, ProgramaAppServices>();
            services.AddScoped<IActividadInstitucionalAppServices, ActividadInstitucionalAppServices>();
            services.AddScoped<IAniosAppServices, AniosAppServices>();
            services.AddScoped<IFuenteFinanciamientoAppServices, FuenteFinanciamientoAppServices>();
            services.AddScoped<IEgresoProyectadoAppService, EgresoProyectadoAppService>();
            services.AddScoped<IEgresoAutorizadoAppService, EgresoAutorizadoAppService>();
            services.AddScoped<IIngresoAutorizadoAppService, IngresoAutorizadoAppService>();
            services.AddScoped<IPgAppServices, PgAppServices>();
            services.AddScoped<IProgramaPresupuestalAppServices, ProgramaPresupuestalAppServices>();
            services.AddScoped<IProyectoAppServices, ProyectoAppServices>();
            services.AddScoped<IRamoAppServices, RamoAppServices>();
            services.AddScoped<ISectorAppServices, SectorAppServices>();
            services.AddScoped<ITipoRecursoAppServices, TipoRecursoAppServices>();
            services.AddScoped<IUnidadResponsableAppServices, UnidadResponsableAppServices>();

            // Application services - Nomina
            services.AddScoped<INominaCrudAppService<NomEmpresaNominaResponse>, NomEmpresaNominaAppService>();
            services.AddScoped<INominaCrudAppService<NomUniversoResponse>, NomUniversoAppService>();
            services.AddScoped<INominaCrudAppService<NomNivelResponse>, NomNivelAppService>();
            services.AddScoped<INominaCrudAppService<NomClasePuestoResponse>, NomClasePuestoAppService>();
            services.AddScoped<INominaCrudAppService<NomPuestoResponse>, NomPuestoAppService>();
            services.AddScoped<INominaCrudAppService<NomPlazaAutorizadaResponse>, NomPlazaAutorizadaAppService>();
            services.AddScoped<INominaCrudAppService<NomNombramientoResponse>, NomNombramientoAppService>();
            services.AddScoped<INominaCrudAppService<NomImporteNivelResponse>, NomImporteNivelAppService>();
            services.AddScoped<INominaCrudAppService<NomContratoLaboralResponse>, NomContratoLaboralAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoResponse>, NomConceptoAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoFactorResponse>, NomConceptoFactorAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoFijoResponse>, NomConceptoFijoAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoPorcentajeResponse>, NomConceptoPorcentajeAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoProporcionalResponse>, NomConceptoProporcionalAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoTabularResponse>, NomConceptoTabularAppService>();
            services.AddScoped<INominaCrudAppService<NomConceptoVariableResponse>, NomConceptoVariableAppService>();
            services.AddScoped<INominaCrudAppService<NomContratoTercerosResponse>, NomContratoTercerosAppService>();
            services.AddScoped<INominaCrudAppService<NomCreditoResponse>, NomCreditoAppService>();
            services.AddScoped<INominaCrudAppService<NomDescuentoCreditoResponse>, NomDescuentoCreditoAppService>();
            services.AddScoped<INominaCrudAppService<NomDescuentoInfonavitResponse>, NomDescuentoInfonavitAppService>();
            services.AddScoped<INominaCrudAppService<NomEstatusPagoResponse>, NomEstatusPagoAppService>();
            services.AddScoped<INominaCrudAppService<NomFactorIntResponse>, NomFactorIntAppService>();
            services.AddScoped<INominaCrudAppService<NomInfonavitResponse>, NomInfonavitAppService>();
            services.AddScoped<INominaCrudAppService<NomPeriodoActivoResponse>, NomPeriodoActivoAppService>();
            services.AddScoped<INominaCrudAppService<NomSalarioMinimoResponse>, NomSalarioMinimoAppService>();
            services.AddScoped<INominaCrudAppService<NomSueldoEspecialResponse>, NomSueldoEspecialAppService>();
            services.AddScoped<INominaCrudAppService<NomSueldoLiqFinResponse>, NomSueldoLiqFinAppService>();
            services.AddScoped<INominaCrudAppService<NomSueldoMensualResponse>, NomSueldoMensualAppService>();
            services.AddScoped<INominaCrudAppService<NomSueldoQuincenalResponse>, NomSueldoQuincenalAppService>();
            services.AddScoped<INominaCrudAppService<NomSueldoSemanalResponse>, NomSueldoSemanalAppService>();
            services.AddScoped<INominaCrudAppService<NomTipoIncapacidadResponse>, NomTipoIncapacidadAppService>();
            services.AddScoped<INominaCrudAppService<NomTipoPagoResponse>, NomTipoPagoAppService>();
            services.AddScoped<INominaCrudAppService<NomTipoPensionResponse>, NomTipoPensionAppService>();
            services.AddScoped<INominaCrudAppService<NomCatalogoSimpleResponse>, NomCatalogoSimpleAppService>();
            services.AddScoped<INominaCrudAppService<NomEstadoCivilResponse>, NomEstadoCivilAppService>();
            services.AddScoped<INominaProcesoAppService, NominaProcesoAppService>();
            services.AddScoped<INominaOperacionAppService, NominaOperacionAppService>();
            services.AddScoped<INominaRhEmpleadoAppService, NominaRhEmpleadoAppService>();
            services.AddScoped<INominaRhEmpleadoDetalleAppService, NominaRhEmpleadoDetalleAppService>();
            services.AddScoped<INominaRhDetailAppService<NominaRhExpedienteDto, NominaRhExpedienteResponse>, NominaRhExpedienteAppService>();
            services.AddScoped<INominaRhDetailAppService<NominaRhContratoDto, NominaRhContratoResponse>, NominaRhContratoAppService>();
            services.AddScoped<INominaRhDetailAppService<NominaRhDependienteDto, NominaRhDependienteResponse>, NominaRhDependienteAppService>();
            services.AddScoped<INominaRhDetailAppService<NominaRhIncidenciaDto, NominaRhIncidenciaResponse>, NominaRhIncidenciaAppService>();
            services.AddScoped<INominaRhDetailAppService<NominaRhPensionDto, NominaRhPensionResponse>, NominaRhPensionAppService>();
            services.AddScoped<INominaRhLookupAppService, NominaRhLookupAppService>();

            // Application services - PBR
            services.AddScoped<IPbrDashboardAppService, PbrDashboardAppService>();
            services.AddScoped<IAdquisicionCrudAppService<PbrAnteproyectoResponse>, PbrAnteproyectoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<PbrPresupuestoProgramaResponse>, PbrPresupuestoProgramaAppService>();
            services.AddScoped<IAdquisicionCrudAppService<PbrPartidaGastoResponse>, PbrPartidaGastoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<PbrMirNivelResponse>, PbrMirNivelAppService>();
            services.AddScoped<IAdquisicionCrudAppService<PbrIndicadorResponse>, PbrIndicadorAppService>();

            // Application services - Conteo ciclico
            services.AddScoped<IConteoAppService, ConteoAppService>();
            services.AddScoped<IPeriodoConteoAppService, PeriodoConteoAppService>();
            services.AddScoped<IConteoDetalleAppService, ConteoDetalleAppService>();
            services.AddScoped<IConteoDetalleEscaneoAppService, ConteoDetalleEscaneoAppService>();

            // Application services - Contabilidad
            services.AddScoped<ITipoPolizaService, TipoPolizaService>();
            services.AddScoped<IMatrizConversionService, MatrizConversionService>();
            services.AddScoped<IContaTipoDoctoPagoService, ContaTipoDoctoPagoService>();
            services.AddScoped<IMatrizIngresoService, MatrizIngresoService>();
            services.AddScoped<IConceptoService, ConceptoService>();
            services.AddScoped<ICuentaContableService, CuentaContableService>();
            services.AddScoped<ITipoDetallePolizaService, TipoDetallePolizaService>();
            services.AddScoped<IPolizaService, PolizaService>();
            services.AddScoped<IPolizaDetalleService, PolizaDetalleService>();
            services.AddScoped<ICierreMensualService, CierreMensualService>();

            // Application services - Tesoreria
            services.AddScoped<ITipoCambioService, TipoCambioService>();
            services.AddScoped<ITipoDoctoClcService, TipoDoctoClcService>();
            services.AddScoped<ITipoInversionService, TipoInversionService>();
            services.AddScoped<ITipoMonedaService, TipoMonedaService>();
            services.AddScoped<ITipoPagoService, TipoPagoService>();
            services.AddScoped<ITipoPagoSFService, TipoPagoSFService>();
            services.AddScoped<ITipoSolicitudCLCService, TipoSolicitudCLCService>();
            services.AddScoped<IAdquisicionCrudAppService<BancoResponse>, BancoInversionService>();
            services.AddScoped<IAdquisicionCrudAppService<CuentaBancariaResponse>, CuentaBancariaInversionService>();
            services.AddScoped<IAdquisicionCrudAppService<IntermediarioFinancieroResponse>, IntermediarioFinancieroInversionService>();
            services.AddScoped<IAdquisicionCrudAppService<InstrumentoResponse>, InstrumentoInversionService>();
            services.AddScoped<IAdquisicionCrudAppService<InversionResponse>, InversionAppService>();
            services.AddScoped<IAdquisicionCrudAppService<InteresResponse>, InteresAppService>();
            services.AddScoped<IAdquisicionCrudAppService<RetiroResponse>, RetiroAppService>();
            services.AddScoped<IAdquisicionCrudAppService<TipoPlazoResponse>, TipoPlazoInversionService>();
            services.AddScoped<IAdquisicionCrudAppService<TipoRetiroResponse>, TipoRetiroInversionService>();
            services.AddScoped<IProvisionPagoImporteAppService, ProvisionPagoImporteAppService>();

            // Application services - Almacen
            services.AddScoped<IEstatusSolService, EstatusSolService>();
            services.AddScoped<IMotivoEsService, MotivoEsService>();
            services.AddScoped<IUnidadesService, UnidadesService>();
            services.AddScoped<IAlmacenAppService, AlmacenAppService>();
            services.AddScoped<ISolicitudSalidaAppService, SolicitudSalidaAppService>();
            services.AddScoped<IDetalleSolicitudSalidaAppService, DetalleSolicitudSalidaAppService>();
            services.AddScoped<IEstatusSolicitudSalidaAppService, EstatusSolicitudSalidaAppService>();

            // Business services
            services.AddHttpContextAccessor();
            services.AddScoped<IUserContextService, UserContextService>();
            services.AddScoped<IEmailService, EmailService>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<INavigateService, NavigateService>();
            services.AddScoped<IUserIpService, UserIpService>();
            services.AddScoped<IUserProfileService, UserProfileService>();
            services.AddScoped<IEmployeeService, EmployeeService>();

            // Catalog services - Clave programa
            services.AddScoped<IGfService, GfService>();
            services.AddScoped<IFnService, FnService>();
            services.AddScoped<ISfService, SfService>();
            services.AddScoped<IFnAppService, FnAppService>();
            services.AddScoped<IGfAppService, GfAppService>();
            services.AddScoped<ISfAppService, SfAppService>();

            //// ===== SERVICIOS GENÉRICOS =====
            services.AddScoped(typeof(GenericService<,,>)); // 3 parámetros: TEntity, TDto, TResponse
            services.AddScoped(typeof(GenericService<,>));  // 2 parámetros: TEntity, TDto
        }
    }
}

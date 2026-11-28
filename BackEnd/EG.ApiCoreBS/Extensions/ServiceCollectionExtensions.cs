using EG.ApiCoreBS.Services;
using EG.ApiCoreBS.Services.Catalogos.ClavePrograma;
using EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen;
using EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria;
using EG.ApiCoreBS.Services.Contabilidad;
using EG.ApiCoreBS.Services.DocumentRag;
using EG.Application.Interfaces;
using EG.Application.Interfaces.AccessConfiguration;
using EG.Application.Interfaces.Account;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.Almacen;
using EG.Application.Interfaces.ClavePrograma;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Interfaces.Contabilidad;
using EG.Application.Interfaces.Contratos;
using EG.Application.Interfaces.CuentasXPagar;
using EG.Application.Interfaces.DocumentRag;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Interfaces.Nomina;
using EG.Application.Interfaces.Patrimonio;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Application.Services;
using EG.Application.Services.AccessConfiguration;
using EG.Application.Services.Account;
using EG.Application.Services.Adquisicion;
using EG.Application.Services.Almacen;
using EG.Application.Services.ConteoCiclico;
using EG.Application.Services.Contratos;
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
using EG.Application.Services.DocumentRag;
using EG.Application.Services.FirmaDocumental;
using EG.Application.Services.FirmaDocumental.Providers;
using EG.Application.Services.Patrimonio;
using EG.Business.Interfaces;
using EG.Business.Services;
using EG.Common.Util;
using EG.Domain.Interfaces;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.DTOs.Responses.Contratos;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.DTOs.Responses.PBR;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.DTOs.Responses.Patrimonio;
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
            services.AddScoped<IMenuPersistence, MenuPersistence>();
            services.AddScoped<IMenuRoleRepository, MenuRoleRepository>();
            services.AddScoped<IMenuAppService, MenuAppService>();
            services.AddScoped<IMenuRoleAppService, MenuRoleAppService>();
            services.AddScoped<IRepositorySP<LoginInformationEmployeeResult>, RepositorySP<LoginInformationEmployeeResult>>();
            services.AddScoped<IRepositorySP<spGetClaimsByUserResult>, RepositorySP<spGetClaimsByUserResult>>();
            services.AddScoped<IRepositorySP<spEliminarUsuarioSucursalResult>, RepositorySP<spEliminarUsuarioSucursalResult>>();
            services.AddScoped<IRepositorySP<spNodeMenuResult>, RepositorySP<spNodeMenuResult>>();
            services.AddScoped<IRepository<PerfilUsuario>, Repository<PerfilUsuario>>();
            services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

            // Application services - Account
            services.AddScoped<IAuthAppService, AuthAppService>();
            services.AddScoped<IPasswordResetAppService, PasswordResetAppService>();
            services.AddScoped<IPasswordResetRepository, PasswordResetRepository>();
            services.AddSingleton<IPasswordResetTokenService, PasswordResetTokenService>();
            services.AddScoped<INavigateAppService, NavigateAppService>();

            // Application services - General
            services.AddScoped<EG.Business.Interfaces.IEmpresaAdministrationService, EG.Business.Services.General.EmpresaService>();
            services.AddScoped<IEmpresaAppService, EmpresaAppService>();
            services.AddScoped<EG.Business.Interfaces.IDepartamentoService, EG.Business.Services.General.DepartamentoService>();
            services.AddScoped<IDepartamentoAppService, DepartamentoAppService>();
            services.AddScoped<IEstadoAppService, EstadoAppService>();
            services.AddScoped<IPaisAppService, PaisAppService>();
            services.AddScoped<EG.Business.Interfaces.ISucursalService, EG.Business.Services.General.SucursalService>();
            services.AddScoped<ISucursalAppService, SucursalAppService>();
            services.AddScoped<IUsuarioAppService, UsuarioAppService>();
            services.AddScoped<EG.Business.Interfaces.IUsuarioSucursalOperations, EG.Business.Services.General.UsuarioSucursalOperationsService>();
            services.AddScoped<IUsuarioSucursalAppService, UsuarioSucursalAppService>();
            services.AddScoped<IAspNetRolesAppService, AspNetRolesAppService>();
            services.AddScoped<EG.Business.Interfaces.IAccessConfigurationOperations, EG.Business.Services.AccessConfiguration.AccessConfigurationOperationsService>();
            services.AddScoped<IAccessConfigurationAppService, AccessConfigurationAppService>();
            services.AddScoped<IAreaAppService, AreaAppService>();
            services.AddScoped<EG.Business.Interfaces.IAreaService, EG.Business.Services.General.AreaService>();
            services.AddScoped<EG.Business.Interfaces.IDashboardService, EG.Business.Services.General.DashboardService>();
            services.AddScoped<IDashboardAppService, DashboardAppService>();
            services.AddScoped<EG.Business.Interfaces.INotificacionOperations, EG.Business.Services.General.NotificacionOperationsService>();
            services.AddScoped<INotificacionAppService, NotificacionAppService>();
            services.AddScoped<EG.Business.Interfaces.IUserProfileOperations, EG.Business.Services.General.UserProfileOperationsService>();
            services.AddScoped<IUserProfileAppService, UserProfileAppService>();
            services.AddScoped<EG.Business.Interfaces.IEnvioWorkflowOperations, EG.Business.Services.General.EnvioWorkflowOperationsService>();
            services.AddScoped<IEnvioWorkflowService, EnvioWorkflowService>();
            services.AddScoped<IEnvioWorkflowRepository, EnvioWorkflowRepository>();
            services.AddScoped<IResguardoMovimientoAppService, ResguardoMovimientoAppService>();
            services.AddScoped<IResguardoMovimientoQueries, ResguardoMovimientoQueries>();
            services.AddScoped<ICatalogLookupQueries, CatalogLookupQueries>();
            services.AddScoped<IRepositoryProvider, RepositoryProvider>();
            services.AddScoped<IPaaaPersistence, PaaaPersistence>();
            services.AddScoped<IPaaaService, PaaaService>();
            services.AddScoped<IPaaaAppService, PaaaAppService>();
            services.AddScoped<ICatalogLookupService, CatalogLookupService>();
            services.AddScoped<ICatalogLookupAppService, CatalogLookupAppService>();
            services.AddScoped<IRhIncidenciaQueries, RhIncidenciaQueries>();
            services.AddScoped<INominaRhIncidenciaListadoAppService, NominaRhIncidenciaListadoAppService>();
            services.AddScoped<IMatrizConversionReferences, MatrizConversionReferences>();
            services.AddScoped<IMatrizConversionValidationService, EG.Application.Services.Contabilidad.MatrizConversionValidationService>();
            services.AddScoped<EG.Business.Interfaces.IUsuarioAreaOperations, EG.Business.Services.General.UsuarioAreaOperationsService>();
            services.AddScoped<IUsuarioAreaAppService, UsuarioAreaAppService>();
            services.AddScoped<EG.Business.Interfaces.IUsuarioDepartamentoOperations, EG.Business.Services.General.UsuarioDepartamentoOperationsService>();
            services.AddScoped<IUsuarioDepartamentoAppService, UsuarioDepartamentoAppService>();
            services.AddScoped<EG.Business.Interfaces.ISoporteDocumentalService, EG.Business.Services.SoporteDocumental.SoporteDocumentalService>();
            services.AddScoped<ISoporteDocumentalAppService, SoporteDocumentalAppService>();
            services.AddScoped<IDocumentSummaryQueries, DocumentSummaryQueries>();
            services.AddScoped<IDocumentSummaryAppService, DocumentSummaryAppService>();
            services.AddSingleton<DocumentRagAppService>();
            services.AddSingleton<IDocumentRagAppService>(provider => provider.GetRequiredService<DocumentRagAppService>());
            services.AddSingleton<IRagEmbeddingService, OpenAiCompatibleRagEmbeddingService>();
            services.AddHostedService<DocumentRagCleanupHostedService>();
            services.AddSingleton<IFirmaCertificateProtector, AesFirmaCertificateProtector>();
            services.AddSingleton<IFirmaDocumentalStore, FileFirmaDocumentalStore>();
            services.AddScoped<IFirmaDocumentalProvider, SatPfxFirmaProvider>();
            services.AddScoped<IFirmaDocumentalProvider, FirmaSimpleInternaProvider>();
            services.AddScoped<IFirmaDocumentalProvider>(_ => new PlaceholderFirmaProvider(
                "PROVEEDOR_PAGO",
                "Proveedor comercial",
                "Adaptador reservado para proveedores comerciales con webhooks, evidencias avanzadas y validaciones externas.",
                requiereCertificado: false));
            services.AddScoped<IFirmaDocumentalProvider>(_ => new PlaceholderFirmaProvider(
                "OPEN_SOURCE_PDF",
                "Firma PDF open source",
                "Adaptador reservado para estampado PDF local con certificados propios o librerias open source.",
                requiereCertificado: true));
            services.AddScoped<IFirmaDocumentalAppService, FirmaDocumentalAppService>();

            // Application services - Adquisicion
            services.AddScoped<IPaaaAppService, PaaaAppService>();
            services.AddScoped<EG.Business.Interfaces.IEstudioMercadoOperations, EG.Business.Services.Adquisicion.EstudioMercadoOperationsService>();
            services.AddScoped<IEstudioMercadoService, EstudioMercadoService>();
            services.AddScoped<EG.Business.Interfaces.IEstudioMercadoDetalleOperations, EG.Business.Services.Adquisicion.EstudioMercadoDetalleOperationsService>();
            services.AddScoped<IEstudioMercadoDetalleService, EstudioMercadoDetalleService>();
            services.AddScoped<IArticuloAppService, ArticuloAppService>();
            services.AddScoped<EG.Business.Interfaces.IEstatusRequisicionOperations, EG.Business.Services.Adquisicion.EstatusRequisicionOperationsService>();
            services.AddScoped<IEstatusRequisicionAppService, EstatusRequisicionAppService>();
            services.AddScoped<EG.Business.Interfaces.IFraccionOperations, EG.Business.Services.Adquisicion.FraccionOperationsService>();
            services.AddScoped<IFraccionAppService, FraccionAppService>();
            services.AddScoped<IModalidadAppService, ModalidadAppService>();
            services.AddScoped<IProcedimientoContratacionAppService, ProcedimientoContratacionAppService>();
            services.AddScoped<EG.Business.Interfaces.IProveedorOperations, EG.Business.Services.Adquisicion.ProveedorOperationsService>();
            services.AddScoped<IProveedorAppService, ProveedorAppService>();
            services.AddScoped<EG.Business.Interfaces.ICotizacionOperations, EG.Business.Services.Adquisicion.CotizacionOperationsService>();
            services.AddScoped<ICotizacionAppService, CotizacionAppService>();
            services.AddScoped<EG.Business.Interfaces.ICotizacionDetalleOperations, EG.Business.Services.Adquisicion.CotizacionDetalleOperationsService>();
            services.AddScoped<ICotizacionDetalleAppService, CotizacionDetalleAppService>();
            services.AddScoped<EG.Business.Interfaces.IRequisicionOperations, EG.Business.Services.Adquisicion.RequisicionOperationsService>();
            services.AddScoped<IRequisicionAppService, RequisicionAppService>();
            services.AddScoped<EG.Business.Interfaces.IRequisicionPartidaOperations, EG.Business.Services.Adquisicion.RequisicionPartidaOperationsService>();
            services.AddScoped<IRequisicionPartidaAppService, RequisicionPartidaAppService>();
            services.AddScoped<EG.Business.Interfaces.IRequisicionDetalleOperations, EG.Business.Services.Adquisicion.RequisicionDetalleOperationsService>();
            services.AddScoped<IRequisicionDetalleAppService, RequisicionDetalleAppService>();
            services.AddScoped<EG.Business.Interfaces.IOrdenCompraOperations, EG.Business.Services.Adquisicion.OrdenCompraOperationsService>();
            services.AddScoped<IOrdenCompraAppService, OrdenCompraAppService>();
            services.AddScoped<GenericService<VwOrdenCompra, EG.Domain.DTOs.Requests.Adquisicion.OrdenCompraDto, EG.Domain.DTOs.Responses.Adquisicion.OrdenCompraResponse>, EG.Business.Services.Adquisicion.OrdenCompraReadService>();
            services.AddScoped<EG.Business.Interfaces.IOrdenCompraDetalleOperations, EG.Business.Services.Adquisicion.OrdenCompraDetalleOperationsService>();
            services.AddScoped<IOrdenCompraDetalleAppService, OrdenCompraDetalleAppService>();
            services.AddScoped<EG.Business.Interfaces.IOrdenCompraPartidaOperations, EG.Business.Services.Adquisicion.OrdenCompraPartidaOperationsService>();
            services.AddScoped<IOrdenCompraPartidaAppService, OrdenCompraPartidaAppService>();
            services.AddScoped<EG.Business.Interfaces.ISolicitudSuficienciaOperations, EG.Business.Services.Adquisicion.SolicitudSuficienciaOperationsService>();
            services.AddScoped<ISolicitudSuficienciaAppService, SolicitudSuficienciaAppService>();
            services.AddScoped<EG.Business.Interfaces.ISolicitudSuficienciaDetalleOperations, EG.Business.Services.Adquisicion.SolicitudSuficienciaDetalleOperationsService>();
            services.AddScoped<ISolicitudSuficienciaDetalleAppService, SolicitudSuficienciaDetalleAppService>();
            services.AddScoped<ITipoContratoAppService, TipoContratoAppService>();
            services.AddScoped<ITipoDocumentoAppService, TipoDocumentoAppService>();
            services.AddScoped<ITipoGarantiaAppService, TipoGarantiaAppService>();

            // Application services - Contratos
            services.AddScoped<IRegistroCompromisoAppService, RegistroCompromisoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<OrcoContratoResponse>>(sp => sp.GetRequiredService<IRegistroCompromisoAppService>());
            services.AddScoped<IAdquisicionCrudAppService<SaldosContratoResponse>, SaldosContratoAppService>();
            services.AddScoped<IEstadoContratoAppService, EstadoContratoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<EstadoContratoResponse>>(sp => sp.GetRequiredService<IEstadoContratoAppService>());

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
            services.AddScoped<IAdquisicionCrudAppService<EgresoDisponibleResponse>, EgresoDisponibleAppService>();

            // Application services - Cuentas por pagar
            services.AddScoped<IAdquisicionCrudAppService<ContratoResponse>, ContratoAppService>();
            services.AddScoped<IAdquisicionCrudAppService<ContratoDetalleResponse>, ContratoDetalleAppService>();
            services.AddScoped<IAdquisicionCrudAppService<FacturaResponse>, FacturaAppService>();
            services.AddScoped<IAdquisicionCrudAppService<FacturaDetalleResponse>, FacturaDetalleAppService>();
            services.AddScoped<IAdquisicionCrudAppService<CLCResponse>, CLCAppService>();
            services.AddScoped<IAdquisicionCrudAppService<CLCDetalleResponse>, CLCDetalleAppService>();
            services.AddScoped<IAdquisicionCrudAppService<CLCFacturaResponse>, CLCFacturaAppService>();
            services.AddScoped<IChequeAppService, ChequeAppService>();
            services.AddScoped<IAdquisicionCrudAppService<ChequeResponse>>(sp => sp.GetRequiredService<IChequeAppService>());
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
            services.AddScoped<EG.Business.Interfaces.ITipoBienOperations, EG.Business.Services.Configuracion.Catalogo.Patrimonio.TipoBienOperationsService>();
            services.AddScoped<ITipoBienService, TipoBienService>();
            services.AddScoped<ITipoPatrimonioService, TipoPatrimonioService>();
            services.AddScoped<EG.Business.Interfaces.IBienOperations, EG.Business.Services.Patrimonio.BienOperationsService>();
            services.AddScoped<IBienAppService, BienAppService>();
            services.AddScoped<EG.Business.Interfaces.IClasificacionBienesMueblesOperations, EG.Business.Services.Patrimonio.ClasificacionBienesMueblesOperationsService>();
            services.AddScoped<IClasificacionBienesMueblesAppService, ClasificacionBienesMueblesAppService>();
            services.AddScoped<IAdquisicionCrudAppService<ClasificacionBienesMueblesResponse>>(sp =>
                sp.GetRequiredService<IClasificacionBienesMueblesAppService>());
            services.AddScoped<EG.Business.Interfaces.IBajaOperations, EG.Business.Services.Patrimonio.BajaOperationsService>();
            services.AddScoped<IBajaAppService, BajaAppService>();
            services.AddScoped<EG.Business.Interfaces.ITipoBajaOperations, EG.Business.Services.Patrimonio.TipoBajaOperationsService>();
            services.AddScoped<ITipoBajaAppService, TipoBajaAppService>();
            services.AddScoped<EG.Business.Interfaces.IEstatusBajaOperations, EG.Business.Services.Patrimonio.EstatusBajaOperationsService>();
            services.AddScoped<IEstatusBajaAppService, EstatusBajaAppService>();
            services.AddScoped<IBienDisponibleBajaAppService, BienDisponibleBajaAppService>();
            services.AddScoped<EG.Business.Interfaces.IResguardoOperations, EG.Business.Services.Patrimonio.ResguardoOperationsService>();
            services.AddScoped<IResguardoAppService, ResguardoAppService>();
            services.AddScoped<EG.Business.Interfaces.ICedulaDiferenciasOperations, EG.Business.Services.Patrimonio.CedulaDiferenciasOperationsService>();
            services.AddScoped<ICedulaDiferenciasAppService, CedulaDiferenciasAppService>();
            services.AddScoped<EG.Business.Interfaces.IResguardoDetalleOperations, EG.Business.Services.Patrimonio.ResguardoDetalleOperationsService>();
            services.AddScoped<IResguardoDetalleAppService, ResguardoDetalleAppService>();
            services.AddScoped<EG.Business.Interfaces.ICalendarioInventarioOperations, EG.Business.Services.Patrimonio.CalendarioInventarioOperationsService>();
            services.AddScoped<ICalendarioInventarioAppService, CalendarioInventarioAppService>();
            services.AddScoped<EG.Business.Interfaces.IInventarioOperations, EG.Business.Services.Patrimonio.InventarioOperationsService>();
            services.AddScoped<IInventarioAppService, InventarioAppService>();
            services.AddScoped<EG.Business.Interfaces.IInventarioDetalleOperations, EG.Business.Services.Patrimonio.InventarioDetalleOperationsService>();
            services.AddScoped<IInventarioDetalleAppService, InventarioDetalleAppService>();
            services.AddScoped<EG.Business.Interfaces.IEstatusInventarioOperations, EG.Business.Services.Patrimonio.EstatusInventarioOperationsService>();
            services.AddScoped<IEstatusInventarioAppService, EstatusInventarioAppService>();

            // Application services - Presupuestales
            services.AddScoped<IProgramaAppServices, ProgramaAppServices>();
            services.AddScoped<IActividadInstitucionalAppServices, ActividadInstitucionalAppServices>();
            services.AddScoped<IAniosAppServices, AniosAppServices>();
            services.AddScoped<IFuenteFinanciamientoAppServices, FuenteFinanciamientoAppServices>();
            services.AddScoped<EG.Business.Interfaces.IEgresoProyectadoOperations, EG.Business.Services.Configuracion.Catalogo.Presupuestales.EgresoProyectadoOperationsService>();
            services.AddScoped<IEgresoProyectadoAppService, EgresoProyectadoAppService>();
            services.AddScoped<EG.Business.Interfaces.IEgresoAutorizadoOperations, EG.Business.Services.Configuracion.Catalogo.Presupuestales.EgresoAutorizadoOperationsService>();
            services.AddScoped<IEgresoAutorizadoAppService, EgresoAutorizadoAppService>();
            services.AddScoped<EG.Business.Interfaces.IIngresoAutorizadoOperations, EG.Business.Services.Configuracion.Catalogo.Presupuestales.IngresoAutorizadoOperationsService>();
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
            services.AddScoped<INominaCrudAppService<NomTablaFiscalResponse>, NomTablaFiscalAppService>();
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
            services.AddScoped<INominaCrudAppService<NomEscolaridadResponse>, NomEscolaridadAppService>();
            services.AddScoped<INominaCrudAppService<NomDiaSemanaResponse>, NomDiaSemanaAppService>();
            services.AddScoped<INominaCrudAppService<NomMedodoPagoResponse>, NomMedodoPagoAppService>();
            services.AddScoped<INominaCrudAppService<NomParentescoResponse>, NomParentescoAppService>();
            services.AddScoped<INominaCrudAppService<NomTipoContratacionResponse>, NomTipoContratacionAppService>();
            services.AddScoped<INominaCrudAppService<NomTipoIncidenciaResponse>, NomTipoIncidenciaAppService>();
            services.AddScoped<INominaCrudAppService<NomTipoJustificacionResponse>, NomTipoJustificacionAppService>();
            services.AddScoped<EG.Business.Interfaces.INominaProcesoOperations, EG.Business.Services.Nomina.NominaProcesoOperationsService>();
            services.AddScoped<INominaProcesoAppService, NominaProcesoAppService>();
            services.AddScoped<EG.Business.Interfaces.INominaOperacionOperations, EG.Business.Services.Nomina.NominaOperacionOperationsService>();
            services.AddScoped<INominaOperacionAppService, NominaOperacionAppService>();
            services.AddScoped<EG.Business.Interfaces.INominaRhEmpleadoOperations, EG.Business.Services.Nomina.NominaRhEmpleadoOperationsService>();
            services.AddScoped<INominaRhEmpleadoAppService, NominaRhEmpleadoAppService>();
            services.AddScoped<EG.Business.Interfaces.INominaRhEmpleadoDetalleOperations, EG.Business.Services.Nomina.NominaRhEmpleadoDetalleOperationsService>();
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
            services.AddScoped<EG.Business.Interfaces.IConteoOperations, EG.Business.Services.ConteoCiclico.ConteoOperationsService>();
            services.AddScoped<IConteoAppService, ConteoAppService>();
            services.AddScoped<EG.Business.Interfaces.IPeriodoConteoOperations, EG.Business.Services.ConteoCiclico.PeriodoConteoOperationsService>();
            services.AddScoped<IPeriodoConteoAppService, PeriodoConteoAppService>();
            services.AddScoped<EG.Business.Interfaces.IConteoDetalleOperations, EG.Business.Services.ConteoCiclico.ConteoDetalleOperationsService>();
            services.AddScoped<IConteoDetalleAppService, ConteoDetalleAppService>();
            services.AddScoped<EG.Business.Interfaces.IConteoDetalleEscaneoOperations, EG.Business.Services.ConteoCiclico.ConteoDetalleEscaneoOperationsService>();
            services.AddScoped<IConteoDetalleEscaneoAppService, ConteoDetalleEscaneoAppService>();

            // Application services - Contabilidad
            services.AddScoped<ITipoPolizaService, TipoPolizaService>();
            services.AddScoped<EG.Business.Interfaces.IMatrizConversionOperations, EG.ApiCoreBS.Services.Contabilidad.MatrizConversionOperationsService>();
            services.AddScoped<IMatrizConversionService, MatrizConversionService>();
            services.AddScoped<IContaTipoDoctoPagoService, ContaTipoDoctoPagoService>();
            services.AddScoped<EG.Business.Interfaces.IMatrizIngresoOperations, EG.ApiCoreBS.Services.Contabilidad.MatrizIngresoOperationsService>();
            services.AddScoped<IMatrizIngresoService, MatrizIngresoService>();
            services.AddScoped<EG.Business.Interfaces.IConceptoOperations, EG.ApiCoreBS.Services.Contabilidad.ConceptoOperationsService>();
            services.AddScoped<IConceptoService, ConceptoService>();
            services.AddScoped<EG.Business.Interfaces.ICuentaContableOperations, EG.ApiCoreBS.Services.Contabilidad.CuentaContableOperationsService>();
            services.AddScoped<ICuentaContableService, CuentaContableService>();
            services.AddScoped<ITipoDetallePolizaService, TipoDetallePolizaService>();
            services.AddScoped<EG.Business.Interfaces.IPolizaOperations, EG.Business.Services.Contabilidad.PolizaOperationsService>();
            services.AddScoped<IPolizaService, PolizaService>();
            services.AddScoped<EG.Business.Interfaces.IPolizaDetalleOperations, EG.Business.Services.Contabilidad.PolizaDetalleOperationsService>();
            services.AddScoped<IPolizaDetalleService, PolizaDetalleService>();
            services.AddScoped<EG.Business.Interfaces.ICierreMensualOperations, EG.Business.Services.Contabilidad.CierreMensualOperationsService>();
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
            services.AddScoped<EG.Business.Interfaces.IAlmacenOperations, EG.Business.Services.Almacen.AlmacenOperationsService>();
            services.AddScoped<IAlmacenAppService, AlmacenAppService>();
            services.AddScoped<EG.Business.Interfaces.ISolicitudSalidaOperations, EG.Business.Services.Almacen.SolicitudSalidaOperationsService>();
            services.AddScoped<ISolicitudSalidaAppService, SolicitudSalidaAppService>();
            services.AddScoped<EG.Business.Interfaces.IDetalleSolicitudSalidaOperations, EG.Business.Services.Almacen.DetalleSolicitudSalidaOperationsService>();
            services.AddScoped<IDetalleSolicitudSalidaAppService, DetalleSolicitudSalidaAppService>();
            services.AddScoped<IEstatusSolicitudSalidaAppService, EstatusSolicitudSalidaAppService>();

            // Business services
            services.AddHttpContextAccessor();
            services.AddScoped<IUserRequestContext, HttpUserRequestContext>();
            services.AddScoped<IUserContextQueries, EG.Business.Services.Security.UserContextQueries>();
            services.AddScoped<IUserContextService, EG.Application.Services.Security.UserContextService>();
            services.AddScoped<EG.Business.Interfaces.IEmailOperations, EG.Business.Services.General.EmailOperationsService>();
            services.AddScoped<IEmailService, EmailService>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<INavigateService, NavigateService>();
            services.AddScoped<IUserIpService, UserIpService>();
            services.AddScoped<IUserProfileService, UserProfileService>();
            services.AddScoped<IEmployeeService, EmployeeService>();
            services.AddScoped<IBitacoraService, BitacoraService>();
            services.AddScoped<IBitacoraAppService, BitacoraAppService>();

            // Catalog services - Clave programa
            services.AddScoped<IGfService, GfService>();
            services.AddScoped<IFnService, FnService>();
            services.AddScoped<ISfService, SfService>();
            services.AddScoped<IFnAppService, FnAppService>();
            services.AddScoped<IGfAppService, GfAppService>();
            services.AddScoped<ISfAppService, SfAppService>();

            //// ===== SERVICIOS GENÉRICOS =====
            services.AddScoped(typeof(global::EG.Business.Services.PBR.PbrDashboardOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PBR.PbrAnteproyectoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PBR.PbrPresupuestoProgramaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PBR.PbrPartidaGastoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PBR.PbrMirNivelOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PBR.PbrIndicadorOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NominaRhExpedienteOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NominaRhContratoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NominaRhDependienteOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NominaRhIncidenciaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NominaRhPensionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NominaRhLookupOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Contratos.RegistroCompromisoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Contratos.SaldosContratoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Contratos.EstadoContratoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoModificado.EgreAdecuacionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoModificado.EgreAdecuacionDetalleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoModificado.EgresoDisponibleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoModificado.IngreAdecuacionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoModificado.IngreAdecuacionDetalleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoComprometido.AutorizacionSuficienciaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.PresupuestoComprometido.AutorizacionSuficienciaDetalleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.BancoInversionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.CuentaBancariaInversionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.IntermediarioFinancieroInversionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.InstrumentoInversionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.InversionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.InteresOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.RetiroOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.TipoPlazoInversionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.TipoRetiroInversionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomEmpresaNominaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomUniversoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomNivelOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomClasePuestoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomPuestoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomPlazaAutorizadaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomNombramientoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomImporteNivelOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomContratoLaboralOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoFactorOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoFijoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoPorcentajeOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoProporcionalOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoTabularOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomConceptoVariableOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomContratoTercerosOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomCreditoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomDescuentoCreditoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomDescuentoInfonavitOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomEstatusPagoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomFactorIntOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTablaFiscalOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomInfonavitOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomPeriodoActivoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomSalarioMinimoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomSueldoEspecialOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomSueldoLiqFinOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomSueldoMensualOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomSueldoQuincenalOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomSueldoSemanalOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTipoIncapacidadOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTipoPagoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTipoPensionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomCatalogoSimpleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomEstadoCivilOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomEscolaridadOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomDiaSemanaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomMedodoPagoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomParentescoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTipoContratacionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTipoIncidenciaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Nomina.NomTipoJustificacionOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.ContratoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.ContratoDetalleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.FacturaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.FacturaDetalleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.CLCOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.CLCDetalleOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.CLCFacturaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.ChequeOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.ChequePartidaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.CuentasXPagar.DepositoOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.General.UsuarioOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Patrimonio.BienDisponibleBajaOperationsService));
            services.AddScoped(typeof(global::EG.Business.Services.Contabilidad.TipoPolizaServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Catalogos.ClavePrograma.FnServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Catalogos.ClavePrograma.GfServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Catalogos.ClavePrograma.SfServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.TipoPatrimonioServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.TipoMonedaServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.TipoAdquisicionServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.MarcaServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.PersonaServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.PartidaServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.GrupoBienServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.AniosOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.FuenteFinanciamientoOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.ActividadInstitucionalOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.NivelServiceOperations));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.ProgramaPresupuestalOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.ProyectoOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.PgOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.RamoOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.TipoRecursoOperationsServices));
            services.AddScoped(typeof(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.SectorOperationsServices));
            services.AddScoped(typeof(GenericService<,,>)); // 3 parámetros: TEntity, TDto, TResponse
            services.AddScoped(typeof(GenericService<,>));  // 2 parámetros: TEntity, TDto
            AddReadOnlyCatalog<Ur, UrDto, UrResponse>(services, nameof(Ur.PkidUr));
            AddReadOnlyCatalog<TipoAdecuacion, TipoAdecuacionDto, TipoAdecuacionResponse>(services, nameof(TipoAdecuacion.PkidTipoAdecuacion));
            AddReadOnlyCatalog<EstatusAdecuacion, EstatusAdecuacionDto, EstatusAdecuacionResponse>(services, nameof(EstatusAdecuacion.PkidEstatusAdecuacion));
            AddReadOnlyCatalog<TipoMovimiento, TipoMovimientoDto, TipoMovimientoResponse>(services, nameof(TipoMovimiento.PkidTipoMovimiento));
            AddReadOnlyCatalog<VwIngresoDisponible, IngresoDisponibleDto, IngresoDisponibleResponse>(services, nameof(VwIngresoDisponible.PkidIngresoAutorizado));
            AddReadOnlyCatalog<VwIngreXejer, IngreXEjerDto, IngreXEjerResponse>(services, nameof(VwIngreXejer.PkIdIngresoAutorizado));
            AddReadOnlyCatalog<IngresoClcFacturaReadModel, IngresoCLCFacturaDto, IngresoCLCFacturaResponse>(services, nameof(IngresoClcFacturaReadModel.PkidClcfactura));
        }

        private static void AddReadOnlyCatalog<TEntity, TDto, TResponse>(IServiceCollection services, string idPropertyName)
            where TEntity : class
            where TDto : class
            where TResponse : class
        {
            services.AddScoped<IReadOnlyCatalogAppService<TResponse>>(provider =>
                new ReadOnlyCatalogAppService<TEntity, TDto, TResponse>(
                    provider.GetRequiredService<GenericService<TEntity, TDto, TResponse>>(), idPropertyName));
        }
    }
}

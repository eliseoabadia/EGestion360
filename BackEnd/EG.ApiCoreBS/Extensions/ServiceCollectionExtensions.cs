using EG.ApiCoreBS.Services;
using EG.ApiCoreBS.Services.Catalogos.ClavePrograma;
using EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen;
using EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria;
using EG.ApiCoreBS.Services.Contabilidad;
using EG.Application.Interfaces;
using EG.Application.Interfaces.Account;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.ClavePrograma;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Interfaces.Contabilidad;
using EG.Application.Interfaces.General;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Interfaces.Patrimonio;
using EG.Application.Services;
using EG.Application.Services.Account;
using EG.Application.Services.Adquisicion;
using EG.Application.Services.ConteoCiclico;
using EG.Application.Services.General;
using EG.Application.Services.Configuracion.Catalogo.ClavePrograma;
using EG.Application.Services.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Configuracion.Catalogo.Patrimonio;
using EG.Business.Interfaces;
using EG.Business.Services;
using EG.Common.Util;
using EG.Domain.Interfaces;
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
            services.AddScoped<IUserProfileAppService, UserProfileAppService>();
            services.AddScoped<IUsuarioAreaAppService, UsuarioAreaAppService>();

            // Application services - Adquisicion
            services.AddScoped<IPaaaAppService, PaaaAppService>();
            services.AddScoped<IArticuloAppService, ArticuloAppService>();
            services.AddScoped<IEstatusRequisicionAppService, EstatusRequisicionAppService>();
            services.AddScoped<IFraccionAppService, FraccionAppService>();
            services.AddScoped<IModalidadAppService, ModalidadAppService>();
            services.AddScoped<IProcedimientoContratacionAppService, ProcedimientoContratacionAppService>();
            services.AddScoped<IProveedorAppService, ProveedorAppService>();
            services.AddScoped<IRequisicionAppService, RequisicionAppService>();
            services.AddScoped<IRequisicionPartidaAppService, RequisicionPartidaAppService>();
            services.AddScoped<IDetalleRequisicionAppService, DetalleRequisicionAppService>();
            services.AddScoped<ITipoContratoAppService, TipoContratoAppService>();
            services.AddScoped<ITipoDocumentoAppService, TipoDocumentoAppService>();
            services.AddScoped<ITipoGarantiaAppService, TipoGarantiaAppService>();

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

            // Application services - Presupuestales
            services.AddScoped<IProgramaAppServices, ProgramaAppServices>();
            services.AddScoped<IActividadInstitucionalAppServices, ActividadInstitucionalAppServices>();
            services.AddScoped<IAniosAppServices, AniosAppServices>();
            services.AddScoped<IFuenteFinanciamientoAppServices, FuenteFinanciamientoAppServices>();
            services.AddScoped<IPgAppServices, PgAppServices>();
            services.AddScoped<IProgramaPresupuestalAppServices, ProgramaPresupuestalAppServices>();
            services.AddScoped<IProyectoAppServices, ProyectoAppServices>();
            services.AddScoped<IRamoAppServices, RamoAppServices>();
            services.AddScoped<ISectorAppServices, SectorAppServices>();
            services.AddScoped<ITipoRecursoAppServices, TipoRecursoAppServices>();
            services.AddScoped<IUnidadResponsableAppServices, UnidadResponsableAppServices>();

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

            // Application services - Tesoreria
            services.AddScoped<ITipoCambioService, TipoCambioService>();
            services.AddScoped<ITipoDoctoClcService, TipoDoctoClcService>();
            services.AddScoped<ITipoInversionService, TipoInversionService>();
            services.AddScoped<ITipoMonedaService, TipoMonedaService>();
            services.AddScoped<ITipoPagoService, TipoPagoService>();
            services.AddScoped<ITipoPagoSFService, TipoPagoSFService>();
            services.AddScoped<ITipoSolicitudCLCService, TipoSolicitudCLCService>();

            // Application services - Almacen
            services.AddScoped<IEstatusSolService, EstatusSolService>();
            services.AddScoped<IMotivoEsService, MotivoEsService>();
            services.AddScoped<IUnidadesService, UnidadesService>();

            // Business services
            services.AddHttpContextAccessor();
            services.AddScoped<IUserContextService, UserContextService>();
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

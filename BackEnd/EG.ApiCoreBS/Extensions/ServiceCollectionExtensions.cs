using EG.ApiCoreBS.Services;
using EG.ApiCoreBS.Services.Catalogos.ClavePrograma;
using EG.ApiCoreBS.Services.Contabilidad;
using EG.Application.Interfaces;
using EG.Application.Interfaces.Account;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Application.Interfaces.Contabilidad;
using EG.Application.Interfaces.General;
using EG.Application.Services;
using EG.Application.Services.Account;
using EG.Application.Services.ConteoCiclico;
using EG.Application.Services.General;
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

            // Application services - Conteo ciclico
            services.AddScoped<IConteoAppService, ConteoAppService>();
            services.AddScoped<IPeriodoConteoAppService, PeriodoConteoAppService>();

            // Business services
            services.AddHttpContextAccessor();
            services.AddScoped<IUserContextService, UserContextService>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<INavigateService, NavigateService>();
            services.AddScoped<IUserIpService, UserIpService>();
            services.AddScoped<IUserProfileService, UserProfileService>();
            services.AddScoped<IEmployeeService, EmployeeService>();

            // Catalog services - Contabilidad
            services.AddScoped<ITipoPolizaService, TipoPolizaService>();
            services.AddScoped<IMatrizConversionService, MatrizConversionService>();

            // Catalog services - Clave programa
            services.AddScoped<IGfService, GfService>();
            services.AddScoped<IFnService, FnService>();
            services.AddScoped<ISfService, SfService>();

            // Generic service
            services.AddScoped(typeof(GenericService<,,>));
        }
    }
}

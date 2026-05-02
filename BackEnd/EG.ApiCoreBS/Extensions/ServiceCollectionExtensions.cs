using EG.ApiCoreBS.Services;
using EG.Application.Interfaces;
using EG.Application.Interfaces.Account;
using EG.Application.Interfaces.General;
using EG.Application.Services;
using EG.Application.Services.Account;
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


            // ===== REPOSITORIES (IRepositorySP) =====
            services.AddScoped<IRepositorySP<LoginInformationEmployeeResult>, RepositorySP<LoginInformationEmployeeResult>>();
            services.AddScoped<IRepositorySP<spGetClaimsByUserResult>, RepositorySP<spGetClaimsByUserResult>>();  // ✅ AGREGADO
            services.AddScoped<IRepositorySP<spEliminarUsuarioSucursalResult>, RepositorySP<spEliminarUsuarioSucursalResult>>();
            services.AddScoped<IRepositorySP<spNodeMenuResult>, RepositorySP<spNodeMenuResult>>();
            //services.AddScoped<IRepositorySP<sp_RegistrarConteoResult>, RepositorySP<sp_RegistrarConteoResult>>();
            services.AddScoped<IRepository<PerfilUsuario>, Repository<PerfilUsuario>>();

            // ===== SERVICIOS DE APLICACIÓN - ACCOUNT =====
            services.AddScoped<IAuthAppService, AuthAppService>();
            services.AddScoped<INavigateAppService, NavigateAppService>();

            // ===== SERVICIOS DE APLICACIÓN - GENERAL =====
            services.AddScoped<IEmpresaAppService, EmpresaAppService>();
            services.AddScoped<IDepartamentoAppService, DepartamentoAppService>();
            services.AddScoped<IUsuarioSucursalAppService, UsuarioSucursalAppService>();

// ===== SERVICIOS DE APLICACIÓN - CONTEO CÍCLICO =====
//services.AddScoped<IArticuloConteoAppService, ArticuloConteoAppService>();
//services.AddScoped<IConteoCiclicoService, ConteoCiclicoService>();
//services.AddScoped<IPeriodoConteoAppService, PeriodoConteoAppService>();
//services.AddScoped<IRegistroConteoAppService, RegistroConteoAppService>();
//services.AddScoped<IRegistroConteoAppService, RegistroConteoAppService>();
//services.AddScoped<ITipoConteoAppService, TipoConteoAppService>();
//services.AddScoped<IBienAppService, BienAppService>();



            // ===== SERVICIOS GENERALES =====
            services.AddHttpContextAccessor();
            services.AddScoped<IUserContextService, UserContextService>();
            services.AddScoped<IUsuarioAppService, UsuarioAppService>();
            services.AddScoped<IAspNetRolesAppService, AspNetRolesAppService>();

// ===== SERVICIOS DE NEGOCIO =====
services.AddScoped<IAuthService, AuthService>();
services.AddScoped<ITokenService, TokenService>();
services.AddScoped<INavigateService, NavigateService>();
            services.AddScoped<IUserIpService, UserIpService>();
            services.AddScoped<IUserProfileService, UserProfileService>();
            services.AddScoped<IEmployeeService, EmployeeService>();

            // ===== SERVICIOS GENÉRICOS =====
            services.AddScoped(typeof(GenericService<,,>));
            services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
        }
    }
}




using EG.Common.Helper;
using EG.Web.Contracs;
using EG.Web.Models.Configuration;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Services;
using Microsoft.JSInterop;

namespace EG.Web.Extensions;

public static class ApiServiceExtensions
{
    public static IServiceCollection AddApiServices(this IServiceCollection services)
    {
        // Registro de dependencias base necesarias
        // services.AddHttpClient(); 

        // Registro de los CRUDs específicos
        RegisterCrud<DepartamentoResponse>(services, "api/Departamento");
        RegisterCrud<UsuarioResponse>(services, "api/Usuario");
        RegisterCrud<EmpresaResponse>(services, "api/Empresa");
        RegisterCrud<MenuItemsResponse>(services, "api/Menu");
        RegisterCrud<UsuarioSucursalResponse>(services, "api/UsuarioSucursal");
        RegisterCrud<SucursalResponse>(services, "api/Sucursal");

        RegisterCrud<ArticuloConteoResponse>(services, "api/ArticuloConteo");
        RegisterCrud<EstatusPeriodoResponse>(services, "api/EstatusPeriodo");
        RegisterCrud<EstatusArticuloConteoResponse>(services, "api/EstatusArticuloConteo");
        RegisterCrud<PeriodoConteoResponse>(services, "api/PeriodoConteo");
        RegisterCrud<TipoConteoResponse>(services, "api/TipoConteo");
        // Agrega más aquí...

        return services;
    }

    private static void RegisterCrud<TResponse>(IServiceCollection services, string endpoint)
        where TResponse : class
    {
        services.AddScoped<IGenericCrudService<TResponse>>(sp =>
            new GenericCrudService<TResponse>(
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                endpoint
            ));
    }
}

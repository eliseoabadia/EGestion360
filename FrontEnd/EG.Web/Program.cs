using EG.Common.Helper;
using EG.Web;
using EG.Web.Auth;
using EG.Web.Contracts;
using EG.Web.Contracts.Configuration;
using EG.Web.Extensions;
using EG.Web.Services;
using EG.Web.Services.Configuration;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses.Contabilidad;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.JSInterop;
using MudBlazor;
using MudBlazor.Services;

internal class Program
{
    private static async Task Main(string[] args)
    {
        var builder = WebAssemblyHostBuilder.CreateDefault(args);
        builder.RootComponents.Add<App>("#app");
        builder.RootComponents.Add<HeadOutlet>("head::after");

        // Configurar MudBlazor con localizaci�n y Snackbar
        builder.Services.AddMudServices(config =>
        {
            config.SnackbarConfiguration.PositionClass = Defaults.Classes.Position.BottomRight;
            config.SnackbarConfiguration.PreventDuplicates = false;
            config.SnackbarConfiguration.NewestOnTop = false;
            config.SnackbarConfiguration.ShowCloseIcon = true;
            config.SnackbarConfiguration.VisibleStateDuration = 5000;
            config.SnackbarConfiguration.HideTransitionDuration = 500;
            config.SnackbarConfiguration.ShowTransitionDuration = 500;
            config.SnackbarConfiguration.SnackbarVariant = Variant.Filled;
        });

        builder.Services.AddLocalization();

        // Registrar HttpClient PRIMERO para que pueda ser resuelto por otros servicios
        // BaseAddress apunta al backend API en puerto 5163 (HTTP - mejor compatibilidad con Blazor WASM en desarrollo)
        builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("https://localhost:7210/") });
        builder.Services.AddHttpClient("ApiClient", client =>
        {
            client.BaseAddress = new Uri("https://localhost:7210/");
            client.DefaultRequestHeaders.Add("Accept", "application/json");
        });

        builder.Services.AddSingleton<ApplicationInstance>();

        builder.Services.AddAuthorizationCore();

        // Registrar servicios por interfaz
        builder.Services.AddScoped<ILoginService, LoginService>();
        builder.Services.AddScoped<INavigateService, NavigateService>();
        builder.Services.AddScoped<IEstadoService, EstadoService>();
        builder.Services.AddScoped<IEmpresaService, EmpresaService>();
        builder.Services.AddScoped<EmpresaService>();
        builder.Services.AddScoped<IProfileService>(sp => sp.GetRequiredService<ProfileService>());
        builder.Services.AddScoped<ProfileService>();
        builder.Services.AddScoped<IDepartamentoService>(sp => sp.GetRequiredService<DepartamentoService>());
        builder.Services.AddScoped<DepartamentoService>();
        builder.Services.AddScoped<IRequestService, RequestService>();
        builder.Services.AddScoped<ISucursalService, SucursalService>(); 
        builder.Services.AddScoped<IUsuarioService, UsuarioService>();
        
        // Registrar servicios para los catálogos presupuestales
        builder.Services.AddScoped<IGenericCrudService<UnidadResponsableResponse>>(sp =>
            new GenericCrudService<UnidadResponsableResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/UnidadResponsable"));
        builder.Services.AddScoped<IGenericCrudService<FuncionResponse>>(sp =>
            new GenericCrudService<FuncionResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Funcion"));
        builder.Services.AddScoped<IGenericCrudService<SubFuncionResponse>>(sp =>
            new GenericCrudService<SubFuncionResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/SubFuncion"));
        builder.Services.AddScoped<IGenericCrudService<ActividadInstitucionalResponse>>(sp =>
            new GenericCrudService<ActividadInstitucionalResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/ActividadInstitucional"));
        builder.Services.AddScoped<IGenericCrudService<ProgramaPresupuestalResponse>>(sp =>
            new GenericCrudService<ProgramaPresupuestalResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/ProgramaPresupuestal"));
        builder.Services.AddScoped<IGenericCrudService<AniosResponse>>(sp =>
            new GenericCrudService<AniosResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Anios"));
        builder.Services.AddScoped<IGenericCrudService<SectorResponse>>(sp =>
            new GenericCrudService<SectorResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Sector"));
        builder.Services.AddScoped<IGenericCrudService<TipoRecursoResponse>>(sp =>
            new GenericCrudService<TipoRecursoResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/TipoRecurso"));
        builder.Services.AddScoped<IGenericCrudService<FuenteFinanciamientoResponse>>(sp =>
            new GenericCrudService<FuenteFinanciamientoResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/FuenteFinanciamiento"));
        builder.Services.AddScoped<IGenericCrudService<PgResponse>>(sp =>
            new GenericCrudService<PgResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Pg"));
        builder.Services.AddScoped<IGenericCrudService<RamoResponse>>(sp =>
            new GenericCrudService<RamoResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Ramo"));
        builder.Services.AddScoped<IGenericCrudService<ProyectoResponse>>(sp =>
            new GenericCrudService<ProyectoResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Proyecto"));
        
        // Registrar servicios para los catálogos de Contabilidad
        builder.Services.AddScoped<IGenericCrudService<TipoPolizaResponse>>(sp =>
            new GenericCrudService<TipoPolizaResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/TipoPoliza"));
        builder.Services.AddScoped<IGenericCrudService<TipoDetallePolizaResponse>>(sp =>
            new GenericCrudService<TipoDetallePolizaResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/TipoDetallePoliza"));
        builder.Services.AddScoped<IGenericCrudService<MatrizConversionResponse>>(sp =>
            new GenericCrudService<MatrizConversionResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/MatrizConversion"));
        builder.Services.AddScoped<IGenericCrudService<MatrizIngresoResponse>>(sp =>
            new GenericCrudService<MatrizIngresoResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/MatrizIngreso"));
        builder.Services.AddScoped<IGenericCrudService<ConceptoResponse>>(sp =>
            new GenericCrudService<ConceptoResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/Concepto"));
        builder.Services.AddScoped<IGenericCrudService<CuentaContableResponse>>(sp =>
            new GenericCrudService<CuentaContableResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                "api/CuentaContable"));
        
        //builder.Services.AddScoped<IPeriodoConteoService, PeriodoConteoService>();

        //builder.Services.AddScoped<IConteoCiclicoService, ConteoCiclicoService>();
        //builder.Services.AddScoped<IPeriodoConteoService, PeriodoConteoService>();
        //builder.Services.AddScoped<IArticuloConteoService, ArticuloConteoService>();
      

        // En Program.cs o Startup.cs
        builder.Services.AddScoped<MenuStateService>();
        builder.Services.AddScoped<SucursalStateService>();

        // Registrar servicios por interfaz (a�adir donde est�n los otros builder.Services.AddScoped...)
        //builder.Services.AddScoped<ProfileService>();
        //builder.Services.AddScoped<IConfigurationService, ConfigurationService>();
        // Program.cs
        builder.Services.AddApiServices();

        // Authentication provider y dependencias
        builder.Services.AddScoped<AuthenticationStateProvider, AuthenticationProviderJWT>(sp => sp.GetRequiredService<AuthenticationProviderJWT>());
        builder.Services.AddScoped<AuthenticationProviderJWT>();
        builder.Services.AddScoped<AuthService>();

        await builder.Build().RunAsync();
    }
}
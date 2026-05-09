using EG.Common.Helper;
using EG.Web;
using EG.Web.Auth;
using EG.Web.Contracts;
using EG.Web.Contracts.Configuration;
using EG.Web.Extensions;
using EG.Web.Services;
using EG.Web.Services.Configuration;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.Presupuestales;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.JSInterop;
using MudBlazor;
using MudBlazor.Services;
using EG.Domain.DTOs.Responses.Presupuestales;

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

        builder.Services.AddScoped<IUsuarioService, UsuarioService>();
        builder.Services.AddScoped<IProfileService>(sp => sp.GetRequiredService<ProfileService>());
        builder.Services.AddScoped<ProfileService>();

        builder.Services.AddScoped<IRequestService, RequestService>();
        
        // En Program.cs o Startup.cs
        builder.Services.AddScoped<MenuStateService>();
        builder.Services.AddScoped<SucursalStateService>();
        builder.Services.AddScoped<DashboardService>();

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
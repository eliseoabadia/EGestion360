using EG.Common.Helper;
using EG.Web;
using EG.Web.Auth;
using EG.Web.Contracts;
using EG.Web.Contracts.Configuration;
using EG.Web.Extensions;
using EG.Web.Localization;
using EG.Web.Services;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
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
            config.SnackbarConfiguration.PreventDuplicates = true;
            config.SnackbarConfiguration.NewestOnTop = true;
            config.SnackbarConfiguration.ShowCloseIcon = true;
            config.SnackbarConfiguration.VisibleStateDuration = 6500;
            config.SnackbarConfiguration.HideTransitionDuration = 350;
            config.SnackbarConfiguration.ShowTransitionDuration = 350;
            config.SnackbarConfiguration.SnackbarVariant = Variant.Filled;
        });
        builder.Services.AddLocalizationInterceptor<PassthroughMudLocalizationInterceptor>();
        builder.Services.AddLocalizationEnumInterceptor<PassthroughMudLocalizationInterceptor>();

        // Registrar HttpClient PRIMERO para que pueda ser resuelto por otros servicios
        var apiBaseUrl = builder.Configuration["ApiSetting:baseUrl"];
        if (string.IsNullOrWhiteSpace(apiBaseUrl))
        {
            throw new InvalidOperationException("La configuracion 'ApiSetting:baseUrl' es requerida en appsettings.json.");
        }

        var apiBaseAddress = Uri.TryCreate(apiBaseUrl, UriKind.Absolute, out var absoluteApiBaseAddress)
            ? absoluteApiBaseAddress
            : new Uri(new Uri(builder.HostEnvironment.BaseAddress), apiBaseUrl);

        builder.Services.AddScoped(sp => new HttpClient { BaseAddress = apiBaseAddress });
        builder.Services.AddHttpClient("ApiClient", client =>
        {
            client.BaseAddress = apiBaseAddress;
            client.DefaultRequestHeaders.Add("Accept", "application/json");
        });

        builder.Services.AddSingleton<ApplicationInstance>();

        builder.Services.AddAuthorizationCore();

        // Registrar servicios por interfaz
        builder.Services.AddScoped<ILoginService, LoginService>();
        builder.Services.AddScoped<INavigateService, NavigateService>();
        builder.Services.AddScoped<ProfileService>();

        builder.Services.AddScoped<IRequestService, RequestService>();
        
        // En Program.cs o Startup.cs
        builder.Services.AddScoped<MenuStateService>();
        builder.Services.AddScoped<SucursalStateService>();
        builder.Services.AddScoped<AnioPresupuestalStateService>();
        builder.Services.AddScoped<ThemeStateService>();
        builder.Services.AddScoped<DashboardService>();

        builder.Services.AddApiServices();

        // Authentication provider y dependencias
        builder.Services.AddScoped<AuthenticationStateProvider, AuthenticationProviderJWT>(sp => sp.GetRequiredService<AuthenticationProviderJWT>());
        builder.Services.AddScoped<AuthenticationProviderJWT>();
        builder.Services.AddScoped<AuthService>();

        await builder.Build().RunAsync();
    }
}

using EG.Common.Helper;
using EG.Web;
using EG.Web.Auth;
using EG.Web.Contracs;
using EG.Web.Contracs.Configuration;
using EG.Web.Services;
using EG.Web.Services.Configuration;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using MudBlazor;
using MudBlazor.Services;
using System.Net.Http;

internal class Program
{
    private static async Task Main(string[] args)
    {
        var builder = WebAssemblyHostBuilder.CreateDefault(args);
        builder.RootComponents.Add<App>("#app");
        builder.RootComponents.Add<HeadOutlet>("head::after");

        // Configurar MudBlazor con localización y Snackbar
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
        builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("https://localhost:44319/") });

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

        // Registrar servicios por interfaz (añadir donde están los otros builder.Services.AddScoped...)
        //builder.Services.AddScoped<ProfileService>();
        builder.Services.AddScoped<IConfigurationService, ConfigurationService>();


        // Authentication provider y dependencias
        builder.Services.AddScoped<AuthenticationProviderJWT>();
        builder.Services.AddScoped<AuthenticationStateProvider, AuthenticationProviderJWT>(sp => sp.GetRequiredService<AuthenticationProviderJWT>());
        builder.Services.AddScoped<AuthService>();

        await builder.Build().RunAsync();
    }
}
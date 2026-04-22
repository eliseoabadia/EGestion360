using BlazorAppEG;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

using MudBlazor.Services;
using BlazorAppEG.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddMudServices();

// Usar el puerto del perfil https de EG.ApiCore
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("https://localhost:6001/") });
builder.Services.AddScoped<LoginService>();

await builder.Build().RunAsync();

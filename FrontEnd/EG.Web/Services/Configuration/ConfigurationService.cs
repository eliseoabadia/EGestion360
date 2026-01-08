// ConfigurationService.cs
using EG.Web.Contracs.Configuration;
using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services.Configuration
{
    public class ConfigurationService : IConfigurationService
    {
        private readonly IJSRuntime _jsRuntime;
        private Dictionary<string, object> _configCache = new();

        public ConfigurationService(IJSRuntime jsRuntime)
        {
            _jsRuntime = jsRuntime;
        }

        public async Task<T> GetAsync<T>(string key, T defaultValue = default)
        {
            try
            {
                // Intenta obtener desde localStorage (si guardaste la configuración allí)
                var json = await _jsRuntime.InvokeAsync<string>(
                    "localStorage.getItem",
                    $"config_{key}");

                if (!string.IsNullOrEmpty(json))
                {
                    return JsonSerializer.Deserialize<T>(json);
                }

                // O usa valores compilados
                return GetCompiledValue(key, defaultValue);
            }
            catch
            {
                return defaultValue;
            }
        }

        private T GetCompiledValue<T>(string key, T defaultValue)
        {
            // Valores compilados en tiempo de build
            var compiledConfig = new Dictionary<string, object>
            {
                ["ApiBaseUrl"] = "https://tu-api.com",
                // Agrega más valores según necesites
            };

            if (compiledConfig.TryGetValue(key, out var value) && value is T typedValue)
            {
                return typedValue;
            }

            return defaultValue;
        }

        public async Task<string> GetBaseUrlAsync()
        {
            // Para WASM, puedes usar NavigationManager.BaseUri
            // O obtenerlo desde configuración
            var baseUrl = await GetAsync<string>("ApiBaseUrl");
            return baseUrl ?? "https://localhost:5001";
        }
    }
}

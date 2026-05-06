using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services
{
    public class SucursalStateService
    {
        private readonly IJSRuntime _jsRuntime;
        private const string SUCURSAL_KEY = "sucursal_seleccionada";
        
        public event Action<int, string>? OnSucursalChanged;

        public int? SucursalId { get; private set; }
        public string? SucursalNombre { get; private set; }

        public SucursalStateService(IJSRuntime jsRuntime)
        {
            _jsRuntime = jsRuntime;
        }

        public async Task InitializeAsync()
        {
            try
            {
                var sucursalJson = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", SUCURSAL_KEY);
                if (!string.IsNullOrEmpty(sucursalJson))
                {
                    var sucursal = JsonSerializer.Deserialize<SucursalSeleccionada>(sucursalJson);
                    if (sucursal != null)
                    {
                        SucursalId = sucursal.Id;
                        SucursalNombre = sucursal.Nombre;
                    }
                }
            }
            catch
            {
                // Si hay error, no hay sucursal seleccionada
            }
        }

        public async Task SetSucursalAsync(int sucursalId, string sucursalNombre)
        {
            SucursalId = sucursalId;
            SucursalNombre = sucursalNombre;

            var sucursal = new SucursalSeleccionada
            {
                Id = sucursalId,
                Nombre = sucursalNombre
            };

            await _jsRuntime.InvokeVoidAsync("localStorage.setItem", SUCURSAL_KEY, JsonSerializer.Serialize(sucursal));
            OnSucursalChanged?.Invoke(sucursalId, sucursalNombre);
        }

        public async Task ClearSucursalAsync()
        {
            SucursalId = null;
            SucursalNombre = null;
            await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", SUCURSAL_KEY);
            OnSucursalChanged?.Invoke(0, string.Empty);
        }

        public bool HasSucursalSeleccionada => SucursalId.HasValue && SucursalId > 0;

        private class SucursalSeleccionada
        {
            public int Id { get; set; }
            public string Nombre { get; set; } = string.Empty;
        }
    }
}

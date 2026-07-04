using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services
{
    public class SucursalStateService
    {
        private readonly IJSRuntime _jsRuntime;
        private const string SUCURSAL_KEY = "sucursal_seleccionada";
        private const string EMPRESA_KEY = "empresa_seleccionada";

        public event Action<int, string>? OnSucursalChanged;
        public event Action<int>? OnEmpresaChanged;

        public int? SucursalId { get; private set; }
        public string? SucursalNombre { get; private set; }
        public int? EmpresaId { get; private set; }
        public string? EmpresaNombre { get; private set; }
        public string? EmpresaNombreCorto { get; private set; }

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
                        EmpresaId = sucursal.EmpresaId;
                        EmpresaNombre = sucursal.EmpresaNombre;
                        EmpresaNombreCorto = sucursal.EmpresaNombreCorto;
                    }
                }
            }
            catch
            {
                // Si hay error, no hay sucursal seleccionada
            }
        }

        public async Task SetSucursalAsync(
            int sucursalId,
            string sucursalNombre,
            int? empresaId = null,
            string? empresaNombre = null,
            string? empresaNombreCorto = null)
        {
            SucursalId = sucursalId;
            SucursalNombre = sucursalNombre;
            EmpresaId = empresaId;
            EmpresaNombre = empresaNombre;
            EmpresaNombreCorto = empresaNombreCorto;

            var sucursal = new SucursalSeleccionada
            {
                Id = sucursalId,
                Nombre = sucursalNombre,
                EmpresaId = empresaId ?? 0,
                EmpresaNombre = empresaNombre ?? string.Empty,
                EmpresaNombreCorto = empresaNombreCorto ?? string.Empty
            };

            await _jsRuntime.InvokeVoidAsync("localStorage.setItem", SUCURSAL_KEY, JsonSerializer.Serialize(sucursal));
            
            if (empresaId.HasValue)
            {
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", EMPRESA_KEY, empresaId.Value.ToString());
                OnEmpresaChanged?.Invoke(empresaId.Value);
            }
            
            OnSucursalChanged?.Invoke(sucursalId, sucursalNombre);
        }

        public async Task SetEmpresaInfoAsync(
            int empresaId,
            string? empresaNombre,
            string? empresaNombreCorto,
            bool notify = true)
        {
            EmpresaId = empresaId > 0 ? empresaId : EmpresaId;
            EmpresaNombre = string.IsNullOrWhiteSpace(empresaNombre)
                ? EmpresaNombre
                : empresaNombre.Trim();
            EmpresaNombreCorto = string.IsNullOrWhiteSpace(empresaNombreCorto)
                ? EmpresaNombreCorto
                : empresaNombreCorto.Trim();

            if (EmpresaId.HasValue)
            {
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", EMPRESA_KEY, EmpresaId.Value.ToString());
            }

            if (SucursalId.HasValue)
            {
                var sucursal = new SucursalSeleccionada
                {
                    Id = SucursalId.Value,
                    Nombre = SucursalNombre ?? string.Empty,
                    EmpresaId = EmpresaId ?? 0,
                    EmpresaNombre = EmpresaNombre ?? string.Empty,
                    EmpresaNombreCorto = EmpresaNombreCorto ?? string.Empty
                };

                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", SUCURSAL_KEY, JsonSerializer.Serialize(sucursal));
            }

            if (notify && EmpresaId.HasValue)
            {
                OnEmpresaChanged?.Invoke(EmpresaId.Value);
            }
        }

        public async Task ClearSucursalAsync()
        {
            SucursalId = null;
            SucursalNombre = null;
            EmpresaId = null;
            EmpresaNombre = null;
            EmpresaNombreCorto = null;
            await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", SUCURSAL_KEY);
            await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", EMPRESA_KEY);
            OnSucursalChanged?.Invoke(0, string.Empty);
            OnEmpresaChanged?.Invoke(0);
        }

        public bool HasSucursalSeleccionada => SucursalId.HasValue && SucursalId > 0;

        public async Task<int?> GetEmpresaIdAsync()
        {
            try
            {
                var empresaIdStr = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", EMPRESA_KEY);
                if (!string.IsNullOrEmpty(empresaIdStr) && int.TryParse(empresaIdStr, out int empresaId))
                {
                    return empresaId;
                }
            }
            catch { }
            return null;
        }

        private class SucursalSeleccionada
        {
            public int Id { get; set; }
            public string Nombre { get; set; } = string.Empty;
            public int EmpresaId { get; set; }
            public string EmpresaNombre { get; set; } = string.Empty;
            public string EmpresaNombreCorto { get; set; } = string.Empty;
        }
    }
}

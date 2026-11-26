using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services
{
    public class SucursalStateService
    {
        private readonly IJSRuntime _jsRuntime;
        private readonly HttpClient _httpClient;
        private readonly ILogger<SucursalStateService> _logger;
        private const string SUCURSAL_KEY = "sucursal_seleccionada";
        private const string EMPRESA_KEY = "empresa_seleccionada";
        private const string EMPRESA_HEADER = "X-Empresa-Id";
        private int selectionVersion;
        private bool initialized;
        private readonly SemaphoreSlim storageGate = new(1, 1);

        public event Action<int, string>? OnSucursalChanged;
        public event Action<int>? OnEmpresaChanged;

        public int? SucursalId { get; private set; }
        public string? SucursalNombre { get; private set; }
        public int? EmpresaId { get; private set; }
        public string? EmpresaNombre { get; private set; }
        public string? EmpresaNombreCorto { get; private set; }

        public SucursalStateService(
            IJSRuntime jsRuntime,
            HttpClient httpClient,
            ILogger<SucursalStateService> logger)
        {
            _jsRuntime = jsRuntime;
            _httpClient = httpClient;
            _logger = logger;
        }

        public async Task InitializeAsync()
        {
            var version = selectionVersion;
            await storageGate.WaitAsync();
            try
            {
                if (version != selectionVersion) return;
                var sucursalJson = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", SUCURSAL_KEY);
                if (version != selectionVersion) return;
                initialized = true;
                ResetSelection();
                if (!string.IsNullOrWhiteSpace(sucursalJson))
                {
                    var sucursal = JsonSerializer.Deserialize<SucursalSeleccionada>(sucursalJson);
                    if (sucursal != null && sucursal.Id > 0 && sucursal.EmpresaId > 0)
                    {
                        SucursalId = sucursal.Id;
                        SucursalNombre = sucursal.Nombre;
                        EmpresaId = sucursal.EmpresaId;
                        EmpresaNombre = sucursal.EmpresaNombre;
                        EmpresaNombreCorto = sucursal.EmpresaNombreCorto;
                        ApplyEmpresaHeader();
                    }
                }
            }
            catch (Exception ex)
            {
                if (version != selectionVersion) return;
                initialized = true;
                ResetSelection();
                _logger.LogWarning(ex, "No se pudo restaurar la sucursal seleccionada.");
            }
            finally
            {
                storageGate.Release();
            }
        }

        public async Task SetSucursalAsync(
            int sucursalId,
            string sucursalNombre,
            int? empresaId = null,
            string? empresaNombre = null,
            string? empresaNombreCorto = null)
        {
            var version = ++selectionVersion;
            initialized = true;
            SucursalId = sucursalId;
            SucursalNombre = sucursalNombre;
            EmpresaId = empresaId > 0 ? empresaId : null;
            EmpresaNombre = empresaNombre;
            EmpresaNombreCorto = empresaNombreCorto;
            ApplyEmpresaHeader();

            var sucursal = new SucursalSeleccionada
            {
                Id = sucursalId,
                Nombre = sucursalNombre,
                EmpresaId = empresaId ?? 0,
                EmpresaNombre = empresaNombre ?? string.Empty,
                EmpresaNombreCorto = empresaNombreCorto ?? string.Empty
            };

            try
            {
                await PersistSelectionAsync(version, sucursal);
                if (version != selectionVersion) return;

                if (EmpresaId.HasValue)
                {
                    ApplyEmpresaHeader();
                    OnEmpresaChanged?.Invoke(empresaId.Value);
                }
                else
                {
                    OnEmpresaChanged?.Invoke(0);
                }

                OnSucursalChanged?.Invoke(sucursalId, sucursalNombre);
            }
            catch
            {
                if (version == selectionVersion)
                {
                    ResetSelection();
                    OnSucursalChanged?.Invoke(0, string.Empty);
                    OnEmpresaChanged?.Invoke(0);
                }
                throw;
            }
        }

        public async Task SetEmpresaInfoAsync(
            int empresaId,
            string? empresaNombre,
            string? empresaNombreCorto,
            bool notify = true)
        {
            // Updating descriptive information must never switch the active company.
            // Responses can arrive after another branch was selected or the session was cleared.
            if (empresaId <= 0 || EmpresaId != empresaId)
            {
                return;
            }
            var version = ++selectionVersion;
            EmpresaNombre = string.IsNullOrWhiteSpace(empresaNombre)
                ? EmpresaNombre
                : empresaNombre.Trim();
            EmpresaNombreCorto = string.IsNullOrWhiteSpace(empresaNombreCorto)
                ? EmpresaNombreCorto
                : empresaNombreCorto.Trim();

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

                await PersistSelectionAsync(version, sucursal);
            }

            if (version != selectionVersion) return;
            if (notify && EmpresaId.HasValue)
            {
                OnEmpresaChanged?.Invoke(EmpresaId.Value);
            }
        }

        public async Task ClearSucursalAsync()
        {
            var version = ++selectionVersion;
            initialized = true;
            ResetSelection();
            try
            {
                await PersistSelectionAsync(version, null);
            }
            finally
            {
                if (version == selectionVersion)
                {
                    OnSucursalChanged?.Invoke(0, string.Empty);
                    OnEmpresaChanged?.Invoke(0);
                }
            }
        }

        private async Task PersistSelectionAsync(int version, SucursalSeleccionada? selection)
        {
            await storageGate.WaitAsync();
            try
            {
                if (version != selectionVersion) return;
                if (selection == null)
                {
                    await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", SUCURSAL_KEY);
                    await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", EMPRESA_KEY);
                    return;
                }

                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", SUCURSAL_KEY, JsonSerializer.Serialize(selection));
                if (selection.EmpresaId > 0)
                    await _jsRuntime.InvokeVoidAsync("localStorage.setItem", EMPRESA_KEY, selection.EmpresaId.ToString());
                else
                    await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", EMPRESA_KEY);
            }
            finally
            {
                storageGate.Release();
            }
        }

        private void ResetSelection()
        {
            SucursalId = null;
            SucursalNombre = null;
            EmpresaId = null;
            EmpresaNombre = null;
            EmpresaNombreCorto = null;
            ApplyEmpresaHeader();
        }

        public bool HasSucursalSeleccionada => SucursalId.HasValue && SucursalId > 0;

        public async Task<int?> GetEmpresaIdAsync()
        {
            if (!initialized) await InitializeAsync();
            return EmpresaId;
        }

        private void ApplyEmpresaHeader()
        {
            _httpClient.DefaultRequestHeaders.Remove(EMPRESA_HEADER);

            if (EmpresaId.HasValue && EmpresaId.Value > 0)
            {
                _httpClient.DefaultRequestHeaders.Add(EMPRESA_HEADER, EmpresaId.Value.ToString());
            }
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

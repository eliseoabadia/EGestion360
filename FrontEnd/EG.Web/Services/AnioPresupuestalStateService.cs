using EG.Common.GenericModel;
using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services
{
    public class AnioPresupuestalStateService
    {
        private const string ANIO_KEY = "anio_presupuestal_seleccionado";
        private readonly IJSRuntime _jsRuntime;
        private readonly SemaphoreSlim storageGate = new(1, 1);
        private int selectionVersion;

        public event Action<int?>? OnAnioChanged;

        public int? AnioId { get; private set; }
        public int? AnioClave { get; private set; }
        public string AnioDescripcion { get; private set; } = string.Empty;
        public string AnioTexto => AnioClave.HasValue
            ? string.IsNullOrWhiteSpace(AnioDescripcion)
                ? AnioClave.Value.ToString()
                : $"{AnioClave} - {AnioDescripcion}"
            : string.Empty;

        public AnioPresupuestalStateService(IJSRuntime jsRuntime)
        {
            _jsRuntime = jsRuntime;
        }

        public async Task InitializeAsync()
        {
            var version = selectionVersion;
            await storageGate.WaitAsync();
            try
            {
                if (version != selectionVersion) return;
                var anioJson = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", ANIO_KEY);
                if (version != selectionVersion) return;
                if (string.IsNullOrWhiteSpace(anioJson))
                {
                    ResetSelection();
                    return;
                }

                var anio = JsonSerializer.Deserialize<AnioPresupuestalSeleccionado>(anioJson);
                if (anio == null || anio.Id <= 0)
                {
                    ResetSelection();
                    return;
                }

                AnioId = anio.Id;
                AnioClave = anio.Clave;
                AnioDescripcion = anio.Descripcion ?? string.Empty;
            }
            catch
            {
                if (version == selectionVersion) ResetSelection();
            }
            finally
            {
                storageGate.Release();
            }
        }

        private void ResetSelection()
        {
            AnioId = null;
            AnioClave = null;
            AnioDescripcion = string.Empty;
        }

        public async Task SetAnioAsync(int anioId, int? anioClave, string? anioDescripcion)
        {
            if (anioId <= 0) throw new ArgumentOutOfRangeException(nameof(anioId));
            var version = ++selectionVersion;
            AnioId = anioId;
            AnioClave = anioClave;
            AnioDescripcion = anioDescripcion ?? string.Empty;

            var anio = new AnioPresupuestalSeleccionado
            {
                Id = anioId,
                Clave = anioClave,
                Descripcion = AnioDescripcion
            };

            await storageGate.WaitAsync();
            try
            {
                if (version != selectionVersion) return;
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", ANIO_KEY, JsonSerializer.Serialize(anio));
            }
            finally
            {
                storageGate.Release();
            }
            if (version == selectionVersion) OnAnioChanged?.Invoke(AnioId);
        }

        public async Task SetAnioAsync(LookupItem item)
        {
            var clave = TryParseClave(item.Text);
            await SetAnioAsync(item.Id, clave, GetDescripcion(item.Text));
        }

        public async Task ClearAnioAsync()
        {
            var version = ++selectionVersion;
            ResetSelection();
            await storageGate.WaitAsync();
            try
            {
                if (version != selectionVersion) return;
                await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", ANIO_KEY);
            }
            finally
            {
                storageGate.Release();
                if (version == selectionVersion) OnAnioChanged?.Invoke(null);
            }
        }

        private static int? TryParseClave(string text)
        {
            var firstPart = text.Split('-', 2)[0].Trim();
            return int.TryParse(firstPart, out var clave) ? clave : null;
        }

        private static string GetDescripcion(string text)
        {
            var parts = text.Split('-', 2);
            return parts.Length == 2 ? parts[1].Trim() : string.Empty;
        }

        private class AnioPresupuestalSeleccionado
        {
            public int Id { get; set; }
            public int? Clave { get; set; }
            public string? Descripcion { get; set; }
        }
    }
}

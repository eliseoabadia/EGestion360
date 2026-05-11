using EG.Common.GenericModel;
using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services
{
    public class AnioPresupuestalStateService
    {
        private const string ANIO_KEY = "anio_presupuestal_seleccionado";
        private readonly IJSRuntime _jsRuntime;

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
            try
            {
                var anioJson = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", ANIO_KEY);
                if (string.IsNullOrWhiteSpace(anioJson))
                    return;

                var anio = JsonSerializer.Deserialize<AnioPresupuestalSeleccionado>(anioJson);
                if (anio == null || anio.Id <= 0)
                    return;

                AnioId = anio.Id;
                AnioClave = anio.Clave;
                AnioDescripcion = anio.Descripcion ?? string.Empty;
            }
            catch
            {
                AnioId = null;
                AnioClave = null;
                AnioDescripcion = string.Empty;
            }
        }

        public async Task SetAnioAsync(int anioId, int? anioClave, string? anioDescripcion)
        {
            AnioId = anioId;
            AnioClave = anioClave;
            AnioDescripcion = anioDescripcion ?? string.Empty;

            var anio = new AnioPresupuestalSeleccionado
            {
                Id = anioId,
                Clave = anioClave,
                Descripcion = AnioDescripcion
            };

            await _jsRuntime.InvokeVoidAsync("localStorage.setItem", ANIO_KEY, JsonSerializer.Serialize(anio));
            OnAnioChanged?.Invoke(AnioId);
        }

        public async Task SetAnioAsync(LookupItem item)
        {
            var clave = TryParseClave(item.Text);
            await SetAnioAsync(item.Id, clave, GetDescripcion(item.Text));
        }

        public async Task ClearAnioAsync()
        {
            AnioId = null;
            AnioClave = null;
            AnioDescripcion = string.Empty;
            await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", ANIO_KEY);
            OnAnioChanged?.Invoke(null);
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

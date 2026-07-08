using Microsoft.JSInterop;
using System.Text.Json;

namespace EG.Web.Services
{
    public enum AppThemeOption
    {
        Claro,
        Oscuro,
        Morena
    }

    public class ThemeStateService
    {
        private const string THEME_KEY = "tema_seleccionado";
        private readonly IJSRuntime _jsRuntime;

        public event Action<AppThemeOption>? OnThemeChanged;

        public AppThemeOption SelectedOption { get; private set; } = AppThemeOption.Oscuro;
        public bool IsDarkMode => SelectedOption is AppThemeOption.Oscuro;
        public string ThemeKey => SelectedOption == AppThemeOption.Morena ? "morena" : "default";
        public string ThemeName => GetThemeName(SelectedOption);

        public ThemeStateService(IJSRuntime jsRuntime)
        {
            _jsRuntime = jsRuntime;
        }

        public async Task InitializeAsync()
        {
            try
            {
                var themeJson = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", THEME_KEY);
                if (string.IsNullOrWhiteSpace(themeJson))
                    return;

                var theme = JsonSerializer.Deserialize<ThemeSelection>(themeJson);
                if (theme == null || string.IsNullOrWhiteSpace(theme.Option))
                    return;

                if (Enum.TryParse<AppThemeOption>(theme.Option, ignoreCase: true, out var option))
                    SelectedOption = option;
            }
            catch
            {
                SelectedOption = AppThemeOption.Oscuro;
            }
        }

        public async Task SetThemeAsync(AppThemeOption option)
        {
            SelectedOption = option;

            var theme = new ThemeSelection
            {
                Option = option.ToString()
            };

            await _jsRuntime.InvokeVoidAsync("localStorage.setItem", THEME_KEY, JsonSerializer.Serialize(theme));
            OnThemeChanged?.Invoke(SelectedOption);
        }

        public static string GetThemeName(AppThemeOption option) => option switch
        {
            AppThemeOption.Claro => "Claro",
            AppThemeOption.Oscuro => "Oscuro",
            AppThemeOption.Morena => "Morena",
            _ => "Oscuro"
        };

        private class ThemeSelection
        {
            public string? Option { get; set; }
        }
    }
}

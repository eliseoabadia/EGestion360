window.mudBlazorTheme = {
    applyTheme: function () {
        // Force MudBlazor to re-apply theme
        if (window.mudBlazor) {
            window.mudBlazor.themeWatcher.applyTheme();
        }
    }
};

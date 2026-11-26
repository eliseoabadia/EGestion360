using System.Globalization;
using System.Text;
using EG.Web.Extensions;
using EG.Web.Contracts.Configuration;
using EG.Web.Models.Configuration;
using EG.Web.Services;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Routing;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using EG.Web.Pages.Shared;
using EG.Web.Shared;
using EG.Web.Models.Forms;
using MudBlazor;

namespace EG.Web.Layout;

public partial class DynamicMenu
{
    private readonly Dictionary<int, bool> _expandedStates = new();
    private readonly Dictionary<int, MenuItem> _itemsById = new();
    private readonly Dictionary<int, int?> _parentById = new();
    private readonly List<MenuItem> _groups = new();
    private readonly List<MenuItem> _routeItems = new();
    private readonly List<SearchIndexEntry> _searchIndex = new();

    private CancellationTokenSource? _searchDebounceCts;
    private bool _loading;
    private bool _isInitialized;
    private bool _navigationLocked;
    private bool _disposed;
    private readonly EditorRequestState _menuLoad = new();
    private int _userId;
    private int? _lastToggleId;
    private DateTime _lastToggleAtUtc = DateTime.MinValue;

    private string _currentPath = string.Empty;
    private string _searchText = string.Empty;
    private string? _loadError;
    private List<SearchResultItem> _searchResults = new();

    [Parameter] public List<MenuItem> Items { get; set; } = new();
    [Parameter] public bool IsCollapsed { get; set; }
    [Parameter] public string ThemeKey { get; set; } = "default";

    private string ThemeClass => ThemeKey == "morena" ? "morena" : string.Empty;

    protected override async Task OnInitializedAsync()
    {
        NavigationManager.LocationChanged += OnLocationChanged;
        AuthenticationStateProvider.AuthenticationStateChanged += OnAuthenticationStateChanged;
        await base.OnInitializedAsync();
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (_disposed || !firstRender || _isInitialized)
            return;

        _isInitialized = true;
        await LoadMenuAsync();
    }

    private async Task LoadMenuAsync()
    {
        if (_disposed) return;
        var uri = NavigationManager.ToBaseRelativePath(NavigationManager.Uri).TrimEnd('/');
        if (uri == "login" || uri.StartsWith("login?", StringComparison.OrdinalIgnoreCase))
            return;

        _loading = true;
        var version = _menuLoad.Begin();
        _loadError = null;
        await InvokeAsync(StateHasChanged);

        try
        {
            var userId = await GetUserIdAsync();
            if (!_menuLoad.IsCurrent(version)) return;
            _userId = userId;
            if (_userId == 0)
            {
                Items = new();
                RebuildMenuIndexes();
                _loadError = "No pudimos identificar tu usuario. Cierra sesion e ingresa nuevamente.";
                Logger.LogWarning("No se cargo el menu porque no fue posible resolver el identificador del usuario.");
                return;
            }

            if (MenuStateService.TryGetItems(_userId, out var cachedItems))
            {
                Items = NormalizeMenuItems(cachedItems);
                RebuildMenuIndexes();
                SyncExpandedStateWithCurrentRoute();
                return;
            }

            var result = await NavigateService.GetMenuAsync(_userId);
            if (!_menuLoad.IsCurrent(version)) return;
            if (result is null || !result.Success)
            {
                Items = new();
                RebuildMenuIndexes();
                _loadError = string.IsNullOrWhiteSpace(result?.Message)
                    ? "No pudimos cargar el menu. Intenta recargar o avisa a TI."
                    : result.Message;
                Logger.LogWarning("La carga del menu no fue exitosa. UserId={UserId}; Message={Message}", _userId, result?.Message);
                Snackbar.Add(_loadError, Severity.Warning);
                return;
            }

            Items = NormalizeMenuItems(result?.Items);
            MenuStateService.Initialize(_userId, Items);
            RebuildMenuIndexes();
            SyncExpandedStateWithCurrentRoute();
        }
        catch (Exception ex)
        {
            if (!_menuLoad.IsCurrent(version)) return;
            Items = new();
            RebuildMenuIndexes();
            _loadError = "No pudimos cargar el menu. Intenta recargar o avisa a TI.";
            Logger.LogError(ex, "Error inesperado al construir el menu del usuario {UserId}.", _userId);
            Snackbar.Add(_loadError, Severity.Error);
        }
        finally
        {
            if (_menuLoad.IsCurrent(version))
            {
                _loading = false;
                _menuLoad.Complete(version);
                await InvokeAsync(StateHasChanged);
            }
        }
    }

    private void OnAuthenticationStateChanged(Task<AuthenticationState> state)
    {
        if (_disposed) return;
        var version = _menuLoad.Begin();
        _ = InvokeAsync(() => RefreshSessionMenuAsync(state, version));
    }

    private async Task RefreshSessionMenuAsync(Task<AuthenticationState> state, int version)
    {
        if (!_menuLoad.IsCurrent(version)) return;
        MenuStateService.Clear();
        Items = [];
        _userId = 0;
        _searchText = string.Empty;
        _searchResults.Clear();
        _expandedStates.Clear();
        _searchDebounceCts?.Cancel();
        RebuildMenuIndexes();
        _loading = false;
        _loadError = null;
        StateHasChanged();
        try
        {
            var authentication = await state;
            if (!_menuLoad.IsCurrent(version)) return;
            if (authentication.User.Identity?.IsAuthenticated == true)
                await LoadMenuAsync();
            else
                StateHasChanged();
        }
        catch (Exception exception)
        {
            if (!_menuLoad.IsCurrent(version)) return;
            _loadError = "No fue posible actualizar el menú de la sesión.";
            Logger.LogError(exception, "No se pudo actualizar el menú tras cambiar la autenticación.");
            StateHasChanged();
        }
    }

    private static List<MenuItem> NormalizeMenuItems(IEnumerable<MenuItem>? items)
    {
        return (items ?? Enumerable.Empty<MenuItem>())
            .OrderBy(item => item.Orden ?? int.MaxValue)
            .ThenBy(item => item.Nombre)
            .Select(item =>
            {
                item.Children = NormalizeMenuItems(item.Children);
                return item;
            })
            .ToList();
    }

    private void RebuildMenuIndexes()
    {
        _itemsById.Clear();
        _parentById.Clear();
        _groups.Clear();
        _routeItems.Clear();
        _searchIndex.Clear();

        foreach (var root in Items)
        {
            IndexMenuItem(root, parentId: null);
        }

        _routeItems.AddRange(_itemsById.Values
            .Where(IsNavigableItem)
            .OrderByDescending(item => NormalizeRoute(item.Ruta).Length));

        foreach (var item in _routeItems)
        {
            var breadcrumb = BuildBreadcrumb(item);
            _searchIndex.Add(new SearchIndexEntry
            {
                Name = UiTerminology.Display(item.Nombre),
                Route = item.Ruta,
                IconClass = GetIconClass(item.ImageUrl),
                Breadcrumb = breadcrumb,
                SearchText = NormalizeText($"{breadcrumb} {UiTerminology.Display(item.Nombre)} {item.Nombre} {item.LegacyName} {item.Ruta}")
            });
        }
    }

    private void IndexMenuItem(MenuItem item, int? parentId)
    {
        _itemsById[item.PkidMenu] = item;
        _parentById[item.PkidMenu] = parentId;

        if (item.Children?.Any() == true)
        {
            _groups.Add(item);
            _expandedStates.TryAdd(item.PkidMenu, false);

            foreach (var child in item.Children)
            {
                IndexMenuItem(child, item.PkidMenu);
            }
        }
    }

    private string BuildBreadcrumb(MenuItem item)
    {
        var segments = new Stack<string>();
        var currentId = item.PkidMenu;

        while (_parentById.TryGetValue(currentId, out var parentId) && parentId.HasValue)
        {
            if (!_itemsById.TryGetValue(parentId.Value, out var parent))
                break;

            segments.Push(UiTerminology.Display(parent.Nombre));
            currentId = parent.PkidMenu;
        }

        return string.Join(" > ", segments);
    }

    private void OnLocationChanged(object? sender, LocationChangedEventArgs e)
    {
        if (_disposed) return;
        SyncExpandedStateWithCurrentRoute();
        StateHasChanged();
    }

    private void SyncExpandedStateWithCurrentRoute()
    {
        _currentPath = NormalizeRoute(NavigationManager.ToBaseRelativePath(NavigationManager.Uri));
        var activeItem = FindItemByRoute(_currentPath);
        if (activeItem == null)
            return;

        foreach (var group in _groups)
        {
            _expandedStates[group.PkidMenu] = false;
        }

        ExpandPathToItem(activeItem);
    }

    private MenuItem? FindItemByRoute(string route)
    {
        return _routeItems.FirstOrDefault(item => RouteMatches(route, NormalizeRoute(item.Ruta)));
    }

    private void ExpandPathToItem(MenuItem item)
    {
        if (item.Children?.Any() == true)
        {
            _expandedStates[item.PkidMenu] = true;
        }

        var currentId = item.PkidMenu;
        while (_parentById.TryGetValue(currentId, out var parentId) && parentId.HasValue)
        {
            _expandedStates[parentId.Value] = true;
            currentId = parentId.Value;
        }
    }

    private bool GetExpandedState(int? pkId) =>
        pkId.HasValue && _expandedStates.TryGetValue(pkId.Value, out var state) && state;

    private void SetExpandedState(int? pkId, bool expanded)
    {
        if (!pkId.HasValue)
            return;

        var now = DateTime.UtcNow;
        if (_lastToggleId == pkId.Value && now - _lastToggleAtUtc < TimeSpan.FromMilliseconds(180))
            return;

        _lastToggleId = pkId.Value;
        _lastToggleAtUtc = now;
        _expandedStates[pkId.Value] = expanded;

        if (expanded)
        {
            CollapseSiblings(pkId.Value);
        }

        StateHasChanged();
    }

    private void CollapseSiblings(int expandedId)
    {
        if (!_itemsById.TryGetValue(expandedId, out var expandedItem))
            return;

        var siblings = _parentById.TryGetValue(expandedItem.PkidMenu, out var parentId) && parentId.HasValue
            ? _itemsById.TryGetValue(parentId.Value, out var parent) ? parent.Children : Enumerable.Empty<MenuItem>()
            : Items;

        foreach (var sibling in siblings.Where(item => item.PkidMenu != expandedId && item.Children?.Any() == true))
        {
            _expandedStates[sibling.PkidMenu] = false;
        }
    }

    private async Task OnSearchChanged(ChangeEventArgs e)
    {
        if (_disposed) return;
        _searchText = e.Value?.ToString() ?? string.Empty;
        _searchDebounceCts?.Cancel();
        _searchDebounceCts?.Dispose();

        if (string.IsNullOrWhiteSpace(_searchText))
        {
            _searchResults.Clear();
            await InvokeAsync(StateHasChanged);
            return;
        }

        var cts = new CancellationTokenSource();
        _searchDebounceCts = cts;

        try
        {
            await Task.Delay(140, cts.Token);
        }
        catch (OperationCanceledException)
        {
            return;
        }

        if (_disposed || cts.IsCancellationRequested)
            return;

        _searchResults = FilterMenuItems(_searchText);
        await InvokeAsync(StateHasChanged);
    }

    private List<SearchResultItem> FilterMenuItems(string searchText)
    {
        var term = NormalizeText(searchText);
        if (string.IsNullOrWhiteSpace(term))
            return new();

        return _searchIndex
            .Where(entry => entry.SearchText.Contains(term, StringComparison.Ordinal))
            .Take(40)
            .Select(entry => new SearchResultItem
            {
                Name = entry.Name,
                IconClass = entry.IconClass,
                Route = entry.Route,
                Breadcrumb = entry.Breadcrumb
            })
            .ToList();
    }

    private void ClearSearch()
    {
        _searchDebounceCts?.Cancel();
        _searchText = string.Empty;
        _searchResults.Clear();
        StateHasChanged();
    }

    private async Task NavigateToSearchResultAsync(SearchResultItem result)
    {
        if (string.IsNullOrWhiteSpace(result.Route))
        {
            Logger.LogWarning("El resultado de menu {MenuName} no tiene una ruta configurada.", result.Name);
            Snackbar.Add("Esta opcion no tiene una ruta configurada. Avisa al administrador.", Severity.Warning);
            return;
        }

        ClearSearch();
        await NavigateToRouteAsync(result.Route);
    }

    private async Task NavigateToMenuItemAsync(MenuItem item)
    {
        if (!IsNavigableItem(item))
            return;

        await NavigateToRouteAsync(item.Ruta);
    }

    private Task NavigateToDashboardAsync(string route) =>
        NavigateToRouteAsync(route);

    private async Task NavigateToRouteAsync(string route)
    {
        if (_disposed) return;
        if (_navigationLocked)
        {
            Snackbar.Add("Ya estamos abriendo una opcion. Espera un momento.", Severity.Info);
            return;
        }

        _navigationLocked = true;
        _currentPath = NormalizeRoute(route);
        var activeItem = FindItemByRoute(_currentPath);
        if (activeItem != null)
        {
            foreach (var group in _groups)
            {
                _expandedStates[group.PkidMenu] = false;
            }

            ExpandPathToItem(activeItem);
        }

        await InvokeAsync(StateHasChanged);

        try
        {
            NavigationManager.NavigateTo(route);
            await Task.Delay(180);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "No fue posible navegar a la ruta {Route}.", route);
            Snackbar.Add("No fue posible abrir la opcion seleccionada. Intenta nuevamente.", Severity.Error);
        }
        finally
        {
            _navigationLocked = false;
            if (!_disposed) await InvokeAsync(StateHasChanged);
        }
    }

    private Task<int> GetUserIdAsync() => AuthService.GetUserIdAsync();

    private string GetIconClass(string? imageUrl) =>
        IconosDisponibles.GetMaterialIcon(imageUrl);

    private static string? GetDashboardRoute(MenuItem item)
    {
        var key = NormalizeText($"{item.Nombre} {item.LegacyName} {item.Ruta}");

        if (key.Contains("tesoreria", StringComparison.Ordinal))
            return "/Tesoreria/Dashboard";

        if (key.Contains("reportes cxc", StringComparison.Ordinal) ||
            key.Contains("cuentasxcobrar", StringComparison.Ordinal) ||
            key.Contains("cuentas por cobrar", StringComparison.Ordinal))
            return "/ReportesCxC/Dashboard";

        if (key.Contains("contabilidad", StringComparison.Ordinal))
            return "/Contabilidad/Dashboard";

        if (key.Contains("adquisicion", StringComparison.Ordinal))
            return "/Adquisiciones/Dashboard";

        if (key.Contains("patrimonio", StringComparison.Ordinal))
            return "/Patrimonio/Dashboard";

        if (key.Contains("almacen", StringComparison.Ordinal))
            return "/Almacen/Dashboard";

        if (key.Contains("presupuesto", StringComparison.Ordinal))
            return "/Presupuesto/Dashboard";

        if (key.Contains("nomina", StringComparison.Ordinal))
            return "/Nomina/Dashboard";

        if (key == "pbr" || key.Contains(" pbr", StringComparison.Ordinal))
            return "/PBR/Dashboard";

        if (key.Contains("configuracion", StringComparison.Ordinal))
            return "/Configuracion/Dashboard";

        return null;
    }

    private bool IsActiveRoute(string? route) =>
        RouteMatches(_currentPath, NormalizeRoute(route));

    private static bool IsNavigableItem(MenuItem item)
    {
        var route = NormalizeRoute(item.Ruta);
        return !string.IsNullOrWhiteSpace(route) && item.Ruta != "/";
    }

    private static string NormalizeRoute(string? route)
    {
        if (string.IsNullOrWhiteSpace(route))
            return string.Empty;

        var value = route.Trim();
        if (Uri.TryCreate(value, UriKind.Absolute, out var uri))
        {
            value = uri.PathAndQuery;
        }

        var queryIndex = value.IndexOfAny(new[] { '?', '#' });
        if (queryIndex >= 0)
        {
            value = value[..queryIndex];
        }

        return value.Trim('/');
    }

    private static bool RouteMatches(string currentRoute, string itemRoute)
    {
        if (string.IsNullOrWhiteSpace(itemRoute))
            return string.IsNullOrWhiteSpace(currentRoute);

        return string.Equals(currentRoute, itemRoute, StringComparison.OrdinalIgnoreCase) ||
               currentRoute.StartsWith($"{itemRoute}/", StringComparison.OrdinalIgnoreCase);
    }

    private static string NormalizeText(string? text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return string.Empty;

        var normalized = text.Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder(normalized.Length);

        foreach (var c in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
            {
                builder.Append(char.ToLowerInvariant(c));
            }
        }

        return builder.ToString().Normalize(NormalizationForm.FormC);
    }

    public void Dispose()
    {
        _disposed = true;
        _menuLoad.Dispose();
        AuthenticationStateProvider.AuthenticationStateChanged -= OnAuthenticationStateChanged;
        NavigationManager.LocationChanged -= OnLocationChanged;
        _searchDebounceCts?.Cancel();
        _searchDebounceCts?.Dispose();
    }

    private sealed class SearchIndexEntry
    {
        public string Name { get; set; } = string.Empty;
        public string IconClass { get; set; } = string.Empty;
        public string Route { get; set; } = string.Empty;
        public string Breadcrumb { get; set; } = string.Empty;
        public string SearchText { get; set; } = string.Empty;
    }

    private sealed class SearchResultItem
    {
        public string Name { get; set; } = string.Empty;
        public string IconClass { get; set; } = string.Empty;
        public string Route { get; set; } = string.Empty;
        public string Breadcrumb { get; set; } = string.Empty;
    }
}

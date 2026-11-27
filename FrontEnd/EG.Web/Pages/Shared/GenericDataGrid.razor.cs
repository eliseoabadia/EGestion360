using MudBlazor;
using System.Collections;
using System.Reflection;
using EG.Web.Models.Forms;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.Logging;

namespace EG.Web.Pages.Shared;

public partial class GenericDataGrid<TItem>
{
    [Parameter] public string Title { get; set; } = string.Empty;
    [Parameter] public string Eyebrow { get; set; } = "CENTRO DE DATOS";
    [Parameter] public string EmptyTitle { get; set; } = "Aún no hay registros";
    [Parameter] public string EmptyMessage { get; set; } = "Revisa el contexto activo, permisos o filtros aplicados.";
    [Parameter] public int Elevation { get; set; } = 2;
    [Parameter] public string SearchPlaceholder { get; set; } = "Buscar...";
    [Parameter] public bool ShowSearch { get; set; } = true;
    [Parameter] public string SearchString { get; set; } = string.Empty;
    [Parameter] public EventCallback<string> SearchStringChanged { get; set; }
    [Parameter] public EventCallback OnSearch { get; set; }
    [Parameter] public int SearchDebounceMilliseconds { get; set; } = 400;
    // La recarga de la vista vive en PageHeader. Se puede habilitar de forma
    // explícita en grids autónomos para evitar dos acciones idénticas.
    [Parameter] public bool ShowRefreshButton { get; set; }
    [Parameter] public bool ShowExportButton { get; set; }
    [Parameter] public bool ShowBusyOverlay { get; set; } = true;
    [Parameter] public bool ShowAddButton { get; set; }
    [Parameter] public string AddButtonTooltip { get; set; } = "Agregar";
    [Parameter] public string AddButtonIcon { get; set; } = Icons.Material.Filled.AddCircleOutline;
    [Parameter] public Color AddButtonColor { get; set; } = Color.Success;
    [Parameter] public EventCallback OnAdd { get; set; }
    [Parameter] public bool ShowToolbar { get; set; } = true;
    [Parameter] public bool ShowDetailHint { get; set; } = true;
    [Parameter] public bool FillAvailableHeight { get; set; } = true;
    [Parameter] public bool EnableColumnOptions { get; set; } = true;
    [Parameter] public bool EnableColumnReordering { get; set; } = true;
    [Parameter] public ResizeMode ColumnResizeMode { get; set; } = ResizeMode.Column;
    [Parameter] public bool EnableColumnFilters { get; set; }
    [Parameter] public bool EnableGrouping { get; set; }
    [Parameter] public bool Dense { get; set; } = true;
    [Parameter] public bool Hover { get; set; } = true;
    [Parameter] public bool Striped { get; set; }
    [Parameter] public bool ReadOnly { get; set; } = true;
    [Parameter] public bool FixedHeader { get; set; } = true;
    // Sin alto por defecto: el contenedor flex calcula el espacio restante entre
    // toolbar y paginador. Un height:100% aqui suma ambos elementos y los empuja
    // por debajo del viewport.
    [Parameter] public string? TableHeight { get; set; }
    [Parameter] public int PageSize { get; set; } = 10;
    [Parameter] public SortDirection InitialSortDirection { get; set; } = SortDirection.Ascending;
    [Parameter] public int[] PageSizeOptions { get; set; } = new[] { 5, 10, 20, 50 };
    [Parameter] public string LoadingMessage { get; set; } = EG.Common.ApplicationText.Status.LoadingData;
    [Parameter] public string ActionLoadingMessage { get; set; } = "Procesando...";
    [Parameter] public RenderFragment? Columns { get; set; }
    [Parameter] public RenderFragment? ToolbarActions { get; set; }
    [Parameter] public RenderFragment<TItem>? RowActions { get; set; }
    [Parameter] public IEnumerable<PropertyInfo>? ReflectedColumns { get; set; }
    [Parameter] public Func<PropertyInfo, string>? ColumnTitleFunc { get; set; }
    [Parameter] public Func<TItem, PropertyInfo, string>? CellValueFunc { get; set; }
    [Parameter] public string ActionsColumnTitle { get; set; } = "Acciones";
    [Parameter] public Func<TableState, CancellationToken, Task<TableData<TItem>>>? ServerDataFunc { get; set; }
    [Parameter] public IEnumerable<TItem>? Items { get; set; }
    [Parameter] public Func<TItem, string>? SearchTextFunc { get; set; }
    [Parameter] public Func<Task>? ExportFunc { get; set; }
    [Parameter] public EventCallback<TItem> OnRowDoubleClick { get; set; }
    [Parameter] public EventCallback<TItem> OnRowClick { get; set; }
    [Parameter] public Func<TItem, int, string>? RowClassFunc { get; set; }

    private MudDataGrid<TItem>? dataGridRef;
    private bool isLoading;
    private bool actionInProgress;
    private bool disposed;
    private int searchDebounceVersion;
    private int totalItems;
    private string? lastLoadError;
    private readonly LatestGridRequest<GridData<TItem>> loadRequests = new();

    private bool IsGridBusy => isLoading || actionInProgress;
    // El elemento raiz debe ser HTML nativo para que Blazor agregue el atributo
    // de aislamiento CSS. MudPaper no propagaba ese atributo y dejaba sin efecto
    // las reglas de altura, flex y overflow del grid compartido.
    private string GridClass => $"mud-paper mud-elevation-{Elevation} themed-table eg-generic-data-grid{(OnRowDoubleClick.HasDelegate ? " eg-grid-has-detail" : string.Empty)}{(FillAvailableHeight ? string.Empty : " eg-grid-auto-height")}";

    private async Task HandleRowClickAsync(DataGridRowClickEventArgs<TItem> args)
    {
        if (args.Item is not null && args.MouseEventArgs.Detail == 1 && OnRowClick.HasDelegate)
            await OnRowClick.InvokeAsync(args.Item);
        if (args.MouseEventArgs.Detail != 2 || !OnRowDoubleClick.HasDelegate || args.Item is null)
        {
            return;
        }

        await OnRowDoubleClick.InvokeAsync(args.Item);
    }

    private string GetReflectedColumnTitle(PropertyInfo property)
        => ColumnTitleFunc?.Invoke(property) ?? property.Name;

    private string GetReflectedCellValue(TItem item, PropertyInfo property)
        => CellValueFunc?.Invoke(item, property) ?? property.GetValue(item)?.ToString() ?? string.Empty;

    private async Task<GridData<TItem>> LoadServerDataAsync(GridState<TItem> state, CancellationToken cancellationToken)
    {
        if (disposed)
        {
            return new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 };
        }

        isLoading = true;
        var request = loadRequests.Begin();

        try
        {
            if (ServerDataFunc is null && Items is null)
            {
                lastLoadError = "La tabla no tiene configurada una fuente de datos.";
                Logger.LogError("GenericDataGrid no tiene ServerDataFunc ni Items. Title={Title}", Title);
                totalItems = 0;
                return await loadRequests.ResolveAsync(request, new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 });
            }

            var sort = state.SortDefinitions
                .OrderBy(definition => definition.Index)
                .FirstOrDefault();

            var tableState = new TableState
            {
                Page = state.Page,
                PageSize = state.PageSize,
                SortLabel = sort?.SortBy,
                SortDirection = sort is null
                    ? InitialSortDirection
                    : sort.Descending ? SortDirection.Descending : SortDirection.Ascending
            };

            var tableData = ServerDataFunc is not null
                ? await ServerDataFunc(tableState, cancellationToken)
                : LoadLocalData(tableState);
            if (loadRequests.IsCurrent(request) && !cancellationToken.IsCancellationRequested)
            {
                totalItems = tableData.TotalItems;
                lastLoadError = null;
            }
            return await loadRequests.ResolveAsync(request, new GridData<TItem> { Items = tableData.Items, TotalItems = tableData.TotalItems });
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested || disposed)
        {
            Logger.LogDebug("Se canceló la carga de GenericDataGrid al cambiar de vista. Title={Title}", Title);
            if (disposed) return new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 };
            return await loadRequests.ResolveAsync(request, new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 });
        }
        catch (Exception ex)
        {
            if (disposed) return new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 };
            if (!loadRequests.IsCurrent(request))
                return await loadRequests.ResolveAsync(request, new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 });
            lastLoadError = "No fue posible cargar la información. Revisa tu conexión e intenta nuevamente.";
            totalItems = 0;
            Logger.LogError(ex, "Error al cargar GenericDataGrid. Title={Title}", Title);
            Snackbar.Add(lastLoadError, Severity.Error);
            return await loadRequests.ResolveAsync(request, new GridData<TItem> { Items = Array.Empty<TItem>(), TotalItems = 0 });
        }
        finally
        {
            if (loadRequests.IsCurrent(request)) isLoading = false;
            if (!disposed && loadRequests.IsCurrent(request))
            {
                await InvokeAsync(StateHasChanged);
            }
        }
    }

    private TableData<TItem> LoadLocalData(TableState state)
    {
        IEnumerable<TItem> query = Items ?? Array.Empty<TItem>();

        if (!string.IsNullOrWhiteSpace(SearchString) && SearchTextFunc is not null)
        {
            query = query.Where(item =>
                SearchTextFunc(item).Contains(SearchString, StringComparison.OrdinalIgnoreCase));
        }

        if (!string.IsNullOrWhiteSpace(state.SortLabel))
        {
            var property = typeof(TItem).GetProperty(
                state.SortLabel,
                BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);

            if (property is not null)
            {
                var comparer = Comparer<object?>.Create((left, right) =>
                    Comparer.DefaultInvariant.Compare(left, right));
                query = state.SortDirection == SortDirection.Descending
                    ? query.OrderByDescending(item => property.GetValue(item), comparer)
                    : query.OrderBy(item => property.GetValue(item), comparer);
            }
        }

        var materialized = query.ToList();
        return new TableData<TItem>
        {
            Items = materialized.Skip(state.Page * state.PageSize).Take(state.PageSize),
            TotalItems = materialized.Count
        };
    }

    private async Task OnSearchTextChanged(string? value)
    {
        SearchString = value ?? string.Empty;
        await SearchStringChanged.InvokeAsync(SearchString);
        QueueSearchDebounce();
    }

    private void QueueSearchDebounce()
    {
        var version = ++searchDebounceVersion;
        _ = DebounceSearchAsync(version);
    }

    private async Task HandleKeyUp(KeyboardEventArgs args)
    {
        if (args.Key == "Enter")
        {
            await ApplySearchAsync();
        }
    }

    private async Task DebounceSearchAsync(int version)
    {
        try
        {
            await Task.Delay(Math.Max(0, SearchDebounceMilliseconds));
            if (disposed || version != searchDebounceVersion)
            {
                return;
            }

            await InvokeAsync(async () =>
            {
                if (!disposed && version == searchDebounceVersion)
                {
                    await ApplySearchAsync();
                }
            });
        }
        catch (ObjectDisposedException ex)
        {
            Logger.LogDebug(ex, "Se canceló una búsqueda al liberar GenericDataGrid. Title={Title}", Title);
        }
    }

    private async Task ApplySearchAsync()
    {
        searchDebounceVersion++;
        if (disposed || actionInProgress)
        {
            return;
        }

        if (OnSearch.HasDelegate)
        {
            await OnSearch.InvokeAsync();
            return;
        }

        if (dataGridRef is not null && dataGridRef.CurrentPage != 0)
        {
            dataGridRef.NavigateTo(Page.First);
            return;
        }

        await ReloadData();
    }

    public async Task ReloadData()
    {
        if (disposed)
        {
            return;
        }

        if (dataGridRef is null)
        {
            Logger.LogWarning("Se intentó recargar GenericDataGrid antes de estar listo. Title={Title}", Title);
            Snackbar.Add("La tabla aún no está lista. Espera un momento e intenta nuevamente.", Severity.Warning);
            return;
        }

        try
        {
            await dataGridRef.ReloadServerData();
        }
        catch (OperationCanceledException) when (disposed)
        {
            Logger.LogDebug("Se canceló la recarga de GenericDataGrid al cambiar de vista. Title={Title}", Title);
        }
        catch (Exception ex)
        {
            lastLoadError = "No fue posible actualizar la información. Intenta nuevamente.";
            Logger.LogError(ex, "Error al recargar GenericDataGrid. Title={Title}", Title);
            Snackbar.Add(lastLoadError, Severity.Error);
        }
    }

    private async Task ReloadDataWithFeedbackAsync()
    {
        await ReloadData();
        if (string.IsNullOrWhiteSpace(lastLoadError))
        {
            Snackbar.Add("Información actualizada.", Severity.Success);
        }
    }

    private void ShowColumnsPanel(MouseEventArgs args)
    {
        dataGridRef?.ShowColumnsPanel(args);
    }

    private async Task ExportToExcelAsync()
    {
        if (disposed)
        {
            return;
        }

        if (ExportFunc is null)
        {
            Logger.LogWarning("Se solicitó exportar GenericDataGrid sin ExportFunc. Title={Title}", Title);
            Snackbar.Add("La exportación no está disponible para esta tabla.", Severity.Warning);
            return;
        }

        actionInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
            await ExportFunc();
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error al exportar GenericDataGrid. Title={Title}", Title);
            Snackbar.Add("No fue posible completar la exportación. El detalle técnico quedó registrado.", Severity.Error);
        }
        finally
        {
            actionInProgress = false;
            if (!disposed)
            {
                await InvokeAsync(StateHasChanged);
            }
        }
    }

    public void Dispose()
    {
        disposed = true;
        loadRequests.Dispose();
        searchDebounceVersion++;
    }
}

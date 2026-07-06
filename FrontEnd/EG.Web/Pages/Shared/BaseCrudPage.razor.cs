using EG.Web.Auth;
using EG.Web.Contracts;
using EG.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using MiniExcelLibs;
using MudBlazor;

namespace EG.Web.Shared;

public abstract class BaseCrudPage<TItem, TResponse> : ComponentBase
    where TItem : class
    where TResponse : class
{
    [Inject] protected NavigationManager NavigationManager { get; set; } = null!;
    [Inject] protected ISnackbar Snackbar { get; set; } = null!;
    [Inject] protected IJSRuntime JsRuntime { get; set; } = null!;
    [Inject] protected IDialogService DialogService { get; set; } = null!;
    [Inject] private AuthenticationProviderJWT AuthProvider { get; set; } = null!;
    [Inject] protected IGenericCrudService<TResponse> Service { get; set; } = null!;

    protected List<TResponse> Elements { get; set; } = new();
    protected int TotalCount { get; set; }
    protected bool IsInitialized { get; set; }
    protected bool HasAccess { get; set; }

    // Permisos
    protected bool CanView { get; set; }
    protected bool CanCreate { get; set; }
    protected bool CanUpdate { get; set; }
    protected bool CanDelete { get; set; }
    protected bool CanExport { get; set; }
    protected bool CanAuthorize { get; set; }

    // Propiedades de tabla
    protected string SearchString { get; set; } = string.Empty;
    protected bool Loading { get; set; }
    protected int CurrentPage { get; set; }
    protected int PageSize { get; set; } = 10;
    protected SortDirection SortDirection { get; set; }
    protected string SortLabel { get; set; } = string.Empty;
    protected CancellationTokenSource SearchCts { get; set; } = new();
    protected bool OperationInProgress { get; private set; }
    protected bool IsBusy => Loading || OperationInProgress;

    protected abstract string ModuleName { get; }
    protected abstract string SubModuleName { get; }
    protected abstract Type CreateDialogType { get; }
    protected abstract Type EditDialogType { get; }
    protected abstract Type DeleteDialogType { get; }
    protected virtual int ExportPageSize => 1000;
    protected virtual int MaxExportRows => 50000;

    protected Task<bool> ConfirmWorkflowAsync(
        string title,
        string message,
        string confirmText = "Confirmar",
        Severity severity = Severity.Info,
        int? id = null)
    {
        var color = severity switch
        {
            Severity.Success => Color.Success,
            Severity.Warning => Color.Warning,
            Severity.Error => Color.Error,
            _ => Color.Primary
        };

        return DialogService.ConfirmWorkflowAsync(title, message, confirmText, color, id);
    }

    protected async Task<bool> RunExclusiveAsync(Func<Task> operation, string? busyMessage = null)
    {
        if (OperationInProgress)
        {
            if (!string.IsNullOrWhiteSpace(busyMessage))
            {
                Snackbar.Add(busyMessage, Severity.Info);
            }

            return false;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
            await operation();
            return true;
        }
        finally
        {
            OperationInProgress = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    protected async Task<TResult> RunExclusiveAsync<TResult>(
        Func<Task<TResult>> operation,
        TResult busyResult,
        string? busyMessage = null)
    {
        if (OperationInProgress)
        {
            if (!string.IsNullOrWhiteSpace(busyMessage))
            {
                Snackbar.Add(busyMessage, Severity.Info);
            }

            return busyResult;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
            return await operation();
        }
        finally
        {
            OperationInProgress = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender && !IsInitialized)
        {
            await VerifyAccess();
        }
    }

    protected virtual async Task VerifyAccess()
    {
        IsInitialized = true;
        try
        {
            Console.WriteLine($"🔷 VerifyAccess: Module={ModuleName}, SubModule={SubModuleName}");
            CanView = AuthProvider.HasPermission(ModuleName, SubModuleName, "view")
                || AuthProvider.HasPermission(ModuleName, SubModuleName, "view-menu");
            Console.WriteLine($"🔷 VerifyAccess: CanView={CanView}");

            if (!CanView)
            {
                Console.WriteLine("⚠️ VerifyAccess: Sin permiso de vista, redirigiendo...");
                HasAccess = false;
                StateHasChanged();
                await Task.Delay(2000);
                NavigationManager.NavigateTo("/", replace: true);
                return;
            }

            CanCreate = AuthProvider.HasPermission(ModuleName, SubModuleName, "new");
            CanUpdate = AuthProvider.HasPermission(ModuleName, SubModuleName, "update");
            CanDelete = AuthProvider.HasPermission(ModuleName, SubModuleName, "delete");
            CanExport = AuthProvider.HasPermission(ModuleName, SubModuleName, "CanExportToExcel");
            CanAuthorize = AuthProvider.HasPermission(ModuleName, SubModuleName, "authorize");

            Console.WriteLine($"🔷 VerifyAccess: Create={CanCreate}, Update={CanUpdate}, Delete={CanDelete}, Export={CanExport}, Authorize={CanAuthorize}");
            HasAccess = true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ VerifyAccess: {ex.Message}");
            Snackbar.Add($"Error al verificar permisos: {ex.Message}", Severity.Error);
            await Task.Delay(1000);
            NavigationManager.NavigateTo("/", replace: true);
        }
        finally
        {
            Loading = false;
            StateHasChanged();
        }
    }

    protected virtual async Task<TableData<TResponse>> LoadServerData(TableState state, CancellationToken cancellationToken)
    {
        Loading = true;
        StateHasChanged();

        try
        {
            var page = Math.Max(1, state.Page + 1);
            CurrentPage = page;
            PageSize = state.PageSize;
            SortLabel = state.SortLabel ?? GetDefaultSortLabel();
            SortDirection = state.SortDirection;

            Console.WriteLine($"🔷 LoadServerData: Page={CurrentPage}, PageSize={PageSize}, Sort={SortLabel}, Dir={SortDirection}");

            var response = await Service.GetAllPaginadoAsync(
                CurrentPage,
                PageSize,
                SearchString,
                SortLabel,
                SortDirection,
                null
            );

            if (response?.Success == true && response.Items != null)
            {
                Elements = response.Items.ToList();
                TotalCount = response.TotalCount;
                Console.WriteLine($"✅ LoadServerData: {Elements.Count} items de {TotalCount} totales");
            }
            else
            {
                Console.WriteLine($"⚠️ LoadServerData: falló (Success={response?.Success}, Items null={response?.Items == null}, Msg={response?.Message})");
                Elements.Clear();
                TotalCount = 0;
                if (!string.IsNullOrEmpty(response?.Message))
                {
                    Snackbar.Add(response.Message, Severity.Error);
                }
            }

            return new TableData<TResponse>
            {
                Items = Elements,
                TotalItems = TotalCount
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ LoadServerData: {ex.Message}");
            Snackbar.Add($"Error al cargar datos: {ex.Message}", Severity.Error);
            return new TableData<TResponse>
            {
                Items = new List<TResponse>(),
                TotalItems = 0
            };
        }
        finally
        {
            Loading = false;
            StateHasChanged();
        }
    }

    protected abstract string GetDefaultSortLabel();

    protected virtual async Task OnSearch()
    {
        SearchCts?.Cancel();
        SearchCts = new CancellationTokenSource();

        try
        {
            await Task.Delay(500, SearchCts.Token);
            if (!SearchCts.Token.IsCancellationRequested)
            {
                await ReloadData();
            }
        }
        catch (TaskCanceledException) { }
    }

    // ==================== M�TODOS CRUD MEJORADOS ====================

    protected virtual async Task CreateItem()
    {
        if (OperationInProgress)
        {
            Snackbar.Add("Operacion en proceso...", Severity.Info);
            return;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
        if (!CanCreate)
        {
            Snackbar.Add("No tienes permisos para crear", Severity.Warning);
            return;
        }

        Console.WriteLine("?? Abriendo di�logo de crear...");
        var dialog = await DialogService.ShowAsync(CreateDialogType, $"Crear {SubModuleName}",
            new DialogOptions { CloseButton = false, MaxWidth = MaxWidth.Medium, FullWidth = true });

        Console.WriteLine("? Esperando resultado del di�logo...");
        var result = await dialog.Result;
        
        if (result == null)
        {
            Console.WriteLine("?? Resultado es null");
            return;
        }
        
        Console.WriteLine($"?? Resultado del di�logo: Canceled={result.Canceled}");
        
        if (!result.Canceled)
        {
            Console.WriteLine("?? Recargando datos...");
            await ReloadData();
            Console.WriteLine("? Datos recargados");
        }
        }
        finally
        {
            OperationInProgress = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    protected virtual async Task EditItem(int id)
    {
        if (OperationInProgress)
        {
            Snackbar.Add("Operacion en proceso...", Severity.Info);
            return;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
        if (!CanUpdate)
        {
            Snackbar.Add("No tienes permisos para editar", Severity.Warning);
            return;
        }

        Console.WriteLine($"?? Abriendo di�logo de editar para ID: {id}");
        var parameters = new DialogParameters { ["Id"] = id };
        var dialog = await DialogService.ShowAsync(EditDialogType, $"Editar {SubModuleName}", parameters,
            new DialogOptions { CloseButton = false, MaxWidth = MaxWidth.Medium, FullWidth = true });

        Console.WriteLine("? Esperando resultado del di�logo...");
        var result = await dialog.Result;
        
        if (result == null)
        {
            Console.WriteLine("?? Resultado es null");
            return;
        }
        
        Console.WriteLine($"?? Resultado del di�logo: Canceled={result.Canceled}, Data={result.Data}");

        if (!result.Canceled)
        {
            Console.WriteLine("?? Recargando datos...");
            await ReloadData();
            Console.WriteLine("? Datos recargados");
        }
        }
        finally
        {
            OperationInProgress = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    protected virtual async Task DeleteItem(int id)
    {
        if (OperationInProgress)
        {
            Snackbar.Add("Operacion en proceso...", Severity.Info);
            return;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
        if (!CanDelete)
        {
            Snackbar.Add("No tienes permisos para eliminar", Severity.Warning);
            return;
        }

        // Obtener el nombre del item para mostrarlo en el di�logo
        var itemName = await GetItemNameForDelete(id);

        var parameters = new DialogParameters
        {
            ["Id"] = id,
            ["ItemName"] = itemName,
            ["DeleteFunc"] = new Func<int, Task<bool>>(async (deleteId) =>
            {
                var result = await ExecuteDelete(deleteId);
                if (result)
                {
                    // FORZAR recarga inmediata
                    await ReloadData();
                }
                return result;
            })
        };

        var dialog = await DialogService.ShowAsync(DeleteDialogType, $"Eliminar {SubModuleName}", parameters,
            new DialogOptions { CloseButton = false, MaxWidth = MaxWidth.Small, FullWidth = true });

        await dialog.Result;
        }
        finally
        {
            OperationInProgress = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    // M�todo para obtener el nombre del item (sobrescribir en cada p�gina)
    protected virtual Task<string> GetItemNameForDelete(int id)
    {
        return Task.FromResult(string.Empty);
    }

    // M�todo que ejecuta la eliminaci�n real
    private async Task<bool> ExecuteDelete(int id)
    {
        try
        {
            Loading = true;
            await InvokeAsync(StateHasChanged);

            var response = await Service.DeleteAsync(id);
            if (response?.Success == true)
            {
                await InvokeAsync(() => Snackbar.Add(response.Message ?? "Elemento eliminado correctamente", Severity.Success));
                return true;
            }
            else
            {
                await InvokeAsync(() => Snackbar.Add(response?.Message ?? "Error al eliminar", Severity.Error));
                return false;
            }
        }
        catch (Exception ex)
        {
            await InvokeAsync(() => Snackbar.Add($"Error: {ex.Message}", Severity.Error));
            return false;
        }
        finally
        {
            Loading = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    // M�todo para recargar datos (sobrescribir en las p�ginas hijas)
    protected virtual async Task ReloadData()
    {
        // Este m�todo ser� sobrescrito en las p�ginas hijas
        await Task.CompletedTask;
    }

    // ==================== FIN M�TODOS CRUD ====================

    protected virtual async Task<List<TResponse>> LoadExportItemsAsync()
    {
        var items = new List<TResponse>();
        var page = 1;
        var sortLabel = string.IsNullOrWhiteSpace(SortLabel) ? GetDefaultSortLabel() : SortLabel;

        while (items.Count < MaxExportRows)
        {
            var response = await Service.GetAllPaginadoAsync(page, ExportPageSize, SearchString, sortLabel, SortDirection);
            if (response?.Success != true)
            {
                throw new InvalidOperationException(response?.Message ?? "No fue posible obtener los datos para exportar.");
            }

            var pageItems = response.Items?.ToList() ?? new List<TResponse>();
            if (pageItems.Count == 0)
            {
                break;
            }

            items.AddRange(pageItems);

            if (items.Count >= response.TotalCount || pageItems.Count < ExportPageSize)
            {
                break;
            }

            page++;
        }

        if (items.Count >= MaxExportRows)
        {
            Snackbar.Add($"La exportacion se limito a {MaxExportRows:N0} registros. Ajusta filtros para exportar menos datos.", Severity.Warning);
        }

        return items;
    }

    protected virtual async Task ExportToExcel()
    {
        if (!CanExport)
        {
            Snackbar.Add("No tienes permisos para exportar", Severity.Warning);
            return;
        }

        if (OperationInProgress)
        {
            Snackbar.Add("Operacion en proceso...", Severity.Info);
            return;
        }

        OperationInProgress = true;
        Loading = true;
        StateHasChanged();

        try
        {
            var exportItems = await LoadExportItemsAsync();

            if (!exportItems.Any())
            {
                Snackbar.Add("No hay datos para exportar", Severity.Warning);
                return;
            }

            var excelData = MapToExcelData(exportItems);

            using var memoryStream = new MemoryStream();
            await memoryStream.SaveAsAsync(excelData);

            var base64 = Convert.ToBase64String(memoryStream.ToArray());

            await JsRuntime.InvokeVoidAsync("downloadFile", base64,
                $"{SubModuleName}_{DateTime.Now:yyyyMMddHHmmss}.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

            Snackbar.Add($"Exportacion exitosa: {exportItems.Count} registros", Severity.Success);
        }
        catch (Exception ex)
        {
            Snackbar.Add($"Error al exportar: {ex.Message}", Severity.Error);
        }
        finally
        {
            Loading = false;
            OperationInProgress = false;
            StateHasChanged();
        }
    }

    protected abstract IEnumerable<object> MapToExcelData(IEnumerable<TResponse> items);

    protected void NavigateToHome() => NavigationManager.NavigateTo("/");
}

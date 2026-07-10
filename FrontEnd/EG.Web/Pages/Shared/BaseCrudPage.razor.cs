using EG.Web.Auth;
using EG.Common;
using EG.Web.Contracts;
using EG.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
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
    [Inject] protected ILogger<BaseCrudPage<TItem, TResponse>> Logger { get; set; } = null!;
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
    protected virtual string BusyMessage => "Hay una operacion en curso. Espera a que termine.";

    protected void NotifyUnexpectedError(Exception exception, string operation, string? userMessage = null)
    {
        Logger.LogError(
            exception,
            "Error en {Operation}. Modulo={Module}; SubModulo={SubModule}",
            operation,
            ModuleName,
            SubModuleName);

        Snackbar.Add(userMessage ?? UserFacingMessages.OperationFailed(operation), Severity.Error);
    }

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
            Snackbar.Add(string.IsNullOrWhiteSpace(busyMessage) ? BusyMessage : busyMessage, Severity.Info);
            return false;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
            await operation();
            return true;
        }
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "ejecutar la operacion");
            return false;
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
            Snackbar.Add(string.IsNullOrWhiteSpace(busyMessage) ? BusyMessage : busyMessage, Severity.Info);
            return busyResult;
        }

        OperationInProgress = true;
        await InvokeAsync(StateHasChanged);

        try
        {
            return await operation();
        }
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "ejecutar la operacion");
            return busyResult;
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
            CanView = AuthProvider.HasPermission(ModuleName, SubModuleName, "view")
                || AuthProvider.HasPermission(ModuleName, SubModuleName, "view-menu");

            if (!CanView)
            {
                HasAccess = false;
                Logger.LogWarning("Acceso denegado. Modulo={Module}; SubModulo={SubModule}", ModuleName, SubModuleName);
                Snackbar.Add("No tienes permisos para consultar esta opcion. Regresaremos al inicio.", Severity.Warning);
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

            HasAccess = true;
        }
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "verificar tus permisos", "No fue posible validar tus permisos. Regresaremos al inicio para proteger tu sesion.");
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
            }
            else
            {
                Elements.Clear();
                TotalCount = 0;
                var message = string.IsNullOrWhiteSpace(response?.Message)
                    ? "No fue posible cargar la informacion. Intenta recargar la pagina."
                    : response.Message;

                Logger.LogWarning(
                    "La carga devolvio un resultado no exitoso. Modulo={Module}; SubModulo={SubModule}; Code={Code}; Message={Message}",
                    ModuleName,
                    SubModuleName,
                    response?.Code,
                    response?.Message);
                Snackbar.Add(message, Severity.Error);
            }

            return new TableData<TResponse>
            {
                Items = Elements,
                TotalItems = TotalCount
            };
        }
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "cargar la informacion", "No fue posible cargar la informacion. Intenta recargar la pagina.");
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
            if (!SearchCts.Token.IsCancellationRequested)
            {
                await ReloadData();
            }
        }
        catch (TaskCanceledException ex)
        {
            Logger.LogDebug(ex, "Se cancelo la busqueda de {SubModule} por una solicitud mas reciente.", SubModuleName);
        }
    }

    // ==================== Mï¿½TODOS CRUD MEJORADOS ====================

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

        var dialog = await DialogService.ShowAsync(CreateDialogType, $"Crear {SubModuleName}",
            new DialogOptions { CloseButton = false, MaxWidth = MaxWidth.Medium, FullWidth = true });

        var result = await dialog.Result;
        
        if (result == null)
        {
            Logger.LogWarning("El dialogo de creacion no devolvio resultado. Modulo={Module}; SubModulo={SubModule}", ModuleName, SubModuleName);
            Snackbar.Add("El formulario se cerro sin devolver una respuesta. Intenta nuevamente.", Severity.Warning);
            return;
        }
        
        
        if (!result.Canceled)
        {
            await ReloadData();
        }
        }
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "abrir o completar el formulario de creacion");
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

        var parameters = new DialogParameters { ["Id"] = id };
        var dialog = await DialogService.ShowAsync(EditDialogType, $"Editar {SubModuleName}", parameters,
            new DialogOptions { CloseButton = false, MaxWidth = MaxWidth.Medium, FullWidth = true });

        var result = await dialog.Result;
        
        if (result == null)
        {
            Logger.LogWarning("El dialogo de edicion no devolvio resultado. Modulo={Module}; SubModulo={SubModule}; Id={Id}", ModuleName, SubModuleName, id);
            Snackbar.Add("El formulario se cerro sin devolver una respuesta. Intenta nuevamente.", Severity.Warning);
            return;
        }
        

        if (!result.Canceled)
        {
            await ReloadData();
        }
        }
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "abrir o completar el formulario de edicion");
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

        // Obtener el nombre del item para mostrarlo en el diï¿½logo
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
        catch (Exception ex)
        {
            NotifyUnexpectedError(ex, "eliminar el registro");
        }
        finally
        {
            OperationInProgress = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    // Mï¿½todo para obtener el nombre del item (sobrescribir en cada pï¿½gina)
    protected virtual Task<string> GetItemNameForDelete(int id)
    {
        return Task.FromResult(string.Empty);
    }

    // Mï¿½todo que ejecuta la eliminaciï¿½n real
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
                var message = string.IsNullOrWhiteSpace(response?.Message)
                    ? "No fue posible eliminar el registro. Verifica que no tenga informacion relacionada."
                    : response.Message;
                Logger.LogWarning(
                    "La eliminacion no fue exitosa. Modulo={Module}; SubModulo={SubModule}; Id={Id}; Code={Code}; Message={Message}",
                    ModuleName,
                    SubModuleName,
                    id,
                    response?.Code,
                    response?.Message);
                await InvokeAsync(() => Snackbar.Add(message, Severity.Error));
                return false;
            }
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error al eliminar. Modulo={Module}; SubModulo={SubModule}; Id={Id}", ModuleName, SubModuleName, id);
            await InvokeAsync(() => Snackbar.Add("No fue posible eliminar el registro. El detalle tecnico quedo registrado.", Severity.Error));
            return false;
        }
        finally
        {
            Loading = false;
            await InvokeAsync(StateHasChanged);
        }
    }

    // Mï¿½todo para recargar datos (sobrescribir en las pï¿½ginas hijas)
    protected virtual async Task ReloadData()
    {
        // Este mï¿½todo serï¿½ sobrescrito en las pï¿½ginas hijas
        await Task.CompletedTask;
    }

    // ==================== FIN Mï¿½TODOS CRUD ====================

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
            NotifyUnexpectedError(ex, "exportar la informacion", "No fue posible generar el archivo. Ajusta los filtros e intenta nuevamente.");
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

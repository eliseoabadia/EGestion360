using EG.Web.Auth;
using EG.Web.Contracs;
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
    //[Inject] protected AuthService AuthService { get; set; } = null!;

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

    // Propiedades de tabla
    protected string SearchString { get; set; } = string.Empty;
    protected bool Loading { get; set; }
    protected int CurrentPage { get; set; }
    protected int PageSize { get; set; } = 10;
    protected SortDirection SortDirection { get; set; }
    protected string SortLabel { get; set; } = string.Empty;
    protected CancellationTokenSource SearchCts { get; set; } = new();

    protected abstract string ModuleName { get; }
    protected abstract string SubModuleName { get; }
    protected abstract Type CreateDialogType { get; }
    protected abstract Type EditDialogType { get; }
    protected abstract Type DeleteDialogType { get; }

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
            CanView = AuthProvider.HasPermission(ModuleName, SubModuleName, "view");

            if (!CanView)
            {
                HasAccess = false;
                StateHasChanged();
                await Task.Delay(2000);
                NavigationManager.NavigateTo("/", forceLoad: true);
                return;
            }

            CanCreate = AuthProvider.HasPermission(ModuleName, SubModuleName, "new");
            CanUpdate = AuthProvider.HasPermission(ModuleName, SubModuleName, "update");
            CanDelete = AuthProvider.HasPermission(ModuleName, SubModuleName, "delete");
            CanExport = AuthProvider.HasPermission(ModuleName, SubModuleName, "CanExportToExcel");

            HasAccess = true;
        }
        catch (Exception ex)
        {
            Snackbar.Add($"Error al verificar permisos: {ex.Message}", Severity.Error);
            await Task.Delay(1000);
            NavigationManager.NavigateTo("/", forceLoad: true);
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
            CurrentPage = state.Page + 1;
            PageSize = state.PageSize;
            SortLabel = state.SortLabel ?? GetDefaultSortLabel();
            SortDirection = state.SortDirection;

            var response = await Service.GetAllPaginadoAsync(
                CurrentPage,
                PageSize,
                SearchString,
                SortLabel,
                SortDirection
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
            Snackbar.Add($"Error: {ex.Message}", Severity.Error);
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
                // Método para recargar - será implementado en las páginas hijas
            }
        }
        catch (TaskCanceledException) { }
    }

    protected virtual async Task CreateItem()
    {
        if (!CanCreate)
        {
            Snackbar.Add("No tienes permisos para crear", Severity.Warning);
            return;
        }

        var dialog = await DialogService.ShowAsync(CreateDialogType, $"Crear {SubModuleName}",
            new DialogOptions { CloseButton = true, MaxWidth = MaxWidth.Medium, FullWidth = true });

        var result = await dialog.Result;
        if (!result!.Canceled)
        {
            // Método para recargar - será implementado en las páginas hijas
        }
    }

    protected virtual async Task EditItem(int id)
    {
        if (!CanUpdate)
        {
            Snackbar.Add("No tienes permisos para editar", Severity.Warning);
            return;
        }

        var parameters = new DialogParameters { ["Id"] = id };
        var dialog = await DialogService.ShowAsync(EditDialogType, $"Editar {SubModuleName}", parameters,
            new DialogOptions { CloseButton = true, MaxWidth = MaxWidth.Medium, FullWidth = true });

        var result = await dialog.Result;
        if (!result!.Canceled)
        {
            // Método para recargar - será implementado en las páginas hijas
        }
    }

    protected virtual async Task DeleteItem(int id)
    {
        if (!CanDelete)
        {
            Snackbar.Add("No tienes permisos para eliminar", Severity.Warning);
            return;
        }

        var parameters = new DialogParameters { ["Id"] = id };
        var dialog = await DialogService.ShowAsync(DeleteDialogType, $"Eliminar {SubModuleName}", parameters,
            new DialogOptions { CloseButton = true, MaxWidth = MaxWidth.Small, FullWidth = true });

        var result = await dialog.Result;
        if (!result!.Canceled)
        {
            // Método para recargar - será implementado en las páginas hijas
        }
    }

    protected virtual async Task ExportToExcel()
    {
        if (!CanExport)
        {
            Snackbar.Add("No tienes permisos para exportar", Severity.Warning);
            return;
        }

        Loading = true;
        StateHasChanged();

        try
        {
            var response = await Service.GetAllPaginadoAsync(1, int.MaxValue, SearchString, SortLabel, SortDirection);

            if (response?.Success != true || response.Items == null || !response.Items.Any())
            {
                Snackbar.Add(response?.Message ?? "No hay datos para exportar", Severity.Warning);
                return;
            }

            var excelData = MapToExcelData(response.Items);

            using var memoryStream = new MemoryStream();
            await memoryStream.SaveAsAsync(excelData);

            var base64 = Convert.ToBase64String(memoryStream.ToArray());

            await JsRuntime.InvokeVoidAsync("downloadFile", base64,
                $"{SubModuleName}_{DateTime.Now:yyyyMMddHHmmss}.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

            Snackbar.Add($"✅ Exportación exitosa: {response.Items.Count()} registros", Severity.Success);
        }
        catch (Exception ex)
        {
            Snackbar.Add($"Error al exportar: {ex.Message}", Severity.Error);
        }
        finally
        {
            Loading = false;
            StateHasChanged();
        }
    }

    protected abstract IEnumerable<object> MapToExcelData(IEnumerable<TResponse> items);

    protected void NavigateToHome() => NavigationManager.NavigateTo("/");
}
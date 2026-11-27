using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Common.Modules;
using EG.Dommain.DTOs.Responses;
using EG.Web.Auth;
using EG.Web.Contracts.Configuration;
using EG.Web.Helpers;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using MiniExcelLibs;
using MudBlazor;
using CreateMenuDialog = EG.Web.Pages.Platform.Sistema.Menu.CrearMenu;
using EditMenuDialog = EG.Web.Pages.Platform.Sistema.Menu.EditarMenu;
using DeleteMenuDialog = EG.Web.Pages.Platform.Sistema.Menu.EliminarMenu;

namespace EG.Web.Pages.Platform.Sistema.Menu;

public partial class Menus
{
    [Inject] private AuthenticationProviderJWT AuthProvider { get; set; } = null!;
    [Inject] private IMenuExportService ExportService { get; set; } = null!;
    private GenericDataGrid<MenuItemsResponse> mudTableRef = null!;
    private bool _isInitialized;
    private bool _hasAccess;
    private bool _canCreate;
    private bool _canUpdate;
    private bool _canDelete;
    private bool _canExport;
    private bool exporting;
    private bool disposed;
    private int loadVersion;
    private const int pageSize = 10;
    private string searchString = string.Empty;
    private string sortLabel = nameof(MenuItemsResponse.Orden);
    private SortDirection sortDirection;
    private string? loadError;

    protected override void OnInitialized()
    {
        _hasAccess = Can(PermissionAction.View);
        _canCreate = Can(PermissionAction.New);
        _canUpdate = Can(PermissionAction.Update);
        _canDelete = Can(PermissionAction.Delete);
        _canExport = Can(PermissionAction.CanExportToExcel);
        _isInitialized = true;
    }

    private bool Can(PermissionAction action) => AuthProvider.HasPermission(
        MenuModule.Group, MenuModule.SubGroup, action.ToClaimValue());

    private void NavigateToHome() => NavigationManager.NavigateTo("/");

    private async Task<TableData<MenuItemsResponse>> LoadServerData(TableState state, CancellationToken cancellationToken)
    {
        var version = ++loadVersion;
        loadError = null;
        sortLabel = state.SortLabel ?? nameof(MenuItemsResponse.Orden);
        sortDirection = state.SortDirection;
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            var response = await _service.GetAllPaginadoAsync(state.Page + 1, state.PageSize, searchString, sortLabel, sortDirection);
            cancellationToken.ThrowIfCancellationRequested();
            if (disposed || version != loadVersion)
                throw new OperationCanceledException();
            if (response?.Success == true)
                return new() { Items = response.Items, TotalItems = response.TotalCount };
            loadError = response?.Message ?? "No fue posible cargar los menús. Intenta actualizar la lista.";
            return new() { Items = [], TotalItems = 0 };
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception exception)
        {
            if (!disposed && version == loadVersion)
                loadError = UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception);
            return new() { Items = [], TotalItems = 0 };
        }
        finally
        {
            if (!disposed && version == loadVersion)
                await InvokeAsync(StateHasChanged);
        }
    }

    private Task CrearMenu() => _canCreate
        ? OpenDialogAsync<CreateMenuDialog>("Nuevo menú", new()) : Task.CompletedTask;

    private Task CrearHijoMenu(int id, string parentName) => _canCreate
        ? OpenDialogAsync<CreateMenuDialog>("Nuevo submenú", new() { [nameof(CreateMenuDialog.MenuIdPadre)] = id, [nameof(CreateMenuDialog.NombreMenuPadre)] = parentName })
        : Task.CompletedTask;

    private Task EditarMenu(int id) => _canUpdate
        ? OpenDialogAsync<EditMenuDialog>("Editar menú", new() { [nameof(EditMenuDialog.MenuId)] = id }) : Task.CompletedTask;

    private Task EliminarMenu(int id) => _canDelete
        ? OpenDialogAsync<DeleteMenuDialog>("Eliminar menú", new() { [nameof(DeleteMenuDialog.MenuId)] = id }) : Task.CompletedTask;

    private async Task OpenDialogAsync<TDialog>(string title, DialogParameters parameters) where TDialog : IComponent
    {
        try
        {
            var dialog = await DialogService.ShowAsync<TDialog>(title, parameters,
                new DialogOptions { CloseButton = false, FullWidth = true, MaxWidth = MaxWidth.Medium });
            var result = await dialog.Result;
            if (!disposed && result?.Canceled == false)
                await mudTableRef.ReloadData();
        }
        catch (Exception exception)
        {
            if (!disposed)
                Snackbar.Add(UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception), Severity.Error);
        }
    }

    private async Task ExportarExcel()
    {
        if (!_canExport || exporting)
            return;
        exporting = true;
        try
        {
            var response = await ExportService.ExportAsync(new PagedRequest
            {
                Filtro = searchString,
                SortLabel = sortLabel,
                SortDirection = sortDirection.ToString()
            });
            if (disposed)
                return;
            if (response?.Success != true)
            {
                Snackbar.Add(response?.Message ?? "No fue posible exportar los menús.", Severity.Error);
                return;
            }
            if (response.Items.Count == 0)
            {
                Snackbar.Add("No hay menús para exportar con esta búsqueda.", Severity.Info);
                return;
            }
            var rows = response.Items.Select(menu => new
            {
                Nombre = menu.Nombre,
                Tipo = menu.TipoDescripcion,
                MenuPadre = menu.NombreMenuPadre ?? "-",
                Ruta = menu.Ruta ?? "-",
                Orden = menu.Orden,
                Validacion = menu.ValidacionEstructura
            }).ToList();
            using var stream = new MemoryStream();
            await stream.SaveAsAsync(EG.Web.Services.ExportProjectionSanitizer.RemoveInternalIdentifiers(rows));
            if (disposed)
                return;
            await _jsRuntime.InvokeVoidAsync("downloadFile", Convert.ToBase64String(stream.ToArray()),
                $"Menus_{DateTime.Now:yyyyMMddHHmmss}.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            Snackbar.Add($"Se exportaron {rows.Count} menús.", Severity.Success);
        }
        catch (Exception exception)
        {
            if (!disposed)
                Snackbar.Add(UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception), Severity.Error);
        }
        finally
        {
            exporting = false;
        }
    }

    public void Dispose()
    {
        disposed = true;
        loadVersion++;
    }
}

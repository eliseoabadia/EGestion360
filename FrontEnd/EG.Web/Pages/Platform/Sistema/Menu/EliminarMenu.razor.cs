using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts;
using EG.Web.Helpers;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Platform.Sistema.Menu;

public partial class EliminarMenu : IDisposable
{
    [Parameter] public int MenuId { get; set; }
    [Inject] private IGenericCrudService<MenuItemsResponse> Service { get; set; } = null!;
    [Inject] private ISnackbar Snackbar { get; set; } = null!;
    private BaseCrudDialog<MenuItemsResponse> dialog = null!;
    private MenuItemsResponse? menu;
    private bool loading;
    private bool disposed;
    private int loadVersion;

    protected override Task OnParametersSetAsync() => LoadMenuAsync();

    private async Task LoadMenuAsync()
    {
        var version = ++loadVersion;
        loading = true;
        menu = null;
        try
        {
            var response = await Service.GetByIdAsync(MenuId);
            if (!disposed && version == loadVersion && response?.Success == true)
                menu = response.Data;
        }
        catch (Exception exception)
        {
            if (!disposed && version == loadVersion)
                Snackbar.Add(UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception), Severity.Error);
        }
        finally
        {
            if (!disposed && version == loadVersion)
                loading = false;
        }
    }

    private async Task DeleteMenuAsync()
    {
        if (loading || menu == null || menu.TieneSubmenus > 0)
            return;
        try
        {
            var response = await Service.DeleteAsync(MenuId);
            if (disposed)
                return;
            if (response?.Success == true)
                dialog.SignalClose(true);
            else
                Snackbar.Add(response?.Message ?? "No fue posible eliminar el menú.", Severity.Error);
        }
        catch (Exception exception)
        {
            if (!disposed)
                Snackbar.Add(UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception), Severity.Error);
        }
    }

    public void Dispose() => disposed = true;
}

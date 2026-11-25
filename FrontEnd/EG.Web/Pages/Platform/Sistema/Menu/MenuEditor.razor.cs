using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts;
using EG.Web.Extensions;
using EG.Web.Helpers;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Platform.Sistema.Menu;

public partial class MenuEditor
{
    [Parameter] public int? MenuId { get; set; }
    [Parameter] public int? ParentId { get; set; }
    [Parameter] public string? ParentName { get; set; }
    [Inject] private IGenericCrudService<MenuItemsResponse> Service { get; set; } = null!;
    [Inject] private ISnackbar Snackbar { get; set; } = null!;

    private BaseCrudDialog<MenuItemsResponse> dialog = null!;
    private BaseEntityForm<MenuItemsResponse> form = null!;
    private MenuItemsResponse menu = new();
    private IconosDisponibles.IconoItem? selectedIcon;
    private bool iconChanged;
    private IconosDisponibles.IconoItem? SelectedIcon
    {
        get => selectedIcon;
        set
        {
            if (ReferenceEquals(selectedIcon, value))
                return;
            selectedIcon = value;
            iconChanged = true;
        }
    }
    private bool loading;
    private bool loaded;
    private bool saving;
    private bool disposed;
    private int loadVersion;
    private string loadError = string.Empty;
    private string ContextDescription => !string.IsNullOrWhiteSpace(ParentName)
        ? $"Submenú de {ParentName}"
        : MenuId.HasValue ? "Actualiza el nombre, la navegación y la presentación." : "Agrega una pantalla al menú de la aplicación.";

    protected override Task OnParametersSetAsync() => LoadMenuAsync();

    private async Task LoadMenuAsync()
    {
        var version = ++loadVersion;
        loading = true;
        loaded = false;
        try
        {
            if (MenuId.HasValue)
            {
                var response = await Service.GetByIdAsync(MenuId.Value);
                if (disposed || version != loadVersion)
                    return;
                if (response?.Success != true || response.Data == null)
                {
                    loadError = string.IsNullOrWhiteSpace(response?.Message) ? "No fue posible cargar el menú." : response.Message;
                    return;
                }
                menu = response.Data;
            }
            else
            {
                menu = new() { Nombre = string.Empty, Ruta = string.Empty, Tipo = 2, Orden = 0, Activo = true, FkidMenuSis = ParentId };
            }
            selectedIcon = IconosDisponibles.Lista.FirstOrDefault(icon => icon.Valor == menu.ImageUrl);
            iconChanged = false;
            loaded = true;
        }
        catch (Exception exception)
        {
            if (!disposed && version == loadVersion)
                loadError = UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception);
        }
        finally
        {
            if (!disposed && version == loadVersion)
                loading = false;
        }
    }

    private static string? ValidateName(string value) => string.IsNullOrWhiteSpace(value) || value.Trim().Length < 2
        ? "Escribe un nombre de al menos dos caracteres." : null;

    private static Task<IEnumerable<IconosDisponibles.IconoItem>> SearchIconsAsync(string value, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        IEnumerable<IconosDisponibles.IconoItem> icons = IconosDisponibles.Lista;
        if (!string.IsNullOrWhiteSpace(value))
            icons = icons.Where(icon => icon.Nombre.Contains(value, StringComparison.OrdinalIgnoreCase) ||
                icon.Valor.Contains(value, StringComparison.OrdinalIgnoreCase) || icon.Categoria.Contains(value, StringComparison.OrdinalIgnoreCase));
        return Task.FromResult(icons.Take(50));
    }

    private async Task SaveMenuAsync()
    {
        if (saving || !loaded || loading || !await form.ValidateAsync())
            return;
        saving = true;
        try
        {
            menu.Nombre = menu.Nombre.Trim();
            menu.Ruta = menu.Tipo == 1 ? "/" : menu.Ruta.Trim();
            if (iconChanged || !MenuId.HasValue)
                menu.ImageUrl = selectedIcon?.Valor ?? string.Empty;
            var response = MenuId.HasValue
                ? await Service.UpdateAsync(menu, MenuId.Value)
                : await Service.CreateAsync(menu);
            if (disposed)
                return;
            if (response?.Success == true)
                dialog.SignalClose(true);
            else
                Snackbar.Add(response?.Message ?? "No fue posible guardar el menú.", Severity.Error);
        }
        catch (Exception exception)
        {
            if (!disposed)
                Snackbar.Add(UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception), Severity.Error);
        }
        finally
        {
            saving = false;
        }
    }

    public void Dispose() => disposed = true;
}

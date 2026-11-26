using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using MudBlazor;

namespace EG.Web.Pages.Platform.Account;

public partial class SelectSucursalDialog
{
    [Parameter] public List<UsuarioSucursalResponse> Sucursales { get; set; } = [];
    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; } = null!;
    private bool selecting;
    private string? selectionError;

    private async Task SelectBranchAsync(UsuarioSucursalResponse branch)
    {
        if (selecting) return;
        if (branch.IdSucursal <= 0 || !Sucursales.Contains(branch) || GetCompanyId(branch) is not > 0)
        {
            selectionError = "La sucursal no tiene una empresa válida. Contacta al administrador.";
            return;
        }

        selecting = true;
        selectionError = null;
        try
        {
            await SucursalStateService.SetSucursalAsync(
                branch.IdSucursal,
                branch.NombreSucursal ?? string.Empty,
                GetCompanyId(branch),
                branch.NombreEmpresa);
            MudDialog.Close(DialogResult.Ok(branch));
        }
        catch (Exception exception)
        {
            AppLoggerFactory.CreateLogger(nameof(SelectSucursalDialog))
                .LogWarning(exception, "No se pudo completar la selección de sucursal.");
            selectionError = "No fue posible guardar la selección. Revisa el almacenamiento del navegador e intenta nuevamente.";
        }
        finally
        {
            selecting = false;
        }
    }

    private static int? GetCompanyId(UsuarioSucursalResponse branch) =>
        branch.PkidEmpresa > 0 ? branch.PkidEmpresa : branch.IdEmpresa > 0 ? branch.IdEmpresa : null;
}

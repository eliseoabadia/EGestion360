using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Shared;

public partial class BaseEntityForm<TEntity> where TEntity : class, new()
{
    [Parameter] public RenderFragment? ChildContent { get; set; }
    [Parameter] public bool ShowHeader { get; set; } = true;
    [Parameter] public string HeaderTitle { get; set; } = string.Empty;
    [Parameter] public string HeaderSubtitle { get; set; } = "Completa la información solicitada para continuar.";
    [Parameter] public string HeaderIcon { get; set; } = Icons.Material.Filled.EditNote;
    [Parameter] public bool Loading { get; set; }
    [Parameter] public string LoadingMessage { get; set; } = "Preparando formulario...";
    [Parameter] public int LoadingSkeletonRows { get; set; } = 8;
    [Parameter] public bool? CatalogMode { get; set; }
    
    [CascadingParameter(Name = "BaseDialog")] 
    private ICrudDialogFormHost? BaseDialog { get; set; }
    
    private MudForm mudForm = new();
    private bool InsideDialog => BaseDialog != null;
    private bool ShouldShowHeader => ShowHeader && BaseDialog == null;
    private string CardCssClass => InsideDialog
        ? "entity-form-card entity-form-card-dialog eae-entity-form"
        : "entity-form-card entity-form-card-standalone eae-entity-form";
    private bool IsCatalogContext => CatalogMode ?? IsCatalogRoute();
    private string ContentCssClass => IsCatalogContext
        ? "entity-form-content entity-form-content-catalog"
        : "entity-form-content entity-form-content-structured";

    private bool IsCatalogRoute()
    {
        var path = Navigation.ToBaseRelativePath(Navigation.Uri);
        return path.Contains("configuracion/", StringComparison.OrdinalIgnoreCase)
            || path.Contains("configuration/", StringComparison.OrdinalIgnoreCase);
    }
    
    // Propiedades para acceder al estado del formulario
    public bool IsValid => mudForm.IsValid;
    public IEnumerable<string> Errors => mudForm.Errors;
    
    protected override void OnInitialized()
    {
        // Registrar este formulario en el diálogo base
        BaseDialog?.RegisterComponent(this);
    }

    public void Dispose() => BaseDialog?.UnregisterComponent(this);
    
    // Métodos públicos para interactuar con el formulario
    public async Task<bool> ValidateAsync()
    {
        await mudForm.Validate();
        return mudForm.IsValid;
    }
    
    // ResetValidation no está disponible en MudForm de MudBlazor 8
    // public void ResetValidation()
    // {
    //     mudForm.Reset();
    // }
    
    // Método para validación asíncrona personalizada
    public async Task<bool> ValidateWithCustomRules(Func<Task<bool>> customValidation)
    {
        await mudForm.Validate();
        
        if (!mudForm.IsValid)
            return false;
            
        return await customValidation();
    }
}

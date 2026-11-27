using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Shared;

public partial class BaseCrudDialog<TItem>
{
    [Parameter] public RenderFragment? ChildContent { get; set; }
    [Parameter] public string Title { get; set; } = string.Empty;
    [Parameter] public string? Subtitle { get; set; }
    [Parameter] public string? TitleIcon { get; set; }
    [Parameter] public MaxWidth MaxWidth { get; set; } = MaxWidth.Medium;
    [Parameter] public string? DialogId { get; set; }
    [Parameter] public string? DialogClass { get; set; }
    [Parameter] public Color ActionColor { get; set; } = Color.Primary;
    [Parameter] public string ActionIcon { get; set; } = Icons.Material.Filled.Save;
    [Parameter] public string ActionText { get; set; } = EG.Common.ApplicationText.Actions.Save;
    [Parameter] public string CancelText { get; set; } = EG.Common.ApplicationText.Actions.Cancel;
    [Parameter] public string ProcessingText { get; set; } = EG.Common.ApplicationText.Status.Saving;
    [Parameter] public string LoadingMessage { get; set; } = "Cargando...";
    [Parameter] public bool CanConfirm { get; set; } = true;
    [Parameter] public bool ShowConfirmButton { get; set; } = true;
    [Parameter] public bool? CatalogMode { get; set; }
    [Parameter] public EventCallback<bool> OnConfirm { get; set; }  // Señal de confirmación con resultado (bool)
    [Parameter] public EventCallback OnCancel { get; set; }
    // Nota: el cierre se notifica al padre mediante SignalClose(success)

    [CascadingParameter] private IMudDialogInstance MudDialog { get; set; } = null!;

    private bool loading = true;
    private bool isProcessing = false;
    private bool _closed = false;
    private Dictionary<string, object> _registeredComponents = new();
    private string DialogCssClass => string.IsNullOrWhiteSpace(DialogClass)
        ? $"crud-dialog eae-form-dialog eae-dialog-{MaxWidth.ToString().ToLowerInvariant()}"
        : $"crud-dialog eae-form-dialog eae-dialog-{MaxWidth.ToString().ToLowerInvariant()} {DialogClass}";
    private bool IsCatalogContext => CatalogMode ?? IsCatalogRoute();
    private string DialogShellCssClass => IsCatalogContext
        ? "crud-dialog-shell crud-dialog-shell-catalog"
        : "crud-dialog-shell crud-dialog-shell-structured";
    private string EffectiveTitleIcon => !string.IsNullOrWhiteSpace(TitleIcon)
        ? TitleIcon!
        : ResolveTitleIcon(Title);
    private string EffectiveSubtitle => !string.IsNullOrWhiteSpace(Subtitle)
        ? Subtitle!
        : ResolveSubtitle(Title);
    private string OperationKey => ResolveOperationKey(Title, ActionText);
    private string OperationState => OperationKey switch
    {
        "alta" => "ALTA DE REGISTRO",
        "cambio" => "ACTUALIZACIÓN",
        "baja" => "BAJA CONTROLADA",
        "consulta" => "CONSULTA",
        "autorizacion" => "VALIDACIÓN",
        _ => "GESTIÓN DE REGISTRO"
    };
    private bool IsCatalogRoute()
    {
        var path = Navigation.ToBaseRelativePath(Navigation.Uri);
        return path.Contains("configuracion/", StringComparison.OrdinalIgnoreCase)
            || path.Contains("configuration/", StringComparison.OrdinalIgnoreCase);
    }

    private static string ResolveTitleIcon(string title)
    {
        var value = title?.Trim() ?? string.Empty;

        if (ContainsAny(value, "eliminar", "borrar", "cancelar"))
            return Icons.Material.Filled.DeleteOutline;
        if (ContainsAny(value, "autorizar", "aprobar", "firmar", "validar"))
            return Icons.Material.Filled.Verified;
        if (ContainsAny(value, "editar", "actualizar", "modificar"))
            return Icons.Material.Filled.EditNote;
        if (ContainsAny(value, "nuevo", "nueva", "crear", "agregar", "registrar"))
            return Icons.Material.Filled.AddCircleOutline;
        if (ContainsAny(value, "ver ", "detalle", "consultar", "consulta"))
            return Icons.Material.Filled.Visibility;

        return Icons.Material.Filled.Description;
    }

    private static string ResolveOperationKey(string title, string actionText)
    {
        var value = title;

        if (ContainsAny(value, "eliminar", "borrar", "cancelar", "eliminando"))
            return "baja";
        if (ContainsAny(value, "autorizar", "aprobar", "firmar", "validar"))
            return "autorizacion";
        if (ContainsAny(value, "editar", "actualizar", "modificar"))
            return "cambio";
        if (ContainsAny(value, "nuevo", "nueva", "crear", "agregar", "registrar"))
            return "alta";
        if (ContainsAny(value, "ver ", "detalle", "consultar", "consulta"))
            return "consulta";

        if (ContainsAny(actionText, "actualizar", "modificar"))
            return "cambio";
        if (ContainsAny(actionText, "crear", "guardar", "agregar"))
            return "alta";

        return "gestion";
    }

    private static string ResolveSubtitle(string title)
    {
        var value = title?.Trim() ?? string.Empty;

        if (ContainsAny(value, "eliminar", "borrar"))
            return "Confirma la operación antes de continuar.";
        if (ContainsAny(value, "autorizar", "aprobar", "firmar", "validar"))
            return "Revisa la información y confirma la operación.";
        if (ContainsAny(value, "editar", "actualizar", "modificar"))
            return "Actualiza únicamente la información necesaria.";
        if (ContainsAny(value, "nuevo", "nueva", "crear", "agregar", "registrar"))
            return "Captura la información solicitada para continuar.";
        if (ContainsAny(value, "ver ", "detalle", "consultar", "consulta"))
            return "Consulta la información registrada y su detalle.";

        return "Revisa y completa la información de esta operación.";
    }

    private static bool ContainsAny(string value, params string[] terms) =>
        terms.Any(term => value.Contains(term, StringComparison.OrdinalIgnoreCase));

    protected override async Task OnInitializedAsync()
    {
        await MudDialog.SetOptionsAsync(MudDialog.Options with
        {
            MaxWidth = MaxWidth,
            FullWidth = true
        });
        // No ejecutar LoadDataAsync aquí para evitar ejecución doble
        // El loading se maneja en OnAfterRender o manualmente
        loading = false;
    }

    // Parametro de cierre: hijos pueden notificar éxito o fallo
    public void SignalClose(bool success)
    {
        if (_closed)
        {
            return;
        }

        if (MudDialog == null)
        {
            return;
        }
        _closed = true;
        if (success)
        {
            MudDialog.Close(DialogResult.Ok(true));
        }
        else
        {
            MudDialog.Close(DialogResult.Cancel());
        }
    }

    protected virtual Task LoadDataAsync() => Task.CompletedTask;

    protected async Task OnConfirmar()
    {
        if (isProcessing || _closed || !CanConfirm)
        {
            return;
        }

        // Verificar que OnConfirm tiene un handler
        if (!OnConfirm.HasDelegate)
        {
            Close(true);
            return;
        }

        isProcessing = true;
        var originalOptions = MudDialog.Options;
        StateHasChanged();

        try
        {
            await MudDialog.SetOptionsAsync(originalOptions with
            {
                BackdropClick = false,
                CloseOnEscapeKey = false,
                CloseButton = false
            });
            await OnConfirm.InvokeAsync(true);
        }
        catch (Exception exception)
        {
            Logger.LogError(exception, "No se pudo confirmar el formulario {Title}", Title);
            Snackbar.Add("No fue posible guardar la información. Revisa los datos e intenta nuevamente.", Severity.Error);
        }
        finally
        {
            isProcessing = false;
            // Solo llamar StateHasChanged si el diálogo no fue cerrado durante la operación
            if (!_closed)
            {
                await MudDialog.SetOptionsAsync(originalOptions);
                StateHasChanged();
            }
        }
    }

    public void Cancelar()
    {
        if (isProcessing || _closed)
        {
            return;
        }

        _closed = true;
        MudDialog.Close(DialogResult.Cancel());
    }

    public void Close(bool success = true)
    {
        if (_closed)
        {
            return;
        }

        _closed = true;
        if (success)
            MudDialog.Close(DialogResult.Ok(true));
        else
            MudDialog.Close(DialogResult.Cancel());
    }

    public void RegisterComponent(string key, object component)
    {
        _registeredComponents[key] = component;
    }

    public TComponent? GetComponent<TComponent>(string key) where TComponent : class
    {
        return _registeredComponents.TryGetValue(key, out var component)
            ? component as TComponent
            : null;
    }

    private object? _lastRegistered;

    public void RegisterComponent(object component)
    {
        _lastRegistered = component;
    }

    public void UnregisterComponent(object component)
    {
        if (ReferenceEquals(_lastRegistered, component))
        {
            _lastRegistered = null;
        }

        foreach (var key in _registeredComponents.Where(entry => ReferenceEquals(entry.Value, component))
                     .Select(entry => entry.Key).ToArray())
        {
            _registeredComponents.Remove(key);
        }
    }

    public void Dispose()
    {
        _closed = true;
        _lastRegistered = null;
        _registeredComponents.Clear();
    }

    public TComponent? GetComponent<TComponent>() where TComponent : class
    {
        return _lastRegistered as TComponent;
    }
}

using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Web.Helpers;
using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Presupuesto.Tesoreria.CuentasXCobrar.ModificadoIngreso;

public partial class ModificadoIngresoDialog : IDisposable
{
    [Parameter] public int? Id { get; set; }
    [Parameter] public int TipoAdecuacionId { get; set; }
    [Parameter] public int AnioId { get; set; }

    private BaseCrudDialog<IngreAdecuacionResponse> dialog = null!;
    private BaseEntityForm<IngreAdecuacionResponse> form = null!;
    private readonly EditorRequestState load = new();
    private IngreAdecuacionResponse item = new();
    private DateTime? _fecha;
    private bool saving;
    private int requestVersion;

    private string DialogTitle => Id.HasValue ? "Editar modificación de ingresos" : "Nueva modificación de ingresos";
    private string ActionText => Id.HasValue ? "Actualizar" : "Crear";
    private string ProcessingText => Id.HasValue ? "Actualizando..." : "Creando...";
    private string TipoTexto => TipoAdecuacionId switch
    {
        1 => "Adecuación compensada",
        2 => "Reducción",
        3 => "Aumento",
        _ => "Adecuación"
    };

    protected override Task OnParametersSetAsync() => LoadAsync();

    private async Task LoadAsync()
    {
        var version = load.Begin();
        requestVersion = version;
        try
        {
            await AnioStateService.InitializeAsync();
            if (!load.IsCurrent(version))
                return;
            if (AnioId <= 0 || AnioStateService.AnioId != AnioId)
            {
                load.Fail(version, "Selecciona un ejercicio presupuestal válido antes de capturar.");
                return;
            }
            if (!Id.HasValue)
            {
                item = new()
                {
                    Activo = true,
                    Fecha = DateOnly.FromDateTime(DateTime.Today),
                    FkidTipoAdecuacionPres = TipoAdecuacionId,
                    FkidAnioSis = AnioId,
                    FkidEstatusAdecuacionPres = 1,
                    FkidAccionAdecuacionMasterPres = 1
                };
            }
            else
            {
                var response = await Service.GetByIdAsync(Id.Value);
                if (!load.IsCurrent(version))
                    return;
                if (response?.Success != true || response.Data == null)
                {
                    load.Fail(version, response?.Message);
                    return;
                }
                if (response.Data.FkidAnioSis != AnioId || response.Data.FkidTipoAdecuacionPres != TipoAdecuacionId)
                {
                    load.Fail(version, "La adecuación no corresponde al ejercicio y tipo seleccionados.");
                    return;
                }
                item = response.Data;
            }
            _fecha = item.Fecha.ToDateTime(TimeOnly.MinValue);
            load.Complete(version);
        }
        catch (Exception exception)
        {
            load.Fail(version, UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception));
        }
    }

    private static string? ValidateDate(DateTime? date) => BudgetCaptureUi.ValidateDate(date);

    private async Task SaveAsync()
    {
        if (!load.IsReady || saving)
            return;
        var version = requestVersion;
        saving = true;
        try
        {
            if (!await form.ValidateAsync())
                return;
            await AnioStateService.InitializeAsync();
            if (!load.IsCurrent(version))
                return;
            if (AnioId <= 0 || AnioStateService.AnioId != AnioId)
            {
                Snackbar.Add("El ejercicio presupuestal cambió; cierra y vuelve a abrir la captura.", Severity.Warning);
                return;
            }
            var dateError = ValidateDate(_fecha);
            if (dateError != null)
            {
                Snackbar.Add(dateError, Severity.Warning);
                return;
            }
            item.FkidAnioSis = AnioId;
            item.FkidTipoAdecuacionPres = TipoAdecuacionId;
            item.Fecha = DateOnly.FromDateTime(_fecha!.Value);
            item.Justificacion = item.Justificacion?.Trim();
            var response = Id.HasValue ? await Service.UpdateAsync(item, Id.Value) : await Service.CreateAsync(item);
            if (!load.IsCurrent(version))
                return;
            if (response?.Success == true)
            {
                Snackbar.Add("Adecuación guardada correctamente.", Severity.Success);
                dialog.SignalClose(true);
            }
            else
            {
                Snackbar.Add(string.IsNullOrWhiteSpace(response?.Message) ? "No fue posible guardar la adecuación." : response.Message, Severity.Error);
            }
        }
        catch (Exception exception)
        {
            if (load.IsCurrent(version))
                Snackbar.Add(UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception), Severity.Error);
        }
        finally
        {
            saving = false;
        }
    }

    public void Dispose() => load.Dispose();
}

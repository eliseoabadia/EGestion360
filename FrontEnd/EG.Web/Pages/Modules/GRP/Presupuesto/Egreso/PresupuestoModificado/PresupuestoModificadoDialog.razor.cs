using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Web.Helpers;
using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Presupuesto.Egreso.PresupuestoModificado;

public partial class PresupuestoModificadoDialog : IDisposable
{
    [Parameter] public int? Id { get; set; }
    [Parameter] public int TipoAdecuacionId { get; set; }
    [Parameter] public int AnioId { get; set; }

    private BaseCrudDialog<EgreAdecuacionResponse> dialog = null!;
    private BaseEntityForm<EgreAdecuacionResponse> form = null!;
    private readonly EditorRequestState load = new();
    private EgreAdecuacionResponse item = new();
    private DateTime? _fecha;
    private bool saving;
    private int requestVersion;

    private string dialogTitle => Id.HasValue ? "Editar presupuesto modificado" : "Nuevo presupuesto modificado";
    private string actionText => Id.HasValue ? EG.Common.ApplicationText.Actions.Update : EG.Common.ApplicationText.Actions.Create;
    private string processingText => Id.HasValue ? EG.Common.ApplicationText.Status.Updating : EG.Common.ApplicationText.Status.Creating;
    private string TipoTexto => TipoAdecuacionId switch
    {
        1 => "Adecuación compensada",
        2 => "Reducción",
        3 => "Ampliación",
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
            if (AnioId <= 0 || AnioStateService.AnioId != AnioId || AnioStateService.AnioClave is not (>= 1 and <= 9999))
            {
                load.Fail(version, "Selecciona un ejercicio presupuestal válido antes de capturar.");
                return;
            }
            if (!Id.HasValue)
            {
                item = new()
                {
                    Activo = true,
                    FkidTipoAdecuacionPres = TipoAdecuacionId,
                    FkidAnioSis = AnioId,
                    FkidEstatusAdecuacionPres = 1,
                    FkidAccionAdecuacionMasterPres = 1,
                    Fecha = new DateOnly(AnioStateService.AnioClave.Value, 1, 1)
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

    private string? ValidateDate(DateTime? date) => BudgetCaptureUi.ValidateDate(date, AnioStateService.AnioClave);

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
            if (AnioId <= 0 || AnioStateService.AnioId != AnioId || AnioStateService.AnioClave is not > 0)
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
                Snackbar.Add(string.IsNullOrWhiteSpace(response?.Message) ? "No fue posible guardar." : response.Message, Severity.Error);
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

    private void ApplyBold() => ApplyFormat("**texto importante**");
    private void ApplyBulletList() => ApplyFormat("- Punto principal" + Environment.NewLine + "- Punto adicional");
    private void ApplyNumberedList() => ApplyFormat("1. Primer punto" + Environment.NewLine + "2. Segundo punto");
    private void ApplyParagraph() => ApplyFormat("Título:" + Environment.NewLine + "Detalle de la justificación...");

    private void ApplyFormat(string snippet)
    {
        if (saving)
            return;
        var current = item.Justificacion?.TrimEnd() ?? string.Empty;
        var separator = string.IsNullOrWhiteSpace(current) ? string.Empty : Environment.NewLine;
        item.Justificacion = current + separator + snippet;
    }

    public void Dispose() => load.Dispose();
}

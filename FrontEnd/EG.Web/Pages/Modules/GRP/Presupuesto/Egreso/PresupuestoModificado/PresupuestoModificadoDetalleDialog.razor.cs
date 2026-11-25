using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Web.Helpers;
using EG.Web.Models;
using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Presupuesto.Egreso.PresupuestoModificado;

public partial class PresupuestoModificadoDetalleDialog : IDisposable
{
    [Parameter] public int? Id { get; set; }
    [Parameter] public int AdecuacionId { get; set; }
    [Parameter] public int TipoMovimientoId { get; set; }
    [Parameter] public int AnioId { get; set; }
    [Parameter] public string CurrencySymbol { get; set; } = "$";

    private BaseCrudDialog<EgreAdecuacionDetalleResponse> dialog = null!;
    private BaseEntityForm<EgreAdecuacionDetalleResponse> form = null!;
    private readonly EditorRequestState load = new();
    private readonly EditorRequestState availableLoad = new();
    private EgreAdecuacionDetalleResponse item = new();
    private LookupItem? _egreso;
    private EgresoDisponibleResponse? _selectedDisponible;
    private DateTime? _fecha;
    private bool saving;
    private int requestVersion;

    private string dialogTitle => Id.HasValue ? "Editar movimiento" : "Nuevo movimiento";
    private string actionText => Id.HasValue ? "Actualizar" : "Crear";
    private string processingText => Id.HasValue ? "Actualizando..." : "Creando...";
    private string TipoTexto => TipoMovimientoId == 1 ? "Ampliación" : "Reducción";
    private decimal CapturedTotal => BudgetCaptureUi.Months.Sum(month => GetMonth(month.Index) ?? 0m);
    private bool CanSave => load.IsReady && availableLoad.IsReady && !saving;
    private string Money(decimal amount) => $"{CurrencySymbol}{amount.ToString("0.00", BudgetCaptureUi.NumberCulture)}";

    protected override Task OnParametersSetAsync() => LoadAsync();

    private async Task LoadAsync()
    {
        var version = load.Begin();
        requestVersion = version;
        availableLoad.Invalidate();
        _egreso = null;
        _selectedDisponible = null;
        try
        {
            await AnioStateService.InitializeAsync();
            if (!load.IsCurrent(version))
                return;
            if (AdecuacionId <= 0 || AnioId <= 0 || AnioStateService.AnioId != AnioId || AnioStateService.AnioClave is not (>= 1 and <= 9999))
            {
                load.Fail(version, "Selecciona una adecuación y un ejercicio presupuestal válidos.");
                return;
            }
            if (!Id.HasValue)
            {
                item = new()
                {
                    Activo = true,
                    FkidEgreAdecuacionPres = AdecuacionId,
                    FkidTipoMovimientoPres = TipoMovimientoId,
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
                if (response.Data.FkidEgreAdecuacionPres != AdecuacionId || response.Data.FkidTipoMovimientoPres != TipoMovimientoId || response.Data.FkidAnioSis != AnioId)
                {
                    load.Fail(version, "El movimiento no corresponde a la adecuación y ejercicio seleccionados.");
                    return;
                }
                item = response.Data;
                foreach (var month in BudgetCaptureUi.Months)
                    SetMonth(month.Index, Math.Abs(GetMonth(month.Index) ?? 0m));
                if (item.FkidEgresoAutorizadoPres.HasValue)
                {
                    _egreso = new()
                    {
                        Id = item.FkidEgresoAutorizadoPres.Value,
                        Text = item.EgresoAutorizadoDescripcion ?? item.FkidEgresoAutorizadoPres.Value.ToString()
                    };
                }
            }
            _fecha = item.Fecha.ToDateTime(TimeOnly.MinValue);
            load.Complete(version);
            if (_egreso != null)
                await LoadAvailableAsync(_egreso.Id);
        }
        catch (Exception exception)
        {
            load.Fail(version, UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception));
        }
    }

    private string? ValidateDate(DateTime? date) => BudgetCaptureUi.ValidateDate(date, AnioStateService.AnioClave);

    private async Task SaveAsync()
    {
        if (!CanSave)
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
            if (AnioStateService.AnioId != AnioId || AnioStateService.AnioClave is not > 0)
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
            if (_egreso == null || _selectedDisponible == null || !availableLoad.IsReady)
            {
                Snackbar.Add("Selecciona un egreso y espera la consulta de su disponibilidad.", Severity.Warning);
                return;
            }
            if (CapturedTotal <= 0)
            {
                Snackbar.Add("Solicita un importe para al menos un mes.", Severity.Warning);
                return;
            }
            if (BudgetCaptureUi.Months.Any(month => BudgetCaptureUi.ValidateAmount(GetMonth(month.Index)) != null))
            {
                Snackbar.Add("Los importes mensuales no pueden ser negativos.", Severity.Warning);
                return;
            }
            if (BudgetCaptureUi.Months.Any(month => month.Index < _fecha!.Value.Month && (GetMonth(month.Index) ?? 0m) > 0m))
            {
                Snackbar.Add("Los meses anteriores al mes seleccionado no deben tener valor.", Severity.Warning);
                return;
            }
            if (TipoMovimientoId == 2 && _selectedDisponible.Total.HasValue && CapturedTotal > _selectedDisponible.Total.Value)
            {
                Snackbar.Add("La reducción no puede ser mayor que el presupuesto disponible.", Severity.Warning);
                return;
            }
            item.FkidEgresoAutorizadoPres = _egreso.Id;
            item.FkidEgreAdecuacionPres = AdecuacionId;
            item.FkidTipoMovimientoPres = TipoMovimientoId;
            item.Fecha = DateOnly.FromDateTime(_fecha!.Value);
            var response = Id.HasValue ? await Service.UpdateAsync(item, Id.Value) : await Service.CreateAsync(item);
            if (!load.IsCurrent(version))
                return;
            if (response?.Success == true)
            {
                Snackbar.Add("Movimiento guardado correctamente.", Severity.Success);
                dialog.SignalClose(true);
            }
            else
            {
                Snackbar.Add(string.IsNullOrWhiteSpace(response?.Message) ? "No fue posible guardar el movimiento." : response.Message, Severity.Error);
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

    private async Task OnEgresoChanged(LookupItem? value)
    {
        _egreso = value;
        _selectedDisponible = null;
        availableLoad.Invalidate();
        if (value != null)
            await LoadAvailableAsync(value.Id);
    }

    private Task RetryAvailableAsync() => _egreso == null ? Task.CompletedTask : LoadAvailableAsync(_egreso.Id);

    private async Task LoadAvailableAsync(int id)
    {
        var version = availableLoad.Begin();
        var editorVersion = requestVersion;
        _selectedDisponible = null;
        try
        {
            var response = await DisponibleService.GetByIdAsync(id);
            if (!availableLoad.IsCurrent(version) || !load.IsCurrent(editorVersion) || _egreso?.Id != id)
                return;
            if (response?.Success != true || response.Data == null || response.Data.PkidEgresoAutorizado != id)
            {
                availableLoad.Fail(version, response?.Message);
                return;
            }
            _selectedDisponible = response.Data;
            availableLoad.Complete(version);
        }
        catch (Exception exception)
        {
            availableLoad.Fail(version, UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception));
        }
    }

    private async Task<ComboLookupResult> LoadEgresosPageAsync(int page, int pageSize, string filter, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var response = await DisponibleService.GetAllPaginadoAsync(page, pageSize, filter,
            nameof(EgresoDisponibleResponse.DescripcionRequisicion), SortDirection.Ascending,
            new() { [nameof(EgresoDisponibleResponse.FkidAnioSis)] = AnioId });
        cancellationToken.ThrowIfCancellationRequested();
        if (response?.Success != true)
            throw new InvalidOperationException("No fue posible consultar los egresos disponibles.");
        var rows = response.Items.Select(row => new LookupItem
        {
            Id = row.PkidEgresoAutorizado,
            Text = $"{row.DescripcionRequisicion} ({Money(row.Total ?? 0m)})"
        }).ToList();
        return new() { Items = rows, TotalCount = response.TotalCount };
    }

    private void OnMonthChanged(BudgetMonthChange change) => SetMonth(change.Index, change.Amount);

    private decimal? GetMonth(int index) => index switch
    {
        1 => item.Enero,
        2 => item.Febrero,
        3 => item.Marzo,
        4 => item.Abril,
        5 => item.Mayo,
        6 => item.Junio,
        7 => item.Julio,
        8 => item.Agosto,
        9 => item.Septiembre,
        10 => item.Octubre,
        11 => item.Noviembre,
        12 => item.Diciembre,
        _ => null
    };

    private void SetMonth(int index, decimal? value)
    {
        value ??= 0m;
        switch (index)
        {
            case 1:
                item.Enero = value;
                break;
            case 2:
                item.Febrero = value;
                break;
            case 3:
                item.Marzo = value;
                break;
            case 4:
                item.Abril = value;
                break;
            case 5:
                item.Mayo = value;
                break;
            case 6:
                item.Junio = value;
                break;
            case 7:
                item.Julio = value;
                break;
            case 8:
                item.Agosto = value;
                break;
            case 9:
                item.Septiembre = value;
                break;
            case 10:
                item.Octubre = value;
                break;
            case 11:
                item.Noviembre = value;
                break;
            case 12:
                item.Diciembre = value;
                break;
        }
    }

    public void Dispose()
    {
        load.Dispose();
        availableLoad.Dispose();
    }
}

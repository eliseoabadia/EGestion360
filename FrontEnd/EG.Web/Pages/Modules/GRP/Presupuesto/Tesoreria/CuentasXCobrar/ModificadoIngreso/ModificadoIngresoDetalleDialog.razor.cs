using EG.Common.GenericModel;
using EG.Common.Modules;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Web.Helpers;
using EG.Web.Models;
using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;
using EG.Web.Pages.Shared;
using Microsoft.AspNetCore.Components;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Presupuesto.Tesoreria.CuentasXCobrar.ModificadoIngreso;

public partial class ModificadoIngresoDetalleDialog : IDisposable
{
    [Parameter] public int? Id { get; set; }
    [Parameter] public int AdecuacionId { get; set; }
    [Parameter] public int TipoMovimientoId { get; set; }
    [Parameter] public int AnioId { get; set; }
    [Parameter] public string CurrencySymbol { get; set; } = "$";

    private BaseCrudDialog<IngreAdecuacionDetalleResponse> dialog = null!;
    private BaseEntityForm<IngreAdecuacionDetalleResponse> form = null!;
    private readonly EditorRequestState load = new();
    private readonly EditorRequestState availableLoad = new();
    private IngreAdecuacionDetalleResponse item = new();
    private LookupItem? _ingreso;
    private IngresoDisponibleResponse? _selectedDisponible;
    private DateTime? _fecha;
    private bool saving;
    private int requestVersion;

    private string dialogTitle => Id.HasValue ? "Editar movimiento" : "Nuevo movimiento";
    private string actionText => Id.HasValue ? EG.Common.ApplicationText.Actions.Update : EG.Common.ApplicationText.Actions.Create;
    private string processingText => Id.HasValue ? EG.Common.ApplicationText.Status.Updating : EG.Common.ApplicationText.Status.Creating;
    private string TipoTexto => TipoMovimientoId == 3 ? "Aumento de ingresos" : "Reducción de ingresos";
    private decimal? CapturedTotal => IncomeAmountRules.TrySum(
        BudgetCaptureUi.Months.Select(month => GetMonth(month.Index)), out var total) ? total : null;
    private decimal? ResultadoEstimado => CapturedTotal is decimal total
        ? TipoMovimientoId == 3 ? (_selectedDisponible?.Total ?? 0m) + total : Math.Max(0m, (_selectedDisponible?.Total ?? 0m) - total)
        : null;
    private bool CanSave => load.IsReady && availableLoad.IsReady && !saving;
    private string Money(decimal? amount) => amount.HasValue
        ? $"{CurrencySymbol}{amount.Value.ToString("0.00", BudgetCaptureUi.NumberCulture)}"
        : "Revisa los importes";

    private static string? ValidateIncomeAmount(decimal? amount) => IncomeAmountRules.ValidateMonth(amount);

    protected override Task OnParametersSetAsync() => LoadAsync();

    private async Task LoadAsync()
    {
        var version = load.Begin();
        requestVersion = version;
        availableLoad.Invalidate();
        _ingreso = null;
        _selectedDisponible = null;
        try
        {
            await AnioStateService.InitializeAsync();
            if (!load.IsCurrent(version))
                return;
            if (AdecuacionId <= 0 || AnioId <= 0 || AnioStateService.AnioId != AnioId)
            {
                load.Fail(version, "Selecciona una adecuación y un ejercicio presupuestal válidos.");
                return;
            }
            if (!Id.HasValue)
            {
                item = new()
                {
                    Activo = true,
                    FkidIngreAdecuacionPres = AdecuacionId,
                    FkidTipoMovimientoPres = TipoMovimientoId,
                    Fecha = DateOnly.FromDateTime(DateTime.Today)
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
                if (response.Data.FkidIngreAdecuacionPres != AdecuacionId || response.Data.FkidTipoMovimientoPres != TipoMovimientoId || response.Data.FkidAnioSis != AnioId)
                {
                    load.Fail(version, "El movimiento no corresponde a la adecuación y ejercicio seleccionados.");
                    return;
                }
                item = response.Data;
                foreach (var month in BudgetCaptureUi.Months)
                    SetMonth(month.Index, Math.Abs(GetMonth(month.Index)));
                if (item.FkidIngresoAutorizadoPres > 0)
                {
                    _ingreso = new()
                    {
                        Id = item.FkidIngresoAutorizadoPres,
                        Text = !string.IsNullOrWhiteSpace(item.PosicionPresupuestal)
                            ? item.PosicionPresupuestal
                            : !string.IsNullOrWhiteSpace(item.IngresoAutorizadoDescripcion)
                                ? item.IngresoAutorizadoDescripcion
                                : "Ingreso autorizado seleccionado"
                    };
                }
            }
            _fecha = item.Fecha.ToDateTime(TimeOnly.MinValue);
            load.Complete(version);
            if (_ingreso != null)
                await LoadAvailableAsync(_ingreso.Id);
        }
        catch (Exception exception)
        {
            load.Fail(version, UserFacingExceptionMessages.ForDisplay(AppLoggerFactory, exception));
        }
    }

    private string? ValidateDate(DateTime? date) => BudgetCaptureUi.ValidateDate(date);

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
            if (AnioStateService.AnioId != AnioId)
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
            if (_ingreso == null || _selectedDisponible == null || !availableLoad.IsReady)
            {
                Snackbar.Add("Selecciona un ingreso y espera la consulta de su disponibilidad.", Severity.Warning);
                return;
            }
            if (!CapturedTotal.HasValue)
            {
                Snackbar.Add("Revisa los importes mensuales y su total antes de guardar.", Severity.Warning);
                return;
            }
            if (CapturedTotal.Value <= 0)
            {
                Snackbar.Add("Solicita un importe para al menos un mes.", Severity.Warning);
                return;
            }
            if (BudgetCaptureUi.Months.Any(month => month.Index < _fecha!.Value.Month && GetMonth(month.Index) > 0m))
            {
                Snackbar.Add("Los meses anteriores al mes seleccionado no deben tener valor.", Severity.Warning);
                return;
            }
            if (TipoMovimientoId == 4 && TryGetExceededMonth(out var exceededMonth))
            {
                Snackbar.Add($"La reducción supera el disponible de {exceededMonth}.", Severity.Warning);
                return;
            }
            item.FkidIngresoAutorizadoPres = _ingreso.Id;
            item.FkidIngreAdecuacionPres = AdecuacionId;
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

    private async Task OnIngresoChanged(LookupItem? value)
    {
        _ingreso = value;
        _selectedDisponible = null;
        availableLoad.Invalidate();
        if (value != null)
            await LoadAvailableAsync(value.Id);
    }

    private Task RetryAvailableAsync() => _ingreso == null ? Task.CompletedTask : LoadAvailableAsync(_ingreso.Id);

    private async Task LoadAvailableAsync(int id)
    {
        var version = availableLoad.Begin();
        var editorVersion = requestVersion;
        _selectedDisponible = null;
        try
        {
            var response = await DisponibleService.GetByIdAsync(id);
            if (!availableLoad.IsCurrent(version) || !load.IsCurrent(editorVersion) || _ingreso?.Id != id)
                return;
            if (response?.Success != true || response.Data == null || response.Data.PkidIngresoAutorizado != id)
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

    private async Task<ComboLookupResult> LoadIngresosPageAsync(int page, int pageSize, string filter, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var response = await DisponibleService.GetAllPaginadoAsync(page, pageSize, filter,
            nameof(IngresoDisponibleResponse.DescripcionRequisicion), SortDirection.Ascending,
            new() { [nameof(IngresoDisponibleResponse.FkidAnioSis)] = AnioId });
        cancellationToken.ThrowIfCancellationRequested();
        if (response?.Success != true)
            throw new InvalidOperationException("No fue posible consultar los ingresos disponibles.");
        var rows = response.Items.Select(row => new LookupItem
        {
            Id = row.PkidIngresoAutorizado,
            Text = $"{row.DescripcionRequisicion} ({Money(row.Total ?? 0m)})"
        }).ToList();
        return new() { Items = rows, TotalCount = response.TotalCount };
    }

    private void OnMonthChanged(BudgetMonthChange change) => SetMonth(change.Index, change.Amount ?? 0m);

    private bool TryGetExceededMonth(out string monthName)
    {
        monthName = string.Empty;
        if (_selectedDisponible == null)
            return false;

        foreach (var month in BudgetCaptureUi.Months)
        {
            if (GetMonth(month.Index) <= GetAvailableMonth(month.Index))
                continue;
            monthName = month.Label;
            return true;
        }

        return false;
    }

    private decimal GetAvailableMonth(int index) => index switch
    {
        1 => _selectedDisponible?.Enero ?? 0m,
        2 => _selectedDisponible?.Febrero ?? 0m,
        3 => _selectedDisponible?.Marzo ?? 0m,
        4 => _selectedDisponible?.Abril ?? 0m,
        5 => _selectedDisponible?.Mayo ?? 0m,
        6 => _selectedDisponible?.Junio ?? 0m,
        7 => _selectedDisponible?.Julio ?? 0m,
        8 => _selectedDisponible?.Agosto ?? 0m,
        9 => _selectedDisponible?.Septiembre ?? 0m,
        10 => _selectedDisponible?.Octubre ?? 0m,
        11 => _selectedDisponible?.Noviembre ?? 0m,
        12 => _selectedDisponible?.Diciembre ?? 0m,
        _ => 0m
    };

    private decimal GetMonth(int index) => index switch
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
        _ => 0m
    };

    private void SetMonth(int index, decimal value)
    {
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

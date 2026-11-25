using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;
using System.Globalization;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts;
using EG.Web.Pages.Shared;
using EG.Web.Pages.Shared.SoporteDocumental;
using EG.Web.Services;
using EG.Web.Shared;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Presupuesto.Egreso.PresupuestoModificado;

public partial class PresupuestoModificadoShell
{
    [Parameter] public string Title { get; set; } = "Presupuesto modificado";
    [Parameter] public string Subtitle { get; set; } = "";
    [Parameter] public string SubModuleNameValue { get; set; } = "";
    [Parameter] public int TipoAdecuacionId { get; set; }
    [Parameter] public int DefaultMovimientoId { get; set; }
    [Parameter] public bool AllowBothMovements { get; set; }

    private GenericDataGrid<EgreAdecuacionResponse> table = null!;
    private GenericDataGrid<EgreAdecuacionDetalleResponse>? detalleTable;
    private GenericDataGrid<EgreAdecuacionDetalleResponse>? aumentosTable;
    private GenericDataGrid<EgreAdecuacionDetalleResponse>? reduccionesTable;
    private EgreAdecuacionResponse? Selected;
    private bool SelectedLocked;
    private readonly EditorRequestState boardLoad = new();
    private int contextVersion;
    private int listRequestVersion;
    private bool disposed;
    private (int Type, int Movement, bool Both, string Permission)? parameterContext;

    protected override async Task OnParametersSetAsync()
    {
        var next = (TipoAdecuacionId, DefaultMovimientoId, AllowBothMovements, SubModuleNameValue);
        if (parameterContext.HasValue && parameterContext.Value != next)
        {
            ClearSelection();
            Elements.Clear();
            TotalCount = 0;
            if (IsInitialized) await VerifyAccess();
        }
        parameterContext = next;
    }

    private void ClearSelection()
    {
        contextVersion++;
        boardLoad.Invalidate();
        Selected = null;
        SelectedLocked = true;
        _detalles.Clear();
        _poliza.Clear();
        detalleSearch = string.Empty;
    }
    private string detalleSearch = string.Empty;
    private string _currencySymbol = "$";
    private readonly Dictionary<int, decimal> DetailTotalCache = new();
    private readonly Dictionary<int, (decimal Debe, decimal Haber, int Count)> BalanceCache = new();
    private List<EgreAdecuacionDetalleResponse> _detalles = new();
    private List<PolizaDetalleResponse> _poliza = new();
    private static readonly CultureInfo NumberCulture = CultureInfo.InvariantCulture;

    protected override string ModuleName => "Presupuesto_Modificado";
    protected override string SubModuleName => SubModuleNameValue;
    protected override Type CreateDialogType => typeof(PresupuestoModificadoDialog);
    protected override Type EditDialogType => typeof(PresupuestoModificadoDialog);
    protected override Type DeleteDialogType => typeof(DeleteDialog<EgreAdecuacionResponse>);
    protected override string GetDefaultSortLabel() => "Fecha";

    private decimal AmpliacionesTotal => _detalles.Where(x => x.FkidTipoMovimientoPres == 1).Sum(x => Math.Abs(x.Total ?? 0m));
    private decimal ReduccionesTotal => _detalles.Where(x => x.FkidTipoMovimientoPres == 2).Sum(x => Math.Abs(x.Total ?? 0m));
    private decimal NetoTotal => AmpliacionesTotal - ReduccionesTotal;
    private decimal DebeTotal => _poliza.Sum(x => x.ImporteDebe ?? 0m);
    private decimal HaberTotal => _poliza.Sum(x => x.ImporteHaber ?? 0m);
    private bool IsSelectedBalanced => _poliza.Count > 0 && DebeTotal == HaberTotal;
    private bool CanSendSelected => Selected != null && CanSendRequest(Selected, IsSelectedBalanced);
    private bool CanCancelSelected => Selected != null && CanCancelRequest(Selected);
    private bool CanAuthorizeSelected => Selected != null && CanAuthorizeItem(Selected, IsSelectedBalanced);
    private bool CanRejectSelected => Selected != null && CanRejectItem(Selected);
    private string BalanceText => _poliza.Count == 0 ? "Sin movimientos contables" : IsSelectedBalanced ? "Balanceada" : $"Diferencia {Money(Math.Abs(DebeTotal - HaberTotal))}";
    private bool IsCompensada => TipoAdecuacionId == 1;

    protected override async Task OnInitializedAsync()
    {
        await base.OnInitializedAsync();
        if (disposed) return;
        await AnioStateService.InitializeAsync();
        await SucursalStateService.InitializeAsync();
        if (disposed) return;
        AnioStateService.OnAnioChanged += OnAnioChanged;
        SucursalStateService.OnEmpresaChanged += OnEmpresaChanged;
        await LoadCurrencyAsync();
    }

    protected override async Task<TableData<EgreAdecuacionResponse>> LoadServerData(TableState state, CancellationToken cancellationToken)
    {
        var context = contextVersion;
        var request = ++listRequestVersion;
        bool IsCurrent() => !disposed && context == contextVersion &&
            request == listRequestVersion && !cancellationToken.IsCancellationRequested;
        if (!AnioStateService.AnioId.HasValue || !SucursalStateService.EmpresaId.HasValue)
        {
            Elements = [];
            TotalCount = 0;
            return new() { Items = [], TotalItems = 0 };
        }

        Elements = [];
        TotalCount = 0;
        var response = await Service.GetAllPaginadoAsync(
            Math.Max(1, state.Page + 1), state.PageSize, SearchString,
            state.SortLabel ?? GetDefaultSortLabel(), state.SortDirection,
            new() { ["FkidAnioSis"] = AnioStateService.AnioId.Value, ["FkidTipoAdecuacionPres"] = TipoAdecuacionId });
        if (!IsCurrent()) return new() { Items = [], TotalItems = 0 };
        if (response?.Success != true)
            throw new InvalidOperationException("No fue posible consultar las adecuaciones.");
        var items = response.Items?.ToList() ?? [];
        try
        {
            await LoadTotalsAsync(items, IsCurrent);
        }
        catch (OperationCanceledException) when (!IsCurrent())
        {
            return new() { Items = [], TotalItems = 0 };
        }
        if (!IsCurrent()) return new() { Items = [], TotalItems = 0 };
        Elements = items;
        TotalCount = response.TotalCount;
        return new() { Items = Elements, TotalItems = TotalCount };
    }
    protected override async Task CreateItem()
    {
        if (!AnioStateService.AnioId.HasValue) { Snackbar.Add("Selecciona un anio presupuestal.", Severity.Warning); return; }
        var parameters = DialogParams(null);
        var dialog = await DialogService.ShowAsync(CreateDialogType, $"Crear {Title}", parameters, new DialogOptions { MaxWidth = MaxWidth.Medium, FullWidth = true });
        if ((await dialog.Result) is { Canceled: false }) await ReloadData();
    }

    protected override async Task EditItem(int id)
    {
        var item = Elements.FirstOrDefault(x => x.PkidEgreAdecuacion == id);
        if (item?.Autorizado == true) { Snackbar.Add("La adecuacion autorizada no puede editarse.", Severity.Warning); return; }
        var dialog = await DialogService.ShowAsync(EditDialogType, $"Editar {Title}", DialogParams(id), new DialogOptions { MaxWidth = MaxWidth.Medium, FullWidth = true });
        if ((await dialog.Result) is { Canceled: false }) await ReloadData();
    }

    private DialogParameters DialogParams(int? id) => new()
    {
        ["Id"] = id,
        ["TipoAdecuacionId"] = TipoAdecuacionId,
        ["AnioId"] = AnioStateService.AnioId ?? 0
    };

    private async Task SelectItem(EgreAdecuacionResponse item)
    {
        Selected = item;
        await RefreshSelected();
    }

    private Task BackToList()
    {
        ClearSelection();
        return Task.CompletedTask;
    }
    private async Task RefreshSelected()
    {
        if (Selected == null || disposed) return;
        var selectedId = Selected.PkidEgreAdecuacion;
        var version = boardLoad.Begin();
        SelectedLocked = true;
        _detalles = [];
        _poliza = [];
        try
        {
            var response = await Service.GetByIdAsync(selectedId);
            if (!boardLoad.IsCurrent(version)) return;
            if (response?.Success != true || response.Data == null)
                throw new InvalidOperationException("No fue posible actualizar la adecuación.");
            Selected = response.Data;
            await LoadBoardsAsync(version);
            if (!boardLoad.Complete(version)) return;
            SelectedLocked = IsLocked(Selected);
        }
        catch (OperationCanceledException) when (!boardLoad.IsCurrent(version))
        {
        }
        catch (Exception exception)
        {
            if (boardLoad.Fail(version, "No fue posible cargar el tablero completo. Reintenta la consulta."))
                NotifyUnexpectedError(exception, "cargar el tablero presupuestal");
        }
    }
    private async Task<TableData<EgreAdecuacionDetalleResponse>> LoadDetalleData(TableState state, CancellationToken token)
        => await LoadDetalleDataByMovement(state, DefaultMovimientoId);

    private async Task<TableData<EgreAdecuacionDetalleResponse>> LoadAumentosData(TableState state, CancellationToken token)
        => await LoadDetalleDataByMovement(state, 1);

    private async Task<TableData<EgreAdecuacionDetalleResponse>> LoadReduccionesData(TableState state, CancellationToken token)
        => await LoadDetalleDataByMovement(state, 2);

    private async Task<TableData<EgreAdecuacionDetalleResponse>> LoadDetalleDataByMovement(TableState state, int tipoMovimiento)
    {
        if (Selected == null) return new TableData<EgreAdecuacionDetalleResponse> { Items = [], TotalItems = 0 };
        var response = await DetalleService.GetAllPaginadoAsync(Math.Max(1, state.Page + 1), state.PageSize, detalleSearch, state.SortLabel ?? "Fecha", state.SortDirection, new() { ["FkidEgreAdecuacionPres"] = Selected.PkidEgreAdecuacion, ["FkidTipoMovimientoPres"] = tipoMovimiento });
        var items = response?.Items?.ToList() ?? [];
        return new TableData<EgreAdecuacionDetalleResponse> { Items = items, TotalItems = response?.TotalCount ?? 0 };
    }

    private async Task LoadBoardsAsync(int version)
    {
        var selected = Selected;
        if (selected == null || !boardLoad.IsCurrent(version)) return;
        var details = await BudgetPageReader.ReadAllAsync(
            (page, size) => DetalleService.GetAllPaginadoAsync(
                page, size, string.Empty, "PkidEgreAdecuacionDetalle", SortDirection.Ascending,
                new() { ["FkidEgreAdecuacionPres"] = selected.PkidEgreAdecuacion }),
            item => item.PkidEgreAdecuacionDetalle,
            () => boardLoad.IsCurrent(version));
        var policy = selected.FkidPolizaConta.HasValue
            ? await BudgetPageReader.ReadAllAsync(
                (page, size) => PolizaDetalleService.GetAllPaginadoAsync(
                    page, size, string.Empty, nameof(PolizaDetalleResponse.PkidPolizaDetalle), SortDirection.Ascending,
                    new() { [nameof(PolizaDetalleResponse.FkidPolizaConta)] = selected.FkidPolizaConta.Value }),
                item => item.PkidPolizaDetalle,
                () => boardLoad.IsCurrent(version))
            : [];
        if (!boardLoad.IsCurrent(version)) return;
        _detalles = details;
        _poliza = policy;
        BalanceCache[selected.PkidEgreAdecuacion] = (DebeTotal, HaberTotal, _poliza.Count);
    }
    private async Task LoadTotalsAsync(IEnumerable<EgreAdecuacionResponse> items, Func<bool> isCurrent)
    {
        var totals = new Dictionary<int, decimal>();
        var balances = new Dictionary<int, (decimal Debe, decimal Haber, int Count)>();
        foreach (var item in items)
        {
            var details = await BudgetPageReader.ReadAllAsync(
                (page, size) => DetalleService.GetAllPaginadoAsync(
                    page, size, string.Empty, nameof(EgreAdecuacionDetalleResponse.PkidEgreAdecuacionDetalle),
                    SortDirection.Ascending, new() { [nameof(EgreAdecuacionDetalleResponse.FkidEgreAdecuacionPres)] = item.PkidEgreAdecuacion }),
                row => row.PkidEgreAdecuacionDetalle, isCurrent);
            totals[item.PkidEgreAdecuacion] = details.Sum(row => Math.Abs(row.Total ?? 0m));
            var policy = item.FkidPolizaConta.HasValue
                ? await BudgetPageReader.ReadAllAsync(
                    (page, size) => PolizaDetalleService.GetAllPaginadoAsync(
                        page, size, string.Empty, nameof(PolizaDetalleResponse.PkidPolizaDetalle),
                        SortDirection.Ascending, new() { [nameof(PolizaDetalleResponse.FkidPolizaConta)] = item.FkidPolizaConta.Value }),
                    row => row.PkidPolizaDetalle, isCurrent)
                : [];
            balances[item.PkidEgreAdecuacion] = (
                policy.Sum(row => row.ImporteDebe ?? 0m),
                policy.Sum(row => row.ImporteHaber ?? 0m),
                policy.Count);
        }
        if (!isCurrent()) return;
        DetailTotalCache.Clear();
        BalanceCache.Clear();
        foreach (var total in totals) DetailTotalCache.Add(total.Key, total.Value);
        foreach (var balance in balances) BalanceCache.Add(balance.Key, balance.Value);
    }
    private async Task AddDetalle(int tipoMovimiento) => await OpenDetalle(null, tipoMovimiento);
    private async Task EditDetalle(int id, int tipoMovimiento) => await OpenDetalle(id, tipoMovimiento);

    private async Task OpenDetalle(int? id, int tipoMovimiento)
    {
        if (Selected == null || SelectedLocked) return;
        var dialog = await DialogService.ShowAsync<PresupuestoModificadoDetalleDialog>(id.HasValue ? "Editar movimiento" : "Nuevo movimiento",
            new DialogParameters { ["Id"] = id, ["AdecuacionId"] = Selected.PkidEgreAdecuacion, ["TipoMovimientoId"] = tipoMovimiento, ["AnioId"] = AnioStateService.AnioId ?? 0, ["CurrencySymbol"] = _currencySymbol },
            new DialogOptions { MaxWidth = MaxWidth.Large, FullWidth = true });
        if ((await dialog.Result) is { Canceled: false }) await RefreshSelected();
    }

    private async Task DeleteDetalle(int id)
    {
        if (SelectedLocked) return;
        var result = await DetalleService.DeleteAsync(id);
        Snackbar.Add(result?.Message ?? "Movimiento eliminado.", result?.Success == true ? Severity.Success : Severity.Error);
        await RefreshSelected();
    }




    private async Task Workflow(EgreAdecuacionResponse item, string action)
    {
        var context = contextVersion;
        await RunExclusiveAsync(async () =>
        {
            try
            {
                await ExecuteWorkflowCoreAsync(item, action, context);
            }
            catch (Exception exception)
            {
                NotifyUnexpectedError(
                    exception,
                    "confirmar la acción presupuestal",
                    "No se pudo confirmar el resultado. Actualiza el registro antes de volver a intentarlo.");
            }
        });
    }
    private async Task ExecuteWorkflowCoreAsync(EgreAdecuacionResponse item, string action, int context)
    {
        var (title, message, confirmText, severity) = action switch
        {
            "autorizar" => (
                "Autorizar modificación presupuestal",
                $"¿Seguro que deseas autorizar la modificación {item.Clave}? La modificación quedará bloqueada.",
                "Autorizar",
                Severity.Success),
            "rechazar" => (
                "Rechazar modificación presupuestal",
                $"¿Seguro que deseas rechazar la modificación {item.Clave}? Quedará bloqueada.",
                "Rechazar",
                Severity.Warning),
            "cancelar-solicitud" => (
                "Cancelar solicitud de autorización",
                $"¿Seguro que deseas cancelar la solicitud de {item.Clave} y devolverla a captura?",
                "Cancelar solicitud",
                Severity.Warning),
            _ => (
                "Enviar solicitud de autorización",
                $"¿Seguro que deseas enviar a autorización la modificación {item.Clave}?",
                "Enviar",
                Severity.Info)
        };

        if (!await ConfirmWorkflowAsync(title, message, confirmText, severity, item.PkidEgreAdecuacion))
        {
            return;
        }

        if (disposed || context != contextVersion)
        {
            Snackbar.Add("El contexto cambió. Abre nuevamente el registro antes de ejecutar la acción.", Severity.Warning);
            return;
        }

        using var response = await Http.PostAsync($"api/EgreAdecuacion/{item.PkidEgreAdecuacion}/{action}", null);
        var result = await response.Content.ReadFromJsonAsync<EG.Web.Models.ApiResponse<EgreAdecuacionResponse>>();
        if (disposed || context != contextVersion) return;
        Snackbar.Add(result?.Message ?? (response.IsSuccessStatusCode && result?.Success == true ? "Proceso realizado." : "No fue posible procesar."), response.IsSuccessStatusCode && result?.Success == true ? Severity.Success : Severity.Error);
        if (Selected != null)
            await RefreshSelected();
        else
            await ReloadData();
    }

    protected override IEnumerable<object> MapToExcelData(IEnumerable<EgreAdecuacionResponse> items) => items.Select(x => new { x.Clave, x.TipoAdecuacionDescripcion, x.EstatusAdecuacionDescripcion, x.Justificacion, Fecha = x.Fecha.ToString("dd/MM/yyyy"), x.ClavePoliza, x.Autorizado, x.Activo, x.UsuarioCreacion, x.FechaCreacion, x.UsuarioModificacion, x.FechaModificacion });
    protected override async Task ReloadData() { if (table != null) await table.ReloadData(); }
    private async Task ReloadDetalle()
    {
        if (detalleTable != null) await detalleTable.ReloadData();
        if (aumentosTable != null) await aumentosTable.ReloadData();
        if (reduccionesTable != null) await reduccionesTable.ReloadData();
    }
    private bool IsLocked(EgreAdecuacionResponse item) => item.Autorizado == true || item.FkidAccionAdecuacionMasterPres != 1;
    private static bool IsRequestSent(EgreAdecuacionResponse item) => item.FkidAccionAdecuacionMasterPres == 2;
    private bool IsBalanced(EgreAdecuacionResponse item) => BalanceCache.TryGetValue(item.PkidEgreAdecuacion, out var balance) && balance.Count > 0 && balance.Debe == balance.Haber;
    private bool CanSendRequest(EgreAdecuacionResponse item) => CanSendRequest(item, IsBalanced(item));
    private bool CanSendRequest(EgreAdecuacionResponse item, bool balanced) => CanUpdate && !OperationInProgress && item.FkidAccionAdecuacionMasterPres == 1 && !IsLockedStatic(item) && balanced;
    private bool CanCancelRequest(EgreAdecuacionResponse item) => !OperationInProgress && CanUpdate && item.Autorizado != true && IsRequestSent(item);
    private bool CanAuthorizeItem(EgreAdecuacionResponse item) => CanAuthorizeItem(item, IsBalanced(item));
    private bool CanAuthorizeItem(EgreAdecuacionResponse item, bool balanced) => !OperationInProgress && CanAuthorize && item.Autorizado != true && balanced && IsRequestSent(item);
    private bool CanRejectItem(EgreAdecuacionResponse item) => !OperationInProgress && CanAuthorize && item.Autorizado != true && IsRequestSent(item);
    private string RequestTooltip(EgreAdecuacionResponse item) => item.Autorizado == true ? "La modificacion ya esta autorizada" : item.FkidAccionAdecuacionMasterPres == 4 ? "La modificacion fue rechazada" : IsRequestSent(item) ? "La solicitud ya fue enviada" : IsBalanced(item) ? "Enviar solicitud de autorizacion" : BalanceTooltip(item);
    private string AuthorizeTooltip(EgreAdecuacionResponse item) => !CanAuthorize ? "No tienes permiso para autorizar" : item.Autorizado == true ? "La modificacion ya esta autorizada" : !IsRequestSent(item) ? "Primero envia la solicitud de autorizacion" : IsBalanced(item) ? "Autorizar modificacion" : BalanceTooltip(item);
    private string BalanceTooltip(EgreAdecuacionResponse item)
    {
        if (!BalanceCache.TryGetValue(item.PkidEgreAdecuacion, out var balance) || balance.Count == 0)
            return "La poliza no tiene movimientos contables";

        return $"La poliza no esta balanceada. Debe {Money(balance.Debe)}, Haber {Money(balance.Haber)}";
    }
    private static bool IsLockedStatic(EgreAdecuacionResponse item) => item.Autorizado == true || item.FkidAccionAdecuacionMasterPres != 1;
    private static string StatusText(EgreAdecuacionResponse item) => item.Autorizado == true ? "Autorizada" : item.FkidAccionAdecuacionMasterPres == 2 ? "Solicitud enviada" : item.FkidAccionAdecuacionMasterPres == 4 ? "Rechazada" : "En captura";
    private static Color StatusColor(EgreAdecuacionResponse item) => item.Autorizado == true ? Color.Success : item.FkidAccionAdecuacionMasterPres == 2 ? Color.Info : item.FkidAccionAdecuacionMasterPres == 4 ? Color.Error : Color.Warning;
    private void OnEmpresaChanged(int empresaId) => _ = InvokeAsync(ChangeContextAsync);
    private void OnAnioChanged(int? anioId) => _ = InvokeAsync(ChangeContextAsync);
    private string Money(decimal amount) => $"{_currencySymbol}{amount.ToString("0.00", NumberCulture)}";
    private static string TextOrDash(string? value) => string.IsNullOrWhiteSpace(value) ? "-" : value;

    private async Task LoadCurrencyAsync()
    {
        var context = contextVersion;
        try
        {
            var userIdString = await JsRuntime.InvokeAsync<string>("localStorage.getItem", "userId");
            if (int.TryParse(userIdString, out var userId))
            {
                var user = await UsuarioService.GetByIdAsync(userId);
                if (disposed || context != contextVersion) return;
                _currencySymbol = string.IsNullOrWhiteSpace(user?.Data?.SimboloMonedaBase) ? "$" : user.Data.SimboloMonedaBase;
            }
        }
        catch (Exception ex)
        {
            AppLoggerFactory.CreateLogger("PresupuestoModificadoShell")
                .LogWarning(ex, "No se pudo cargar la moneda configurada para el presupuesto modificado.");
            AppSnackbar.Add("No se pudo confirmar la moneda de la empresa; se mostrara la moneda predeterminada.", Severity.Warning);
        }
    }


    private async Task ChangeContextAsync()
    {
        if (disposed) return;
        ClearSelection();
        Elements.Clear();
        TotalCount = 0;
        DetailTotalCache.Clear();
        BalanceCache.Clear();
        StateHasChanged();
        await LoadCurrencyAsync();
        if (!disposed) StateHasChanged();
    }
    public void Dispose()
    {
        disposed = true;
        contextVersion++;
        boardLoad.Dispose();
        AnioStateService.OnAnioChanged -= OnAnioChanged;
        SucursalStateService.OnEmpresaChanged -= OnEmpresaChanged;
    }
}

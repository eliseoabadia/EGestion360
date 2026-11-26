using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;
using System.Globalization;
using System.Net.Http.Json;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts;
using EG.Web.Pages.Shared;
using EG.Web.Pages.Shared.SoporteDocumental;
using EG.Web.Services;
using EG.Web.Shared;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Presupuesto.Tesoreria.CuentasXCobrar.ModificadoIngreso;

public partial class ModificadoIngresoShell
{
    [Parameter] public string Title { get; set; } = "Modificado de ingresos";
    [Parameter] public string Subtitle { get; set; } = "Control presupuestal y contable";
    [Parameter] public string SubModuleNameValue { get; set; } = "Adecuaciones_Compensadas";
    [Parameter] public int TipoAdecuacionId { get; set; }
    [Parameter] public int DefaultMovimientoId { get; set; }
    [Parameter] public bool AllowBothMovements { get; set; }

    private GenericDataGrid<IngreAdecuacionResponse> table = null!;
    private GenericDataGrid<IngreAdecuacionDetalleResponse>? detalleTable;
    private IngreAdecuacionResponse? Selected;
    private bool SelectedLocked;
    private readonly EditorRequestState boardLoad = new();
    private int contextVersion;
    private int listRequestVersion;
    private bool disposed;
    private bool contextReady;
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
    private string _currencyName = "Peso Mexicano";
    private List<IngreAdecuacionDetalleResponse> _detalles = [];
    private List<PolizaDetalleResponse> _poliza = [];
    private static readonly CultureInfo NumberCulture = CultureInfo.InvariantCulture;
    private static readonly (int Index, string Label)[] MonthFields = [(1,"Ene"),(2,"Feb"),(3,"Mar"),(4,"Abr"),(5,"May"),(6,"Jun"),(7,"Jul"),(8,"Ago"),(9,"Sep"),(10,"Oct"),(11,"Nov"),(12,"Dic")];

    protected override string ModuleName => "Presupuesto_Modificado";
    protected override string SubModuleName => SubModuleNameValue;
    protected override Type CreateDialogType => typeof(ModificadoIngresoDialog);
    protected override Type EditDialogType => typeof(ModificadoIngresoDialog);
    protected override Type DeleteDialogType => typeof(DeleteDialog<IngreAdecuacionResponse>);
    protected override string GetDefaultSortLabel() => "Fecha";

    private bool HasCompany => SucursalStateService.EmpresaId.HasValue && SucursalStateService.EmpresaId.Value > 0;
    private decimal AumentosTotal => _detalles.Where(x => x.FkidTipoMovimientoPres == 3).Sum(x => Math.Abs(x.Total ?? 0m));
    private decimal ReduccionesTotal => _detalles.Where(x => x.FkidTipoMovimientoPres == 4).Sum(x => Math.Abs(x.Total ?? 0m));
    private decimal NetoTotal => AumentosTotal - ReduccionesTotal;
    private decimal DebeTotal => _poliza.Sum(x => x.ImporteDebe ?? 0m);
    private decimal HaberTotal => _poliza.Sum(x => x.ImporteHaber ?? 0m);
    private bool IsSelectedBalanced => _poliza.Count > 0 && DebeTotal == HaberTotal;
    private string BalanceText => _poliza.Count == 0 ? "Sin movimientos" : IsSelectedBalanced ? "Balanceada" : $"Diferencia {Money(Math.Abs(DebeTotal - HaberTotal))}";

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
        contextReady = !disposed;
    }

    protected override async Task<TableData<IngreAdecuacionResponse>> LoadServerData(TableState state, CancellationToken cancellationToken)
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

        if (!IsCurrent()) return new() { Items = [], TotalItems = 0 };
        Elements = items;
        TotalCount = response.TotalCount;
        return new() { Items = Elements, TotalItems = TotalCount };
    }
    protected override async Task CreateItem()
    {
        if (!HasCompany) { Snackbar.Add("Selecciona una empresa/sucursal.", Severity.Warning); return; }
        if (!AnioStateService.AnioId.HasValue) { Snackbar.Add("Selecciona un anio presupuestal.", Severity.Warning); return; }

        var dialog = await DialogService.ShowAsync(CreateDialogType, $"Crear {Title}", DialogParams(null), new DialogOptions { MaxWidth = MaxWidth.Medium, FullWidth = true });
        if ((await dialog.Result) is { Canceled: false }) await ReloadData();
    }

    protected override async Task EditItem(int id)
    {
        var item = Elements.FirstOrDefault(x => x.PkidIngreAdecuacion == id) ?? Selected;
        if (item != null && IsCaptureLocked(item)) { Snackbar.Add("La captura esta bloqueada por su estado.", Severity.Warning); return; }

        var dialog = await DialogService.ShowAsync(EditDialogType, $"Editar {Title}", DialogParams(id), new DialogOptions { MaxWidth = MaxWidth.Medium, FullWidth = true });
        if ((await dialog.Result) is { Canceled: false })
        {
            if (Selected != null) await RefreshSelected(); else await ReloadData();
        }
    }

    private DialogParameters DialogParams(int? id) => new()
    {
        ["Id"] = id,
        ["TipoAdecuacionId"] = TipoAdecuacionId,
        ["AnioId"] = AnioStateService.AnioId ?? 0
    };

    private async Task SelectItem(IngreAdecuacionResponse item) { Selected = item; await RefreshSelected(); }
    private Task BackToList()
    {
        ClearSelection();
        return Task.CompletedTask;
    }
    private async Task RefreshSelected()
    {
        if (Selected == null || disposed) return;
        var selectedId = Selected.PkidIngreAdecuacion;
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
            SelectedLocked = IsCaptureLocked(Selected);
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
    private async Task LoadBoardsAsync(int version)
    {
        var selected = Selected;
        if (selected == null || !boardLoad.IsCurrent(version)) return;
        var details = await BudgetPageReader.ReadAllAsync(
            (page, size) => DetalleService.GetAllPaginadoAsync(
                page, size, string.Empty, "PkidIngreAdecuacionDetalle", SortDirection.Ascending,
                new() { ["FkidIngreAdecuacionPres"] = selected.PkidIngreAdecuacion }),
            item => item.PkidIngreAdecuacionDetalle,
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

    }
    private async Task<TableData<IngreAdecuacionDetalleResponse>> LoadDetalleData(TableState state, CancellationToken cancellationToken)
    {
        if (Selected == null) return new() { Items = [], TotalItems = 0 };
        var filters = new Dictionary<string, object> { ["FkidIngreAdecuacionPres"] = Selected.PkidIngreAdecuacion };
        if (!AllowBothMovements) filters["FkidTipoMovimientoPres"] = DefaultMovimientoId;

        var response = await DetalleService.GetAllPaginadoAsync(Math.Max(1, state.Page + 1), state.PageSize, detalleSearch, state.SortLabel ?? "Fecha", state.SortDirection, filters);
        return new() { Items = response?.Items ?? [], TotalItems = response?.TotalCount ?? 0 };
    }

    private async Task OpenDetalle(int? id, int tipoMovimiento)
    {
        if (Selected == null || SelectedLocked) return;
        var dialog = await DialogService.ShowAsync<ModificadoIngresoDetalleDialog>(
            id.HasValue ? "Editar movimiento" : "Nuevo movimiento",
            new DialogParameters
            {
                ["Id"] = id,
                ["AdecuacionId"] = Selected.PkidIngreAdecuacion,
                ["TipoMovimientoId"] = tipoMovimiento,
                ["AnioId"] = AnioStateService.AnioId ?? 0,
                ["CurrencySymbol"] = _currencySymbol
            },
            new DialogOptions { MaxWidth = MaxWidth.Large, FullWidth = true });
        if ((await dialog.Result) is { Canceled: false }) await RefreshSelected();
    }

    private async Task DeleteDetalle(int id)
    {
        if (SelectedLocked) return;
        if (!await JS.InvokeAsync<bool>("confirm", "Eliminar este movimiento y sus renglones contables?")) return;
        var result = await DetalleService.DeleteAsync(id);
        Snackbar.Add(result?.Message ?? "Movimiento eliminado.", result?.Success == true ? Severity.Success : Severity.Error);
        await RefreshSelected();
    }




    private async Task Workflow(IngreAdecuacionResponse item, string action)
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
    private async Task ExecuteWorkflowCoreAsync(IngreAdecuacionResponse item, string action, int context)
    {
        var (title, message, confirmText, severity) = action switch
        {
            "autorizar" => (
                "Autorizar adecuación de ingreso",
                $"¿Seguro que deseas autorizar y bloquear la adecuación {item.Clave}?",
                "Autorizar",
                Severity.Success),
            "rechazar" => (
                "Rechazar adecuación de ingreso",
                $"¿Seguro que deseas rechazar y reabrir la adecuación {item.Clave}?",
                "Rechazar",
                Severity.Warning),
            _ => (
                "Enviar solicitud de autorización",
                $"¿Seguro que deseas enviar a autorización la adecuación {item.Clave}?",
                "Enviar",
                Severity.Info)
        };

        if (!await ConfirmWorkflowAsync(title, message, confirmText, severity, item.PkidIngreAdecuacion)) return;

        if (disposed || context != contextVersion)
        {
            Snackbar.Add("El contexto cambió. Abre nuevamente el registro antes de ejecutar la acción.", Severity.Warning);
            return;
        }

        using var response = await Http.PostAsync($"api/IngreAdecuacion/{item.PkidIngreAdecuacion}/{action}", null);
        var result = await response.Content.ReadFromJsonAsync<EG.Common.GenericModel.PagedResult<IngreAdecuacionResponse>>();
        if (disposed || context != contextVersion) return;
        Snackbar.Add(result?.Message ?? (response.IsSuccessStatusCode && result?.Success == true ? "Proceso realizado." : "No fue posible procesar."), response.IsSuccessStatusCode && result?.Success == true ? Severity.Success : Severity.Error);
        if (Selected != null) await RefreshSelected(); else await ReloadData();
    }

    protected override IEnumerable<object> MapToExcelData(IEnumerable<IngreAdecuacionResponse> items) => items.Select(item => new
    {
        item.Clave,
        item.TipoAdecuacionDescripcion,
        item.EstatusAdecuacionDescripcion,
        item.Justificacion,
        Fecha = item.Fecha.ToString("dd/MM/yyyy"),
        item.TotalAumento,
        item.TotalReduccion,
        item.Diferencia,
        item.ClavePoliza,
        item.Autorizado,
        item.UsuarioCreacion,
        item.FechaCreacion,
        item.UsuarioModificacion,
        item.FechaModificacion
    });

    protected override Task<string> GetItemNameForDelete(int id) => Task.FromResult(Elements.FirstOrDefault(x => x.PkidIngreAdecuacion == id)?.Clave ?? "la adecuacion");
    protected override Task ReloadData() => table?.ReloadData() ?? Task.CompletedTask;
    private Task ReloadDetalle() => detalleTable?.ReloadData() ?? Task.CompletedTask;
    private static bool IsRequestSent(IngreAdecuacionResponse item) => item.FkidAccionAdecuacionMasterPres == 2;
    private static bool IsCaptureLocked(IngreAdecuacionResponse item) => item.Autorizado || IsRequestSent(item);
    private bool CanSendRequest(IngreAdecuacionResponse item) => CanUpdate && !OperationInProgress && !IsCaptureLocked(item) && item.HasChild == true;
    private bool CanAuthorizeItem(IngreAdecuacionResponse item) => !OperationInProgress && CanAuthorize && !item.Autorizado && IsRequestSent(item);
    private string RequestTooltip(IngreAdecuacionResponse item) => item.Autorizado ? "Adecuacion autorizada" : IsRequestSent(item) ? "Solicitud enviada" : item.HasChild == true ? "Enviar solicitud" : "Agrega al menos un movimiento";
    private static string StatusText(IngreAdecuacionResponse item) => item.Autorizado ? "Autorizada" : item.FkidAccionAdecuacionMasterPres switch { 2 => "En autorizacion", 4 => "Rechazada", _ => "En captura" };
    private static Color StatusColor(IngreAdecuacionResponse item) => item.Autorizado ? Color.Success : item.FkidAccionAdecuacionMasterPres switch { 2 => Color.Info, 4 => Color.Error, _ => Color.Warning };
    private decimal MonthTotal(int month) => _detalles.Sum(item => month switch { 1 => item.Enero, 2 => item.Febrero, 3 => item.Marzo, 4 => item.Abril, 5 => item.Mayo, 6 => item.Junio, 7 => item.Julio, 8 => item.Agosto, 9 => item.Septiembre, 10 => item.Octubre, 11 => item.Noviembre, _ => item.Diciembre });
    private string Money(decimal value) => $"{_currencySymbol}{value.ToString("0.00", NumberCulture)}";
    private static string TextOrDash(string? value) => string.IsNullOrWhiteSpace(value) ? "-" : value;
    private static string FormatDateTime(DateTime? value) => value?.ToString("dd/MM/yyyy HH:mm") ?? "-";
    private void OnAnioChanged(int? anioId) => _ = InvokeAsync(ChangeContextAsync);
    private void OnEmpresaChanged(int empresaId) => _ = InvokeAsync(ChangeContextAsync);

    private async Task LoadCurrencyAsync()
    {
        var context = contextVersion;
        try
        {
            var userIdText = await JS.InvokeAsync<string>("localStorage.getItem", "userId");
            if (!int.TryParse(userIdText, out var userId)) return;
            var response = await UsuarioService.GetByIdAsync(userId);
            if (disposed || context != contextVersion) return;
            if (response?.Success != true || response.Data == null) return;
            _currencySymbol = string.IsNullOrWhiteSpace(response.Data.SimboloMonedaBase) ? "$" : response.Data.SimboloMonedaBase;
            _currencyName = string.IsNullOrWhiteSpace(response.Data.MonedaBaseEmpresa) ? "Peso Mexicano" : response.Data.MonedaBaseEmpresa;
        }
        catch (Exception ex)
        {
            AppLoggerFactory.CreateLogger("ModificadoIngresoShell")
                .LogWarning(ex, "No se pudo cargar la moneda configurada para el ingreso modificado.");
            AppSnackbar.Add("No se pudo confirmar la moneda de la empresa; se mostrara la moneda predeterminada.", Severity.Warning);
        }
    }


    private async Task ChangeContextAsync()
    {
        if (disposed) return;
        ClearSelection();
        Elements.Clear();
        TotalCount = 0;

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

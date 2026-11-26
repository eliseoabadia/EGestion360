using System.Globalization;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Web.Models;
using EG.Web.Pages.Shared;
using Microsoft.Extensions.Logging;
using MudBlazor;

namespace EG.Web.Pages.Modules.GRP.Almacen;

public partial class Recepcion_Pedidos
{
    private GenericDataGrid<OrdenCompraResponse>? table;
    private GenericDataGrid<OrdenCompraDetalleResponse>? detalleTable;
    private GenericDataGrid<AlmacenResponse>? entradasTable;
    private MudNumericField<decimal?>? quantityField;
    private MudForm? receiptForm;
    private bool validating;
    private OrdenCompraResponse? selectedOrden;
    private OrdenCompraDetalleResponse? selectedDetalle;
    private List<OrdenCompraDetalleResponse> detalles = [];
    private string detalleSearch = string.Empty;
    private string entradasSearch = string.Empty;
    private string? loadError, saveError;
    private int detalleTotal, contextVersion, selectionVersion, orderLoadVersion;
    private decimal? receiptQuantity = 1m;
    private DateTime? receiptDate = DateTime.Today;
    private bool detailLoading, saving, contextRefreshing, mustRefresh, showOrders, showHistory, disposed, pendingDetailsRefresh;
    private bool ordersReady, detailsReady;
    private Task contextInitialization = Task.CompletedTask;
    private static readonly CultureInfo NumberCulture = CultureInfo.GetCultureInfo("es-MX");
    private bool CanReceive => CanCreate && selectedOrden is not null && selectedDetalle is not null &&
        Pending(selectedDetalle) > 0 && ordersReady && detailsReady && !saving && !detailLoading && !contextRefreshing && !mustRefresh;
    private string OrderLabel => selectedOrden?.NumeroOrdenCompra ?? "Selecciona una orden";
    private IEnumerable<OrdenCompraResponse> PriorityOrders => Elements
        .OrderBy(x => x.FechaEntrega ?? x.FechaRequerida ?? DateTime.MaxValue)
        .ThenBy(x => x.FechaOrdenCompra).Take(4);
    protected override string ModuleName => "Almacen";
    protected override string SubModuleName => "Recepcion_Pedidos";
    protected override Type CreateDialogType => typeof(AlmacenDialog);
    protected override Type EditDialogType => typeof(AlmacenDialog);
    protected override Type DeleteDialogType => typeof(DeleteDialog<OrdenCompraResponse>);
    protected override string GetDefaultSortLabel() => "FechaOrdenCompra";

    protected override async Task OnInitializedAsync()
    {
        contextInitialization = InitializeContextAsync();
        await contextInitialization;
        if (disposed) return;
        AnioStateService.OnAnioChanged += OnAnioChanged;
        SucursalStateService.OnEmpresaChanged += OnEmpresaChanged;
    }

    private async Task InitializeContextAsync()
    {
        await AnioStateService.InitializeAsync();
        await SucursalStateService.InitializeAsync();
    }

    protected override async Task VerifyAccess()
    {
        // La vista base puede renderizarse mientras se restaura el contexto por JS.
        // No montar las tablas hasta conocer empresa y ejercicio.
        await contextInitialization;
        if (!disposed) await base.VerifyAccess();
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        await base.OnAfterRenderAsync(firstRender);
        if (!disposed && pendingDetailsRefresh && detalleTable is not null)
        {
            pendingDetailsRefresh = false;
            await detalleTable.ReloadData();
        }
    }

    protected override Dictionary<string, object> GetAdditionalFilters() => new()
    {
        ["FkidEstatusOrdenCompraOrco"] = 2,
        ["FkidEmpresaSis"] = SucursalStateService.EmpresaId ?? 0,
        ["FkidAnioSis"] = AnioStateService.AnioId ?? 0
    };
    private bool HasContext => SucursalStateService.EmpresaId is > 0 && AnioStateService.AnioId is > 0;

    protected override async Task<TableData<OrdenCompraResponse>> LoadServerData(TableState state, CancellationToken token)
    {
        var version = contextVersion;
        var load = ++orderLoadVersion;
        ordersReady = false;
        if (!HasContext)
        {
            Elements = []; TotalCount = 0;
            ClearSelection();
            loadError = "Selecciona empresa y ejercicio en el encabezado para consultar las órdenes.";
            return new() { Items = [], TotalItems = 0 };
        }
        CurrentPage = state.Page + 1; PageSize = state.PageSize;
        SortLabel = state.SortLabel ?? GetDefaultSortLabel(); SortDirection = state.SortDirection;
        var response = await Service.GetAllPaginadoAsync(CurrentPage, PageSize, SearchString, SortLabel, SortDirection, GetAdditionalFilters());
        if (disposed || version != contextVersion || load != orderLoadVersion || token.IsCancellationRequested)
            return new() { Items = [], TotalItems = 0 };
        if (response?.Success != true)
        {
            loadError = "No se pudieron cargar las órdenes. Actualiza para intentar nuevamente.";
            EnsureSuccess(response);
        }
        Elements = response!.Items.ToList(); TotalCount = response.TotalCount; loadError = null; ordersReady = true;
        if (selectedOrden is null && Elements.Count > 0)
        {
            selectedOrden = PriorityOrders.First();
            selectionVersion++;
            if (detalleTable is not null) await detalleTable.ReloadData();
            else pendingDetailsRefresh = true;
        }
        await InvokeAsync(StateHasChanged);
        return new() { Items = Elements, TotalItems = TotalCount };
    }

    private async Task<TableData<OrdenCompraDetalleResponse>> LoadDetalleData(TableState state, CancellationToken token)
    {
        var order = selectedOrden;
        if (order is null || !HasContext) return new() { Items = [], TotalItems = 0 };
        var version = selectionVersion;
        detailLoading = true; detailsReady = false;
        try
        {
            var response = await OrdenDetalleService.GetAllPaginadoAsync(state.Page + 1, state.PageSize,
                detalleSearch, state.SortLabel ?? "TipoBienDescripcion", state.SortDirection,
                new() { ["FkidOrdenCompraOrco"] = order.PkidOrdenCompra });
            if (disposed || version != selectionVersion || token.IsCancellationRequested) return new() { Items = [], TotalItems = 0 };
            EnsureSuccess(response);
            detalles = response.Items.ToList(); detalleTotal = response.TotalCount;
            detailsReady = true;
            var current = detalles.FirstOrDefault(x => x.PkidOrdenCompraDetalle == selectedDetalle?.PkidOrdenCompraDetalle);
            if (current is not null && Pending(current) > 0) selectedDetalle = current;
            else SetDetail(detalles.FirstOrDefault(x => Pending(x) > 0));
            loadError = null;
            await InvokeAsync(StateHasChanged);
            return new() { Items = detalles, TotalItems = detalleTotal };
        }
        catch (Exception ex)
        {
            if (version == selectionVersion && !disposed)
            {
                selectedDetalle = null; detalles = []; detalleTotal = 0;
                loadError = "No se pudieron cargar los renglones. Actualiza para intentar nuevamente.";
                Logger.LogWarning(ex, "No se pudieron preparar los renglones de recepcion.");
            }
            throw;
        }
        finally
        {
            if (version == selectionVersion)
            {
                detailLoading = false;
                if (!disposed) await InvokeAsync(StateHasChanged);
            }
        }
    }

    private async Task SelectOrden(OrdenCompraResponse? order)
    {
        if (saving || disposed || order is null || selectedOrden?.PkidOrdenCompra == order.PkidOrdenCompra) return;
        ClearSelection(); selectedOrden = order; detalleSearch = string.Empty;
        if (detalleTable is not null) await detalleTable.ReloadData();
    }
    private void SetDetail(OrdenCompraDetalleResponse? detail)
    {
        selectedDetalle = detail;
        receiptQuantity = detail is null ? null : Math.Min(1m, Pending(detail));
        saveError = null;
    }
    private async Task SelectDetalle(OrdenCompraDetalleResponse? detail)
    {
        if (saving || detailLoading || detail?.FkidOrdenCompraOrco != selectedOrden?.PkidOrdenCompra) return;
        SetDetail(detail);
        if (showHistory && entradasTable is not null) await entradasTable.ReloadData();
    }
    private async Task PrepareReceiptAsync(OrdenCompraDetalleResponse detail)
    {
        await SelectDetalle(detail);
        await FocusReceiptAsync();
    }
    private async Task FocusReceiptAsync()
    {
        if (CanReceive && quantityField is not null) await quantityField.FocusAsync();
    }
    private void ResetCapture()
    {
        receiptQuantity = selectedDetalle is null ? null : Math.Min(1m, Pending(selectedDetalle));
        receiptDate = DateTime.Today; saveError = null;
    }

    private async Task<IEnumerable<OrdenCompraResponse>> SearchOrdersAsync(string text, CancellationToken token)
    {
        var version = contextVersion;
        if (!HasContext || disposed) return [];
        var result = await Service.GetAllPaginadoAsync(1, 20, text, GetDefaultSortLabel(), SortDirection.Ascending, GetAdditionalFilters());
        if (version != contextVersion || disposed || token.IsCancellationRequested) return [];
        EnsureSuccess(result);
        return result.Items;
    }
    private async Task<IEnumerable<OrdenCompraDetalleResponse>> SearchDetailsAsync(string text, CancellationToken token)
    {
        var order = selectedOrden; var version = selectionVersion;
        if (order is null || disposed) return [];
        var result = await OrdenDetalleService.GetAllPaginadoAsync(1, 20, text, "TipoBienDescripcion", SortDirection.Ascending,
            new() { ["FkidOrdenCompraOrco"] = order.PkidOrdenCompra });
        if (version != selectionVersion || disposed || token.IsCancellationRequested) return [];
        EnsureSuccess(result);
        return result.Items.Where(x => Pending(x) > 0);
    }

    private async Task ConfirmReceiptAsync()
    {
        if (!CanReceive || validating || selectedDetalle is null) return;
        var validationContext = contextVersion;
        var validationDetail = selectedDetalle.PkidOrdenCompraDetalle;
        validating = true;
        try
        {
            if (receiptForm is not null)
            {
                await receiptForm.Validate();
                if (!receiptForm.IsValid) return;
            }
        }
        finally { validating = false; }
        if (!CanReceive || disposed || validationContext != contextVersion || selectedDetalle?.PkidOrdenCompraDetalle != validationDetail) return;
        if (receiptQuantity is null || receiptQuantity <= 0 || receiptQuantity > Pending(selectedDetalle))
        { saveError = "Captura una cantidad mayor a cero y hasta el saldo pendiente."; return; }
        if (decimal.Round(receiptQuantity.Value, 4) != receiptQuantity.Value)
        { saveError = "La cantidad admite hasta cuatro decimales."; return; }
        if (receiptDate is null || receiptDate == default(DateTime))
        { saveError = "Captura una fecha de entrada válida."; return; }
        if (!int.TryParse(AnioStateService.AnioTexto, out var year))
            year = AnioStateService.AnioClave ?? 0;
        if (year > 0 && receiptDate.Value.Year != year)
        { saveError = "La fecha debe pertenecer al ejercicio seleccionado."; return; }
        var version = contextVersion;
        var detail = selectedDetalle;
        saving = true; saveError = null;
        try
        {
            var result = await AlmacenService.CreateAsync(new AlmacenResponse
            {
                FkidEmpresaSis = SucursalStateService.EmpresaId!.Value, FkidAnioSis = AnioStateService.AnioId,
                FkidDetalleOrdenCompraOrco = detail.PkidOrdenCompraDetalle, FkidTipoBienAlma = detail.FkidTipoBienAlma,
                FkidUnidadesAlma = detail.FkidUnidadesAlma, Cantidad = receiptQuantity.Value,
                CostoUnitario = detail.PrecioUnitario, FechaEntrada = receiptDate.Value.Date, AplicaAlmacen = true, Activo = true
            });
            if (disposed || version != contextVersion) return;
            if (result.Success)
            {
                Snackbar.Add(result.Message, Severity.Success);
                SetDetail(null);
                await RefreshAll();
            }
            else
            {
                saveError = string.IsNullOrWhiteSpace(result.Message) ? "No se pudo confirmar la entrada." : result.Message;
                mustRefresh = true;
                saveError += " Actualiza para comprobar las entradas y el saldo antes de volver a confirmar.";
                showHistory = true;
            }
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "No se pudo confirmar la recepcion rapida.");
            if (!disposed && version == contextVersion)
            {
                mustRefresh = true; showHistory = true;
                saveError = "No se pudo confirmar el resultado. Actualiza y revisa las entradas antes de volver a registrar.";
            }
        }
        finally { saving = false; }
    }

    private string? ValidateReceiptQuantity(decimal? value)
    {
        if (value is null || value <= 0) return "Captura una cantidad mayor a cero.";
        if (selectedDetalle is null || value > Pending(selectedDetalle)) return "La cantidad excede el saldo pendiente.";
        return decimal.Round(value.Value, 4) != value.Value ? "La cantidad admite hasta cuatro decimales." : null;
    }

    private async Task OpenCompleteFormAsync()
    {
        if (!CanReceive || selectedDetalle is null) return;
        var detail = selectedDetalle; var version = contextVersion;
        saving = true;
        try
        {
            var dialog = await DialogService.ShowAsync<AlmacenDialog>("Registrar entrada", new DialogParameters
            {
                ["OrdenDetalleId"] = detail.PkidOrdenCompraDetalle, ["TipoBienId"] = detail.FkidTipoBienAlma,
                ["TipoBienText"] = $"{detail.TipoBienCodigoClave} · {detail.TipoBienDescripcion}",
                ["UnidadId"] = detail.FkidUnidadesAlma, ["UnidadText"] = detail.UnidadMedida,
                ["CantidadSugerida"] = receiptQuantity ?? 1m, ["CostoSugerido"] = detail.PrecioUnitario
            }, new() { MaxWidth = MaxWidth.Medium, FullWidth = true });
            if (await dialog.Result is { Canceled: false } && version == contextVersion && !disposed)
                await RefreshAll();
        }
        finally { saving = false; }
    }

    private async Task ShowHistoryAsync(OrdenCompraDetalleResponse detail)
    {
        await SelectDetalle(detail);
        var wasOpen = showHistory; showHistory = true; entradasSearch = string.Empty;
        if (wasOpen && entradasTable is not null) await entradasTable.ReloadData();
    }
    private async Task<TableData<AlmacenResponse>> LoadEntradasData(TableState state, CancellationToken token)
    {
        var detail = selectedDetalle; var version = selectionVersion;
        if (detail is null || !HasContext) return new() { Items = [], TotalItems = 0 };
        var response = await AlmacenService.GetAllPaginadoAsync(state.Page + 1, state.PageSize, entradasSearch,
            "FechaEntrada", SortDirection.Descending, new()
            {
                ["FkidDetalleOrdenCompraOrco"] = detail.PkidOrdenCompraDetalle,
                ["FkidEmpresaSis"] = SucursalStateService.EmpresaId!.Value, ["FkidAnioSis"] = AnioStateService.AnioId!.Value
            });
        if (disposed || token.IsCancellationRequested || version != selectionVersion || selectedDetalle?.PkidOrdenCompraDetalle != detail.PkidOrdenCompraDetalle)
            return new() { Items = [], TotalItems = 0 };
        EnsureSuccess(response);
        return new() { Items = response.Items, TotalItems = response.TotalCount };
    }

    private void ToggleOrders() => showOrders = !showOrders;
    private async Task RefreshAll()
    {
        if (disposed) return;
        contextRefreshing = true;
        try
        {
            if (table is not null) await table.ReloadData();
            if (detalleTable is not null) await detalleTable.ReloadData();
            if (showHistory && entradasTable is not null) await entradasTable.ReloadData();
            // Un error conserva el bloqueo de reintento: el usuario debe poder comprobar el saldo.
            if (loadError is null && ordersReady && detailsReady) { mustRefresh = false; saveError = null; }
        }
        finally { contextRefreshing = false; }
    }
    private void ClearSelection()
    {
        selectionVersion++; selectedOrden = null; selectedDetalle = null; detalles = []; detalleTotal = 0;
        detailLoading = false; detailsReady = false; showHistory = false; receiptQuantity = null;
    }
    private void OnEmpresaChanged(int _) => QueueContextRefresh();
    private void OnAnioChanged(int? _) => QueueContextRefresh();
    private void QueueContextRefresh() => _ = InvokeAsync(async () =>
    {
        if (disposed) return;
        contextVersion++; ClearSelection(); Elements = []; TotalCount = 0; SearchString = detalleSearch = string.Empty;
        try { await RefreshAll(); }
        catch (Exception ex) { Logger.LogError(ex, "Error al cambiar contexto de recepcion."); loadError = "No se pudo actualizar el contexto. Intenta nuevamente."; }
        if (!disposed) StateHasChanged();
    });
    private Task OnDetalleSearch() => detalleTable?.ReloadData() ?? Task.CompletedTask;
    private Task OnEntradasSearch() => entradasTable?.ReloadData() ?? Task.CompletedTask;
    protected override Task ReloadData() => RefreshAll();
    protected override async Task<List<OrdenCompraResponse>> LoadExportItemsAsync()
    {
        if (!HasContext) return [];
        var result = new List<OrdenCompraResponse>(); var version = contextVersion;
        for (var page = 1; result.Count < MaxExportRows; page++)
        {
            var response = await Service.GetAllPaginadoAsync(page, ExportPageSize, SearchString,
                GetDefaultSortLabel(), SortDirection, GetAdditionalFilters());
            if (version != contextVersion || disposed) throw new OperationCanceledException("El contexto cambió durante la exportación.");
            EnsureSuccess(response); result.AddRange(response.Items);
            if (response.Items.Count == 0 || result.Count >= response.TotalCount) break;
        }
        return result.Take(MaxExportRows).ToList();
    }
    protected override IEnumerable<object> MapToExcelData(IEnumerable<OrdenCompraResponse> items) => items.Select(x => new
    { x.NumeroOrdenCompra, x.ProveedorNombre, Fecha = x.FechaOrdenCompra.ToString("dd/MM/yyyy"), x.Subtotal, x.Iva, x.Total, x.MonedaNombre, x.EstatusDescripcion });
    private static void EnsureSuccess<T>(ApiResponse<T>? response)
    {
        if (response?.Success != true) throw new InvalidOperationException("No se pudo consultar la información de recepción.");
    }
    private static decimal Pending(OrdenCompraDetalleResponse item) => Math.Max(0m, item.CantidadPendiente ?? item.CantidadSolicitada - item.CantidadRecibida);
    private static double Progress(OrdenCompraDetalleResponse item) => item.CantidadSolicitada <= 0 ? 0 : (double)Math.Clamp(item.CantidadRecibida / item.CantidadSolicitada * 100m, 0m, 100m);
    private static string Qty(decimal value) => value.ToString("#,##0.####", CultureInfo.InvariantCulture);
    private static string DeliveryLabel(OrdenCompraResponse order)
    {
        var date = order.FechaEntrega ?? order.FechaRequerida;
        return date is null ? "Sin fecha de entrega" : date.Value.Date < DateTime.Today ? $"Entrega prevista: {date:dd/MM/yyyy}" : date.Value.Date == DateTime.Today ? "Entrega prevista hoy" : $"Entrega: {date:dd/MM/yyyy}";
    }
    public void Dispose()
    {
        disposed = true; contextVersion++; selectionVersion++;
        SucursalStateService.OnEmpresaChanged -= OnEmpresaChanged; AnioStateService.OnAnioChanged -= OnAnioChanged;
        SearchCts?.Cancel(); SearchCts?.Dispose();
    }
}

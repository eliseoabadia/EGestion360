using EG.Web.Services;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.JSInterop;

namespace EG.UnidTest.Presentation;

public sealed class CompanyStateTests
{
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("null")]
    [InlineData("{}")]
    [InlineData("invalid-json")]
    [InlineData("{\"Id\":1,\"EmpresaId\":0}")]
    public async Task InvalidStoredBranchClearsPreviousCompanyAndHeader(string? stored)
    {
        var storage = new Storage();
        using var client = new HttpClient();
        var state = Create(storage, client);
        await state.SetSucursalAsync(1, "Anterior", 7);
        storage.Value = stored;
        await state.InitializeAsync();
        Assert.Null(state.EmpresaId);
        Assert.Null(state.SucursalId);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
    }

    [Fact]
    public async Task ClearingRemovesHeaderEvenIfBrowserStorageFails()
    {
        var storage = new Storage();
        using var client = new HttpClient();
        var state = Create(storage, client);
        await state.SetSucursalAsync(1, "Anterior", 7);
        storage.Fail = true;
        var notified = false;
        state.OnEmpresaChanged += id => notified = id == 0;
        await Assert.ThrowsAsync<JSException>(() => state.ClearSucursalAsync());
        Assert.Null(state.EmpresaId);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
        Assert.True(notified);
    }

    [Fact]
    public async Task FailedBranchPersistenceClearsPartiallySelectedCompany()
    {
        var storage = new Storage();
        using var client = new HttpClient();
        var state = Create(storage, client);
        await state.SetSucursalAsync(1, "Anterior", 7);
        storage.Fail = true;
        var cleared = false;
        state.OnEmpresaChanged += id => cleared = id == 0;
        await Assert.ThrowsAsync<JSException>(() => state.SetSucursalAsync(2, "Nueva", 8));
        Assert.Null(state.EmpresaId);
        Assert.Null(state.SucursalId);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
        Assert.True(cleared);
    }

    [Fact]
    public async Task BranchWithoutCompanyDoesNotReuseOldCompanyHeader()
    {
        var storage = new Storage();
        using var client = new HttpClient();
        var state = Create(storage, client);
        await state.SetSucursalAsync(1, "Anterior", 7);
        await state.SetSucursalAsync(2, "Nueva");
        Assert.Null(state.EmpresaId);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
    }

    [Fact]
    public async Task LateCompanyDescriptionCannotSwitchActiveBranchCompany()
    {
        using var client = new HttpClient();
        var state = Create(new Storage(), client);
        await state.SetSucursalAsync(2, "Actual", 8, "Empresa actual");
        var notifications = 0;
        state.OnEmpresaChanged += _ => notifications++;
        await state.SetEmpresaInfoAsync(7, "Respuesta antigua", "Anterior");
        Assert.Equal(8, state.EmpresaId);
        Assert.Equal(2, state.SucursalId);
        Assert.Equal("Empresa actual", state.EmpresaNombre);
        Assert.Equal("8", Assert.Single(client.DefaultRequestHeaders.GetValues("X-Empresa-Id")));
        Assert.Equal(0, notifications);
    }

    [Fact]
    public async Task LateCompanyDescriptionCannotRestoreClearedSession()
    {
        using var client = new HttpClient();
        var state = Create(new Storage(), client);
        await state.SetSucursalAsync(1, "Anterior", 7);
        await state.ClearSucursalAsync();
        await state.SetEmpresaInfoAsync(7, "Respuesta antigua", "Anterior");
        Assert.Null(state.EmpresaId);
        Assert.Null(state.EmpresaNombre);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
    }

    [Fact]
    public async Task CurrentCompanyDescriptionCanRefreshWithoutChangingBranch()
    {
        using var client = new HttpClient();
        var state = Create(new Storage(), client);
        await state.SetSucursalAsync(2, "Actual", 8);
        await state.SetEmpresaInfoAsync(8, "  Empresa actual  ", "Actual", notify: false);
        Assert.Equal("Empresa actual", state.EmpresaNombre);
        Assert.Equal("Actual", state.EmpresaNombreCorto);
        Assert.Equal(2, state.SucursalId);
    }

    private static SucursalStateService Create(Storage storage, HttpClient client) =>
        new(storage, client, NullLogger<SucursalStateService>.Instance);

    [Fact]
    public async Task OverlappingSelectionsPersistLatestBranchAndCompanyTogether()
    {
        var browser = new DelayedStorage();
        using var client = new HttpClient();
        var state = new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance);
        var notifications = new List<int>();
        state.OnEmpresaChanged += notifications.Add;

        var first = state.SetSucursalAsync(1, "Anterior", 7);
        await browser.WriteStarted.Task;
        var latest = state.SetSucursalAsync(2, "Actual", 8);
        browser.ContinueWrite.SetResult();
        await Task.WhenAll(first, latest);

        Assert.Equal("8", browser.Values["empresa_seleccionada"]);
        Assert.Contains("\"Id\":2", browser.Values["sucursal_seleccionada"]);
        Assert.Equal(new[] { 8 }, notifications);
        Assert.Equal(8, state.EmpresaId);
    }

    [Fact]
    public async Task ClearWhileSelectionIsSavingCannotRestoreStoredCompany()
    {
        var browser = new DelayedStorage();
        using var client = new HttpClient();
        var state = new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance);
        var first = state.SetSucursalAsync(1, "Anterior", 7);
        await browser.WriteStarted.Task;
        var clear = state.ClearSucursalAsync();
        browser.ContinueWrite.SetResult();
        await Task.WhenAll(first, clear);

        Assert.Empty(browser.Values);
        Assert.Null(state.EmpresaId);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
    }

    private sealed class DelayedStorage : IJSRuntime
    {
        public Dictionary<string, string> Values { get; } = [];
        public TaskCompletionSource WriteStarted { get; } = new();
        public TaskCompletionSource ContinueWrite { get; } = new();
        private bool delayed;

        public ValueTask<T> InvokeAsync<T>(string identifier, object?[]? args) =>
            InvokeAsync<T>(identifier, default, args);

        public async ValueTask<T> InvokeAsync<T>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            var key = (string)args![0]!;
            if (identifier == "localStorage.setItem")
            {
                if (!delayed)
                {
                    delayed = true;
                    WriteStarted.SetResult();
                    await ContinueWrite.Task;
                }
                Values[key] = (string)args[1]!;
            }
            if (identifier == "localStorage.removeItem") Values.Remove(key);
            return identifier == "localStorage.getItem" ? (T)(object)Values.GetValueOrDefault(key)! : default!;
        }
    }

    [Fact]
    public async Task LegacyCompanyKeyCannotRestoreCompanyWithoutValidBranch()
    {
        var browser = new DelayedStorage();
        browser.Values["empresa_seleccionada"] = "7";
        using var client = new HttpClient();
        var state = new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance);
        Assert.Null(await state.GetEmpresaIdAsync());
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
    }

    [Fact]
    public async Task FailedStorageCleanupCannotRestoreCompanyThroughFallbackGetter()
    {
        var storage = new Storage();
        using var client = new HttpClient();
        var state = Create(storage, client);
        await state.SetSucursalAsync(1, "Anterior", 7);
        storage.Fail = true;
        await Assert.ThrowsAsync<JSException>(() => state.ClearSucursalAsync());
        storage.Fail = false;
        storage.Value = "7";
        Assert.Null(await state.GetEmpresaIdAsync());
    }

    private sealed class Storage : IJSRuntime
    {
        public string? Value { get; set; }
        public bool Fail { get; set; }
        public ValueTask<T> InvokeAsync<T>(string identifier, object?[]? args) =>
            InvokeAsync<T>(identifier, default, args);
        public ValueTask<T> InvokeAsync<T>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            if (Fail) throw new JSException("Storage unavailable");
            return ValueTask.FromResult(identifier == "localStorage.getItem" ? (T)(object)Value! : default!);
        }
    }
}

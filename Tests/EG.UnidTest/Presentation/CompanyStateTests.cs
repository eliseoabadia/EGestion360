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

    private static SucursalStateService Create(Storage storage, HttpClient client) =>
        new(storage, client, NullLogger<SucursalStateService>.Instance);

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

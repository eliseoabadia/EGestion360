using EG.Web.Auth;
using EG.Web.Services;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.JSInterop;

namespace EG.UnidTest.Presentation;

public sealed class SessionCleanupTests
{
    [Fact]
    public async Task LogoutClearsMemoryAndAttemptsAllKeysWhenTokenRemovalFails()
    {
        var browser = new Storage();
        using var client = new HttpClient();
        var branch = new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance);
        var year = new AnioPresupuestalStateService(browser);
        await branch.SetSucursalAsync(1, "Actual", 7);
        await year.SetAnioAsync(1, 2026, "Actual");
        client.DefaultRequestHeaders.Authorization = new("Bearer", "old-token");
        browser.FailRemovals = true;
        var provider = new AuthenticationProviderJWT(browser, client,
            NullLogger<AuthenticationProviderJWT>.Instance, branch, year);

        await provider.LogoutAsync();

        Assert.Null(client.DefaultRequestHeaders.Authorization);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
        Assert.Null(branch.EmpresaId);
        Assert.Null(year.AnioId);
        Assert.Contains("authToken", browser.RemovalAttempts);
        Assert.Contains("dbPermissionClaims", browser.RemovalAttempts);
        Assert.Contains("userId", browser.RemovalAttempts);
        Assert.Contains("userName", browser.RemovalAttempts);
        Assert.Contains("sucursal_seleccionada", browser.RemovalAttempts);
        Assert.Contains("anio_presupuestal_seleccionado", browser.RemovalAttempts);
        Assert.False((await provider.GetAuthenticationStateAsync()).User.Identity?.IsAuthenticated);
        Assert.Equal(0, browser.Reads);
    }

    [Fact]
    public async Task NewLoginClearsPreviousWorkspaceBeforeActivatingToken()
    {
        var browser = new Storage();
        using var client = new HttpClient();
        var branch = new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance);
        var year = new AnioPresupuestalStateService(browser);
        await branch.SetSucursalAsync(1, "Anterior", 7);
        await year.SetAnioAsync(1, 2026, "Anterior");
        var provider = new AuthenticationProviderJWT(browser, client,
            NullLogger<AuthenticationProviderJWT>.Instance, branch, year);
        // The browser only parses JWT claims; signature authorization remains on the API.
        var payload = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(
            "{\"sub\":\"new-user\",\"exp\":4102444800}"));
        await provider.LoginAsync("header." + payload + ".test-signature");
        Assert.Null(branch.EmpresaId);
        Assert.Null(year.AnioId);
        Assert.False(client.DefaultRequestHeaders.Contains("X-Empresa-Id"));
        Assert.NotNull(client.DefaultRequestHeaders.Authorization);
    }

    [Fact]
    public async Task YearCleanupNotifiesSubscribersEvenIfStorageFails()
    {
        var browser = new Storage();
        var year = new AnioPresupuestalStateService(browser);
        await year.SetAnioAsync(1, 2026, "Actual");
        var cleared = false;
        year.OnAnioChanged += id => cleared = id == null;
        browser.FailRemovals = true;
        await Assert.ThrowsAsync<JSException>(() => year.ClearAnioAsync());
        Assert.Null(year.AnioId);
        Assert.True(cleared);
    }

    private sealed class Storage : IJSRuntime
    {
        public bool FailRemovals { get; set; }
        public List<string> RemovalAttempts { get; } = [];
        public int Reads { get; private set; }
        public ValueTask<T> InvokeAsync<T>(string identifier, object?[]? args) =>
            InvokeAsync<T>(identifier, default, args);
        public ValueTask<T> InvokeAsync<T>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            if (identifier == "localStorage.getItem") Reads++;
            if (identifier == "localStorage.removeItem")
            {
                RemovalAttempts.Add((string)args![0]!);
                if (FailRemovals) throw new JSException("Storage unavailable");
            }
            return ValueTask.FromResult(default(T)!);
        }
    }
}

using EG.Web.Auth;
using EG.Web.Services;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.JSInterop;

namespace EG.UnidTest.Presentation;

public sealed class SessionRaceTests
{
    [Fact]
    public async Task PreviousAccountsPermissionResponseCannotReplaceCurrentPermissions()
    {
        var browser = new DelayedWriteStorage { DelayPermissionWrite = false };
        using var client = new HttpClient();
        var provider = new AuthenticationProviderJWT(browser, client,
            NullLogger<AuthenticationProviderJWT>.Instance,
            new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance),
            new AnioPresupuestalStateService(browser));
        string TokenFor(string user) => "header." + Convert.ToBase64String(
            System.Text.Encoding.UTF8.GetBytes("{\"sub\":\"" + user + "\",\"exp\":4102444800}")) + ".test-signature";
        var previous = TokenFor("previous");
        var current = TokenFor("current");
        await provider.LoginAsync(previous);
        await provider.LoginAsync(current);
        await provider.LoadClaimsFromDbAsync([
            new() { Group = "Test", SubGroup = "Module", Values = "view" }
        ], current);
        var storedPermissions = browser.Values["dbPermissionClaims"];

        await provider.LoadClaimsFromDbAsync([
            new() { Group = "Test", SubGroup = "Module", Values = "update" }
        ], previous);

        Assert.True(provider.HasPermission("Test", "Module", "view"));
        Assert.False(provider.HasPermission("Test", "Module", "update"));
        Assert.Equal(storedPermissions, browser.Values["dbPermissionClaims"]);
        Assert.Equal(current, client.DefaultRequestHeaders.Authorization?.Parameter);
    }

    [Fact]
    public async Task PendingPermissionWriteFinishesBeforeLogoutRemovesIt()
    {
        var browser = new DelayedWriteStorage();
        using var client = new HttpClient();
        var provider = new AuthenticationProviderJWT(browser, client,
            NullLogger<AuthenticationProviderJWT>.Instance,
            new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance),
            new AnioPresupuestalStateService(browser));
        var payload = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(
            "{\"sub\":\"test-user\",\"exp\":4102444800}"));
        var token = "header." + payload + ".test-signature";
        await provider.LoginAsync(token);
        var permissions = provider.LoadClaimsFromDbAsync([
            new() { Group = "Test", SubGroup = "Module", Values = "update" }
        ], token);
        await browser.WriteStarted.Task;
        var logout = provider.LogoutAsync();
        browser.ResumeWrite.SetResult();
        await Task.WhenAll(permissions, logout);
        Assert.False(browser.Values.ContainsKey("dbPermissionClaims"));
        Assert.False(browser.Values.ContainsKey("authToken"));
        Assert.False(provider.HasPermission("Test", "Module", "update"));
        Assert.Null(client.DefaultRequestHeaders.Authorization);
    }

    [Theory]
    [InlineData("authToken")]
    [InlineData("dbPermissionClaims")]
    public async Task DelayedReadCannotRestoreSessionOrPermissionsAfterLogout(string delayedKey)
    {
        var browser = new DelayedStorage(delayedKey);
        using var client = new HttpClient();
        var provider = new AuthenticationProviderJWT(browser, client,
            NullLogger<AuthenticationProviderJWT>.Instance,
            new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance),
            new AnioPresupuestalStateService(browser));

        var read = provider.GetAuthenticationStateAsync();
        await browser.ReadStarted.Task;
        await provider.LogoutAsync();
        browser.ResumeRead.SetResult();
        var state = await read;

        Assert.False(state.User.Identity?.IsAuthenticated);
        Assert.Null(client.DefaultRequestHeaders.Authorization);
        Assert.False(provider.HasPermission("Test", "Module", "update"));
        Assert.False((await provider.GetAuthenticationStateAsync()).User.Identity?.IsAuthenticated);
    }

    private sealed class DelayedStorage(string delayedKey) : IJSRuntime
    {
        public TaskCompletionSource ReadStarted { get; } = new();
        public TaskCompletionSource ResumeRead { get; } = new();

        public ValueTask<T> InvokeAsync<T>(string identifier, object?[]? args) =>
            InvokeAsync<T>(identifier, default, args);

        public async ValueTask<T> InvokeAsync<T>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            if (identifier != "localStorage.getItem") return default!;
            var key = (string)args![0]!;
            if (key == delayedKey)
            {
                ReadStarted.TrySetResult();
                await ResumeRead.Task;
            }
            var payload = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(
                "{\"sub\":\"test-user\",\"exp\":4102444800}"));
            var value = key == "authToken"
                ? "header." + payload + ".test-signature"
                : "[{\"Group\":\"Test\",\"SubGroup\":\"Module\",\"Values\":\"update\"}]";
            return (T)(object)value;
        }
    }

    private sealed class DelayedWriteStorage : IJSRuntime
    {
        public bool DelayPermissionWrite { get; set; } = true;
        public Dictionary<string, string> Values { get; } = [];
        public TaskCompletionSource WriteStarted { get; } = new();
        public TaskCompletionSource ResumeWrite { get; } = new();
        public ValueTask<T> InvokeAsync<T>(string identifier, object?[]? args) =>
            InvokeAsync<T>(identifier, default, args);
        public async ValueTask<T> InvokeAsync<T>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            var key = (string)args![0]!;
            if (identifier == "localStorage.setItem")
            {
                if (key == "dbPermissionClaims" && DelayPermissionWrite)
                {
                    WriteStarted.TrySetResult();
                    await ResumeWrite.Task;
                }
                Values[key] = (string)args[1]!;
            }
            if (identifier == "localStorage.removeItem") Values.Remove(key);
            return default!;
        }
    }
}

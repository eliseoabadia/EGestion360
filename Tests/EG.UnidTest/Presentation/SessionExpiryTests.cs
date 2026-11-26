using EG.Web.Auth;
using EG.Web.Services;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.JSInterop;
using System.Text;

namespace EG.UnidTest.Presentation;

public sealed class SessionExpiryTests
{
    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task CachedSessionStopsGrantingPermissionsWhenTokenExpires(bool superAdmin)
    {
        var clock = new Clock();
        var browser = new Storage();
        using var client = new HttpClient();
        var branch = new SucursalStateService(browser, client, NullLogger<SucursalStateService>.Instance);
        var year = new AnioPresupuestalStateService(browser);
        var provider = new AuthenticationProviderJWT(browser, client,
            NullLogger<AuthenticationProviderJWT>.Instance, branch, year, clock);
        var token = Token("\"exp\":" + clock.Now.AddMinutes(2).ToUnixTimeSeconds() +
            (superAdmin ? ",\"role\":\"SuperAdmin\"" : ""));
        await provider.LoginAsync(token);
        await provider.LoadClaimsFromDbAsync([new() { Group = "Test", SubGroup = "Module", Values = "update" }], token);
        await branch.SetSucursalAsync(1, "Actual", 7);
        await year.SetAnioAsync(1, 2026, "Actual");
        Assert.Equal(42, provider.GetUserId());
        Assert.True(provider.HasPermission("Test", "Module", "update"));
        Assert.Equal(superAdmin, provider.HasPermission("Other", "Unassigned", "view"));

        clock.Now = clock.Now.AddMinutes(3);

        Assert.Null(provider.GetUserId());
        Assert.False(provider.HasPermission("Test", "Module", "update"));
        Assert.False((await provider.GetAuthenticationStateAsync()).User.Identity?.IsAuthenticated);
        Assert.Null(client.DefaultRequestHeaders.Authorization);
        Assert.Null(branch.EmpresaId);
        Assert.Null(year.AnioId);
        Assert.False(browser.Values.ContainsKey("authToken"));
    }

    [Theory]
    [InlineData("")]
    [InlineData("\"exp\":\"invalid\"")]
    [InlineData("\"exp\":9223372036854775807")]
    [InlineData("\"exp\":-9223372036854775808")]
    public async Task MissingOrOutOfRangeExpirationCannotActivateSession(string expiration)
    {
        var browser = new Storage();
        using var client = new HttpClient();
        var provider = Create(browser, client);
        await provider.LoginAsync(Token(expiration));
        Assert.Null(client.DefaultRequestHeaders.Authorization);
        Assert.Null(provider.GetUserId());
        Assert.False((await provider.GetAuthenticationStateAsync()).User.Identity?.IsAuthenticated);
    }

    [Fact]
    public async Task MissingBrowserTokenRemovesCachedAuthenticationAndPermissions()
    {
        var browser = new Storage();
        using var client = new HttpClient();
        var provider = Create(browser, client);
        await provider.LoginAsync(Token("\"exp\":4102444800"));
        browser.Values.Remove("authToken");
        Assert.Null(await provider.GetUserIdAsync());
        Assert.Null(provider.GetUserId());
        Assert.Null(client.DefaultRequestHeaders.Authorization);
    }

    private static AuthenticationProviderJWT Create(Storage browser, HttpClient client) => new(
        browser, client, NullLogger<AuthenticationProviderJWT>.Instance,
        new(browser, client, NullLogger<SucursalStateService>.Instance), new(browser));

    private static string Token(string expiration) => "header." + Convert.ToBase64String(
        Encoding.UTF8.GetBytes("{\"sub\":\"42\"" + (expiration.Length == 0 ? "" : "," + expiration) + "}")) + ".test-signature";

    private sealed class Clock : TimeProvider
    {
        public DateTimeOffset Now { get; set; } = new(2030, 1, 1, 0, 0, 0, TimeSpan.Zero);
        public override DateTimeOffset GetUtcNow() => Now;
    }

    private sealed class Storage : IJSRuntime
    {
        public Dictionary<string, string> Values { get; } = [];
        public ValueTask<T> InvokeAsync<T>(string identifier, object?[]? args) => InvokeAsync<T>(identifier, default, args);
        public ValueTask<T> InvokeAsync<T>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            var key = (string)args![0]!;
            if (identifier == "localStorage.setItem") Values[key] = (string)args[1]!;
            if (identifier == "localStorage.removeItem") Values.Remove(key);
            return ValueTask.FromResult(identifier == "localStorage.getItem" ? (T)(object)Values.GetValueOrDefault(key)! : default!);
        }
    }
}

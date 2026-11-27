using EG.Web.Services;
using Microsoft.JSInterop;

namespace EG.UnidTest.Presentation;

public sealed class BudgetYearStateTests
{
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("null")]
    [InlineData("{}")]
    [InlineData("{\"Id\":0}")]
    [InlineData("{invalid-json")]
    public async Task MissingOrInvalidStorageCannotKeepAPreviousFiscalYear(string? stored)
    {
        var browser = new Storage();
        var state = new AnioPresupuestalStateService(browser);
        await state.SetAnioAsync(7, 2026, "Ejercicio previo");
        browser.Value = stored;

        await state.InitializeAsync();

        Assert.Null(state.AnioId);
        Assert.Null(state.AnioClave);
        Assert.Equal(string.Empty, state.AnioDescripcion);
    }

    [Fact]
    public async Task InitializationUsesTheCurrentStoredYear()
    {
        var browser = new Storage();
        var state = new AnioPresupuestalStateService(browser);
        await state.SetAnioAsync(7, 2026, "Anterior");
        browser.Value = "{\"Id\":8,\"Clave\":2027,\"Descripcion\":\"Actual\"}";

        await state.InitializeAsync();

        Assert.Equal(8, state.AnioId);
        Assert.Equal(2027, state.AnioClave);
        Assert.Equal("Actual", state.AnioDescripcion);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task DelayedInitializationCannotOverwriteANewerSelectionOrClear(bool clear)
    {
        var browser = new DelayedStorage { BlockNextRead = true };
        var state = new AnioPresupuestalStateService(browser);
        var initialization = state.InitializeAsync();
        await browser.OperationStarted.Task;

        var latest = clear ? state.ClearAnioAsync() : state.SetAnioAsync(8, 2027, "Actual");
        browser.ContinueOperation.SetResult();
        await Task.WhenAll(initialization, latest);

        Assert.Equal(clear ? null : (int?)8, state.AnioId);
        Assert.Equal(clear ? null : (int?)2027, state.AnioClave);
        if (clear) Assert.Null(browser.Value);
        else Assert.Contains("\"Id\":8", browser.Value);
    }

    [Fact]
    public async Task OverlappingSelectionsPersistAndNotifyOnlyTheLatestYear()
    {
        var browser = new DelayedStorage { BlockNextWrite = true };
        var state = new AnioPresupuestalStateService(browser);
        var notifications = new List<int?>();
        state.OnAnioChanged += notifications.Add;
        var first = state.SetAnioAsync(7, 2026, "Anterior");
        await browser.OperationStarted.Task;
        var latest = state.SetAnioAsync(8, 2027, "Actual");
        browser.ContinueOperation.SetResult();
        await Task.WhenAll(first, latest);

        Assert.Equal(8, state.AnioId);
        Assert.Contains("\"Id\":8", browser.Value);
        Assert.Equal(new int?[] { 8 }, notifications);
    }

    private sealed class DelayedStorage : IJSRuntime
    {
        public string? Value { get; private set; }
        public bool BlockNextRead { get; init; }
        public bool BlockNextWrite { get; init; }
        public TaskCompletionSource OperationStarted { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);
        public TaskCompletionSource ContinueOperation { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);
        private bool blocked;

        public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args) =>
            InvokeAsync<TValue>(identifier, CancellationToken.None, args);

        public async ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            var capturedValue = Value;
            if (!blocked && ((BlockNextRead && identifier == "localStorage.getItem") ||
                (BlockNextWrite && identifier == "localStorage.setItem")))
            {
                blocked = true;
                OperationStarted.SetResult();
                await ContinueOperation.Task;
            }
            if (identifier == "localStorage.getItem") return (TValue)(object)capturedValue!;
            if (identifier == "localStorage.setItem") Value = (string)args![1]!;
            if (identifier == "localStorage.removeItem") Value = null;
            return default!;
        }
    }

    private sealed class Storage : IJSRuntime
    {
        public string? Value { get; set; }
        public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args) =>
            InvokeAsync<TValue>(identifier, CancellationToken.None, args);

        public ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args)
        {
            if (identifier == "localStorage.getItem")
                return ValueTask.FromResult((TValue)(object)Value!);
            if (identifier == "localStorage.setItem")
                Value = (string)args![1]!;
            return ValueTask.FromResult(default(TValue)!);
        }
    }
}

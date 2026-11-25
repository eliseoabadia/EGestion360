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

using EG.Web.Models.Forms;
using EG.Web.Models.PresupuestoModificado;

namespace EG.UnidTest.Presentation;

public sealed class BudgetCaptureUiTests
{
    [Fact]
    public void FailedEditLoadCannotEnableSavingAnEmptyRecord()
    {
        using var state = new EditorRequestState();
        var request = state.Begin();

        state.Fail(request, "El registro no está disponible.");

        Assert.False(state.IsReady);
        Assert.False(state.IsLoading);
        Assert.Equal("El registro no está disponible.", state.Error);
    }

    [Fact]
    public async Task PreviousLookupCannotReplaceTheLatestSelection()
    {
        using var state = new EditorRequestState();
        var first = new TaskCompletionSource<string>();
        var second = new TaskCompletionSource<string>();
        string? selected = null;
        async Task LoadAsync(Task<string> response)
        {
            var version = state.Begin();
            var value = await response;
            if (state.Complete(version))
                selected = value;
        }
        var firstRequest = LoadAsync(first.Task);
        var secondRequest = LoadAsync(second.Task);

        second.SetResult("Partida actual");
        await secondRequest;
        first.SetResult("Partida anterior");
        await firstRequest;

        Assert.Equal("Partida actual", selected);
        Assert.True(state.IsReady);
    }

    [Fact]
    public void ClearingTheSelectionInvalidatesItsPendingAvailability()
    {
        using var state = new EditorRequestState();
        var request = state.Begin();

        state.Invalidate();

        Assert.False(state.Complete(request));
        Assert.False(state.IsReady);
    }

    [Fact]
    public void ClosedDialogCannotApplyALateResult()
    {
        var state = new EditorRequestState();
        var request = state.Begin();
        state.Dispose();

        Assert.False(state.Complete(request));
        Assert.False(state.Fail(request, "Error tardío"));
        Assert.False(state.IsReady);
        Assert.Null(state.Error);
    }

    [Fact]
    public void RetryClearsThePreviousErrorAndOnlyEnablesSavingAfterSuccess()
    {
        using var state = new EditorRequestState();
        state.Fail(state.Begin(), "Consulta fallida");

        var retry = state.Begin();

        Assert.Null(state.Error);
        Assert.False(state.IsReady);
        Assert.True(state.IsLoading);
        Assert.True(state.Complete(retry));
        Assert.True(state.IsReady);
    }

    [Fact]
    public void ClearedDateIsRejectedWithoutReplacingItWithToday()
    {
        DateTime? date = null;

        Assert.NotNull(BudgetCaptureUi.ValidateDate(date));
        Assert.Null(date);
    }

    [Theory]
    [InlineData(2025, false)]
    [InlineData(2026, true)]
    [InlineData(2027, false)]
    public void ExpenditureDateMustBelongToTheSelectedFiscalYear(int year, bool valid) =>
        Assert.Equal(valid, BudgetCaptureUi.ValidateDate(new DateTime(year, 12, 31), 2026) == null);

    [Fact]
    public void LeapDayRoundTripsWithTheDisplayedDateFormat()
    {
        var date = new DateTime(2024, 2, 29);
        var text = date.ToString("dd/MM/yyyy", BudgetCaptureUi.DateCulture);

        Assert.Equal("29/02/2024", text);
        Assert.Equal(date, DateTime.ParseExact(text, "dd/MM/yyyy", BudgetCaptureUi.DateCulture));
        Assert.Null(BudgetCaptureUi.ValidateDate(date, 2024));
    }

    [Theory]
    [InlineData(-0.01, false)]
    [InlineData(-10, false)]
    [InlineData(0, true)]
    [InlineData(0.01, true)]
    [InlineData(100, true)]
    public void MonthlyAmountRejectsNegativesWithoutChangingTheirSign(decimal amount, bool valid) =>
        Assert.Equal(valid, BudgetCaptureUi.ValidateAmount(amount) == null);
}

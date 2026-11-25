using EG.Web.Models;
using EG.Web.Models.PresupuestoModificado;

namespace EG.UnidTest.Presentation;

public class BudgetPageReaderTests
{
    [Fact]
    public async Task ReadsBeyondPreviousFiveHundredRowLimit()
    {
        var rows = Enumerable.Range(1, 701).ToArray();
        var pages = new List<int>();
        var result = await BudgetPageReader.ReadAllAsync<int>((page, size) =>
        {
            pages.Add(page);
            return Task.FromResult(new ApiResponse<int>
            {
                Success = true,
                TotalCount = rows.Length,
                Items = rows.Skip((page - 1) * size).Take(size).ToArray()
            });
        }, id => id, () => true);
        Assert.Equal(rows, result);
        Assert.Equal(new[] { 1, 2, 3 }, pages);
    }

    [Fact]
    public async Task DoesNotPresentFailedRequestAsZeroMovements()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => Read(new() { Success = false }));
    }

    [Fact]
    public async Task EmptySuccessfulQueryIsValid()
    {
        Assert.Empty(await Read(new() { Success = true }));
    }

    [Fact]
    public async Task MissingPageRejectsPartialTotal()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => Read(new()
        {
            Success = true, TotalCount = 5, Items = []
        }));
    }

    [Fact]
    public async Task DuplicateRowsRejectUnstablePagination()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => Read(new()
        {
            Success = true, TotalCount = 3, Items = [1, 1, 2]
        }));
    }

    [Fact]
    public async Task ChangedTotalRejectsMixedSnapshot()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => BudgetPageReader.ReadAllAsync<int>(
            (page, _) => Task.FromResult(new ApiResponse<int>
            {
                Success = true, TotalCount = page == 1 ? 2 : 3, Items = [page]
            }), id => id, () => true));
    }

    [Fact]
    public async Task ContextChangeWhileWaitingDiscardsResponseAndStopsPaging()
    {
        var pending = new TaskCompletionSource<ApiResponse<int>>();
        var current = true;
        var calls = 0;
        var load = BudgetPageReader.ReadAllAsync<int>((_, _) =>
        {
            calls++;
            return pending.Task;
        }, id => id, () => current);
        current = false;
        pending.SetResult(new() { Success = true, TotalCount = 2, Items = [1] });
        await Assert.ThrowsAsync<OperationCanceledException>(() => load);
        Assert.Equal(1, calls);
    }

    private static Task<List<int>> Read(ApiResponse<int> response) =>
        BudgetPageReader.ReadAllAsync<int>((_, _) => Task.FromResult(response), id => id, () => true);
}

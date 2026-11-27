using EG.Web.Models;
using EG.Web.Models.Forms;

namespace EG.UnidTest.Presentation;

public sealed class PagedCollectionReaderTests
{
    [Fact]
    public async Task ServerPageLimitDoesNotTruncateExport()
    {
        var calls = new List<int>();
        var result = await PagedCollectionReader.ReadAsync<int>((page, size) =>
        {
            calls.Add(page);
            Assert.Equal(250, size);
            return Task.FromResult(new ApiResponse<int> { Success = true, TotalCount = 600,
                Items = Enumerable.Range(1, 600).Skip((page - 1) * size).Take(size).ToList() });
        }, 1000, 50000);
        Assert.Equal(600, result.Items.Count);
        Assert.Equal(new[] { 1, 2, 3 }, calls);
        Assert.False(result.Limited);
    }

    [Fact]
    public async Task FailedLaterPageDoesNotReturnPartialData()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => PagedCollectionReader.ReadAsync<int>((page, size) =>
            Task.FromResult(page == 1
                ? new ApiResponse<int> { Success = true, TotalCount = 300, Items = Enumerable.Range(1, 250).ToList() }
                : new ApiResponse<int> { Success = false, Message = "Consulta no disponible" }), 250, 50000));
    }

    [Fact]
    public async Task ExportLimitIsExactAndExplicit()
    {
        var result = await PagedCollectionReader.ReadAsync<int>((page, size) => Task.FromResult(new ApiResponse<int>
        { Success = true, TotalCount = 600, Items = Enumerable.Range(1, 600).Skip((page - 1) * size).Take(size).ToList() }), 250, 275);
        Assert.Equal(275, result.Items.Count);
        Assert.True(result.Limited);
    }

    [Fact]
    public async Task ChangingTotalIsRejected()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => PagedCollectionReader.ReadAsync<int>((page, size) =>
            Task.FromResult(new ApiResponse<int> { Success = true, TotalCount = page == 1 ? 300 : 301,
                Items = Enumerable.Range(1, 300).Skip((page - 1) * size).Take(size).ToList() }), 250, 50000));
    }

    [Fact]
    public async Task ContextChangeDoesNotReturnAnotherCompanysData()
    {
        var current = true;
        await Assert.ThrowsAsync<OperationCanceledException>(() => PagedCollectionReader.ReadAsync<int>((page, size) =>
        {
            current = false;
            return Task.FromResult(new ApiResponse<int> { Success = true, TotalCount = 1, Items = [1] });
        }, 250, 50000, () => current));
    }
}

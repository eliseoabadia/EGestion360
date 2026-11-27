using EG.Web.Models.Forms;

namespace EG.UnidTest.Presentation;

public sealed class DeferredBatchLoaderTests
{
    [Fact]
    public async Task TenRowsShareOneRequest()
    {
        var calls = 0;
        var loader = new DeferredBatchLoader<int, int>(requests => { calls++; return Task.FromResult(requests.Count); });
        var results = await Task.WhenAll(Enumerable.Range(1, 10).Select(loader.LoadAsync));
        Assert.Equal(1, calls);
        Assert.All(results, count => Assert.Equal(10, count));
    }

    [Fact]
    public async Task FailureReleasesEveryCallerAndNextBatchCanRecover()
    {
        var fail = true;
        var loader = new DeferredBatchLoader<int, int>(requests => fail
            ? Task.FromException<int>(new InvalidOperationException("Unavailable")) : Task.FromResult(7));
        await Assert.ThrowsAsync<InvalidOperationException>(() => Task.WhenAll(loader.LoadAsync(1), loader.LoadAsync(2)));
        fail = false;
        Assert.Equal(7, await loader.LoadAsync(3));
    }

    [Fact]
    public async Task BatchesHaveServerBoundedSize()
    {
        var sizes = new List<int>();
        var loader = new DeferredBatchLoader<int, int>(requests => { sizes.Add(requests.Count); return Task.FromResult(1); });
        await Task.WhenAll(Enumerable.Range(1, 215).Select(loader.LoadAsync));
        Assert.Equal(new[] { 100, 100, 15 }, sizes);
    }
}

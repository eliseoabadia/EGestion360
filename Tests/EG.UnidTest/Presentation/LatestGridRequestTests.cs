using EG.Web.Models.Forms;

namespace EG.UnidTest.Presentation;

public sealed class LatestGridRequestTests
{
    [Fact]
    public async Task OldResponseReceivesLatestDataInsteadOfReplacingIt()
    {
        using var requests = new LatestGridRequest<string>();
        var first = requests.Begin();
        var latest = requests.Begin();
        var oldResult = requests.ResolveAsync(first, "old");
        Assert.False(oldResult.IsCompleted);
        Assert.Equal("latest", await requests.ResolveAsync(latest, "latest"));
        Assert.Equal("latest", await oldResult);
        Assert.False(requests.IsCurrent(first));
    }

    [Fact]
    public async Task ThreeOverlappingLoadsReleaseAllWaitersWithLatestData()
    {
        using var requests = new LatestGridRequest<string>();
        var first = requests.Begin();
        var second = requests.Begin();
        var oldest = requests.ResolveAsync(first, "first");
        var latest = requests.Begin();
        var middle = requests.ResolveAsync(second, "second");
        await requests.ResolveAsync(latest, "latest");
        Assert.Equal("latest", await oldest.WaitAsync(TimeSpan.FromSeconds(5)));
        Assert.Equal("latest", await middle.WaitAsync(TimeSpan.FromSeconds(5)));
    }

    [Fact]
    public async Task LatestCompletedBeforeOldResponseStillWins()
    {
        using var requests = new LatestGridRequest<int>();
        var first = requests.Begin();
        var latest = requests.Begin();
        await requests.ResolveAsync(latest, 2);
        Assert.Equal(2, await requests.ResolveAsync(first, 1));
    }

    [Fact]
    public async Task DisposalReleasesPendingCallersAndRejectsNewLoads()
    {
        var requests = new LatestGridRequest<string>();
        var first = requests.Begin();
        requests.Begin();
        var waiting = requests.ResolveAsync(first, "fallback");
        requests.Dispose();
        Assert.Equal("fallback", await waiting.WaitAsync(TimeSpan.FromSeconds(5)));
        Assert.Throws<ObjectDisposedException>(() => requests.Begin());
    }
}

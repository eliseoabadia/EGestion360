namespace EG.Web.Models.Forms;

/// <summary>Groups requests rendered together without caching authorization-sensitive results.</summary>
public sealed class DeferredBatchLoader<TRequest, TResult>(Func<IReadOnlyList<TRequest>, Task<TResult>> loadBatch)
{
    private readonly object gate = new();
    private readonly Queue<(TRequest Request, TaskCompletionSource<TResult> Completion)> pending = new();
    private bool running;

    public Task<TResult> LoadAsync(TRequest request)
    {
        var completion = new TaskCompletionSource<TResult>(TaskCreationOptions.RunContinuationsAsynchronously);
        lock (gate)
        {
            pending.Enqueue((request, completion));
            if (!running) { running = true; _ = DrainAsync(); }
        }
        return completion.Task;
    }

    private async Task DrainAsync()
    {
        await Task.Delay(35);
        while (true)
        {
            List<(TRequest Request, TaskCompletionSource<TResult> Completion)> batch = [];
            lock (gate)
            {
                while (batch.Count < 100 && pending.TryDequeue(out var entry)) batch.Add(entry);
                if (batch.Count == 0) { running = false; return; }
            }
            try
            {
                var result = await loadBatch(batch.Select(entry => entry.Request).ToArray());
                foreach (var entry in batch) entry.Completion.TrySetResult(result);
            }
            catch (Exception exception)
            {
                foreach (var entry in batch) entry.Completion.TrySetException(exception);
            }
        }
    }
}

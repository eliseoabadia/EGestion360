namespace EG.Web.Models.Forms;

public sealed class LatestGridRequest<T> : IDisposable
{
    private Request? latest;
    private bool disposed;

    public sealed class Request
    {
        internal TaskCompletionSource<T> Completion { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);
    }

    public Request Begin()
    {
        ObjectDisposedException.ThrowIf(disposed, this);
        latest = new Request();
        return latest;
    }

    public bool IsCurrent(Request request) => !disposed && ReferenceEquals(latest, request);

    public async Task<T> ResolveAsync(Request request, T value)
    {
        var owner = request;
        try
        {
            while (!disposed && !IsCurrent(request))
            {
                request = latest!;
                value = await request.Completion.Task;
            }
        }
        catch (OperationCanceledException) when (disposed)
        {
            // Release obsolete callers when the table is removed from the page.
        }
        if (!disposed) request.Completion.TrySetResult(value);
        owner.Completion.TrySetResult(value);
        return value;
    }

    public void Dispose()
    {
        disposed = true;
        latest?.Completion.TrySetCanceled();
    }
}

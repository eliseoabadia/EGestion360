namespace EG.Web.Models.Forms;

public sealed class EditorRequestState : IDisposable
{
    private int version;
    private bool disposed;

    public bool IsLoading { get; private set; }
    public bool IsReady { get; private set; }
    public string? Error { get; private set; }

    public int Begin()
    {
        ObjectDisposedException.ThrowIf(disposed, this);
        Invalidate();
        IsLoading = true;
        return version;
    }

    public bool IsCurrent(int requestVersion) => !disposed && version == requestVersion;

    public bool Complete(int requestVersion)
    {
        if (!IsCurrent(requestVersion))
            return false;
        IsLoading = false;
        IsReady = true;
        Error = null;
        return true;
    }

    public bool Fail(int requestVersion, string? message)
    {
        if (!IsCurrent(requestVersion))
            return false;
        IsLoading = false;
        IsReady = false;
        Error = string.IsNullOrWhiteSpace(message) ? "No fue posible cargar la información. Intenta nuevamente." : message;
        return true;
    }

    public void Invalidate()
    {
        version++;
        IsLoading = false;
        IsReady = false;
        Error = null;
    }

    public void Dispose()
    {
        disposed = true;
        Invalidate();
    }
}

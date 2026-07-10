namespace EG.Application.Interfaces.DocumentRag
{
    public interface IRagEmbeddingService
    {
        bool IsEnabled { get; }
        Task<IReadOnlyList<float[]>> EmbedAsync(IReadOnlyList<string> inputs, CancellationToken cancellationToken = default);
    }
}

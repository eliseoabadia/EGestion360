using EG.Application.Interfaces.DocumentRag;
using EG.Application.Services.DocumentRag;
using EG.Domain.DTOs.Requests.DocumentRag;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;

namespace EG.UnidTest.Application;

public sealed class DocumentSessionIsolationTests
{
    [Fact]
    public async Task OtherUserCannotReadSessionOrHistoryAndOwnerCanStillRead()
    {
        var service = new DocumentRagAppService(Options.Create(new DocumentRagSettings()),
            NullLogger<DocumentRagAppService>.Instance, new Embeddings());
        var created = await service.CreateSessionAsync(new DocumentRagSessionRequest { FkidEmpresaSis = 7 }, 42);
        var id = created.Data!.SessionId;

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.GetSessionAsync(id, 43));
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.GetHistoryAsync(id, 43));
        await service.ReleaseSessionAsync(id, 43);

        var ownerSession = await service.GetSessionAsync(id, 42);
        Assert.Equal(id, ownerSession.Data!.SessionId);
    }

    private sealed class Embeddings : IRagEmbeddingService
    {
        public bool IsEnabled => false;
        public Task<IReadOnlyList<float[]>> EmbedAsync(IReadOnlyList<string> inputs, CancellationToken cancellationToken = default) =>
            throw new InvalidOperationException("A rejected request must not reach the external provider.");
    }
}

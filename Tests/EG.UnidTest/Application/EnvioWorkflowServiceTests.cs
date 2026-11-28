using EnvioWorkflowService = EG.Business.Services.General.EnvioWorkflowOperationsService;

namespace EG.UnidTest.Application;

public sealed class EnvioWorkflowServiceTests
{
    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public async Task BeginRequiresAuthenticatedActorBeforePersistence(int usuarioId)
    {
        var service = new EnvioWorkflowService(null!);
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.TryBeginAsync("COTIZACION", 1, usuarioId));
    }

    [Fact]
    public async Task CompleteRejectsEmptyOperationTokenBeforePersistence()
    {
        var service = new EnvioWorkflowService(null!);
        await Assert.ThrowsAsync<ArgumentException>(() => service.CompleteAsync("COTIZACION", 1, Guid.Empty));
    }

    [Fact]
    public async Task CancelRejectsEmptyOperationTokenBeforePersistence()
    {
        var service = new EnvioWorkflowService(null!);
        await Assert.ThrowsAsync<ArgumentException>(() => service.CancelAsync("COTIZACION", 1, Guid.Empty));
    }

    [Fact]
    public async Task RejectRequiresAuthenticatedActorBeforePersistence()
    {
        var service = new EnvioWorkflowService(null!);
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.RejectAsync("COTIZACION", 1, 0, "Motivo"));
    }

    [Fact]
    public async Task RejectDoesNotSilentlyTruncateLongReason()
    {
        var service = new EnvioWorkflowService(null!);
        await Assert.ThrowsAsync<ArgumentException>(() => service.RejectAsync("COTIZACION", 1, 7, new string('x', 501)));
    }
}

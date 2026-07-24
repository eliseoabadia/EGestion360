using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General;

public interface IEnvioWorkflowService
{
    Task<EnvioWorkflowEstadoResponse> GetAsync(string proceso, long entidadId, CancellationToken cancellationToken = default);
    Task<IReadOnlyDictionary<long, EnvioWorkflowEstadoResponse>> GetManyAsync(
        string proceso,
        IEnumerable<long> entidadIds,
        CancellationToken cancellationToken = default);
    Task<EnvioWorkflowClaimResult> TryBeginAsync(
        string proceso,
        long entidadId,
        int usuarioId,
        CancellationToken cancellationToken = default);
    Task CompleteAsync(
        string proceso,
        long entidadId,
        Guid operationToken,
        CancellationToken cancellationToken = default);
    Task CancelAsync(
        string proceso,
        long entidadId,
        Guid operationToken,
        CancellationToken cancellationToken = default);
    Task<EnvioWorkflowEstadoResponse> RejectAsync(
        string proceso,
        long entidadId,
        int usuarioId,
        string? motivo,
        CancellationToken cancellationToken = default);
}

public sealed record EnvioWorkflowClaimResult(
    bool Claimed,
    Guid? OperationToken,
    EnvioWorkflowEstadoResponse State);

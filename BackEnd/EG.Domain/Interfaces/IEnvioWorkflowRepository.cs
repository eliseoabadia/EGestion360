using EG.Domain.DTOs.Responses.General;

namespace EG.Domain.Interfaces;

public sealed record EnvioWorkflowClaim(bool Claimed, Guid? OperationToken, EnvioWorkflowEstadoResponse State);

public interface IEnvioWorkflowRepository
{
    Task<EnvioWorkflowEstadoResponse> GetAsync(string proceso, long entidadId, CancellationToken cancellationToken = default);
    Task<IReadOnlyDictionary<long, EnvioWorkflowEstadoResponse>> GetManyAsync(string proceso, IEnumerable<long> entidadIds, CancellationToken cancellationToken = default);
    Task<EnvioWorkflowClaim> TryBeginAsync(string proceso, long entidadId, int usuarioId, CancellationToken cancellationToken = default);
    Task CompleteAsync(string proceso, long entidadId, Guid operationToken, CancellationToken cancellationToken = default);
    Task CancelAsync(string proceso, long entidadId, Guid operationToken, CancellationToken cancellationToken = default);
    Task<EnvioWorkflowEstadoResponse> RejectAsync(string proceso, long entidadId, int usuarioId, string? motivo, CancellationToken cancellationToken = default);
}

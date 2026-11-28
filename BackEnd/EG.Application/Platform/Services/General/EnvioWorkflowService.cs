using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class EnvioWorkflowService(IEnvioWorkflowOperations service) : IEnvioWorkflowService
{
    public Task<EnvioWorkflowEstadoResponse> GetAsync(string proceso, long entidadId, CancellationToken cancellationToken = default) => service.GetAsync(proceso, entidadId, cancellationToken);
    public Task<IReadOnlyDictionary<long, EnvioWorkflowEstadoResponse>> GetManyAsync( string proceso, IEnumerable<long> entidadIds, CancellationToken cancellationToken = default) => service.GetManyAsync(proceso, entidadIds, cancellationToken);
    public Task<EnvioWorkflowClaimResult> TryBeginAsync( string proceso, long entidadId, int usuarioId, CancellationToken cancellationToken = default) => service.TryBeginAsync(proceso, entidadId, usuarioId, cancellationToken);
    public Task CompleteAsync( string proceso, long entidadId, Guid operationToken, CancellationToken cancellationToken = default) => service.CompleteAsync(proceso, entidadId, operationToken, cancellationToken);
    public Task CancelAsync( string proceso, long entidadId, Guid operationToken, CancellationToken cancellationToken = default) => service.CancelAsync(proceso, entidadId, operationToken, cancellationToken);
    public Task<EnvioWorkflowEstadoResponse> RejectAsync( string proceso, long entidadId, int usuarioId, string? motivo, CancellationToken cancellationToken = default) => service.RejectAsync(proceso, entidadId, usuarioId, motivo, cancellationToken);
}

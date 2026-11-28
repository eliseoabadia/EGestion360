using EG.Business.Interfaces;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;

namespace EG.Business.Services.General;

public sealed class EnvioWorkflowOperationsService(IEnvioWorkflowRepository repository) : IEnvioWorkflowOperations
{
    public Task<EnvioWorkflowEstadoResponse> GetAsync(string proceso, long entidadId, CancellationToken cancellationToken = default)
        => repository.GetAsync(proceso, entidadId, cancellationToken);

    public Task<IReadOnlyDictionary<long, EnvioWorkflowEstadoResponse>> GetManyAsync(
        string proceso, IEnumerable<long> entidadIds, CancellationToken cancellationToken = default)
        => repository.GetManyAsync(proceso, entidadIds, cancellationToken);

    public async Task<EnvioWorkflowClaimResult> TryBeginAsync(
        string proceso, long entidadId, int usuarioId, CancellationToken cancellationToken = default)
    {
        EnsureActor(usuarioId);
        var claim = await repository.TryBeginAsync(proceso, entidadId, usuarioId, cancellationToken);
        return new EnvioWorkflowClaimResult(claim.Claimed, claim.OperationToken, claim.State);
    }

    public Task CompleteAsync(string proceso, long entidadId, Guid operationToken, CancellationToken cancellationToken = default)
    {
        EnsureToken(operationToken);
        return repository.CompleteAsync(proceso, entidadId, operationToken, cancellationToken);
    }

    public Task CancelAsync(string proceso, long entidadId, Guid operationToken, CancellationToken cancellationToken = default)
    {
        EnsureToken(operationToken);
        return repository.CancelAsync(proceso, entidadId, operationToken, cancellationToken);
    }

    public Task<EnvioWorkflowEstadoResponse> RejectAsync(
        string proceso, long entidadId, int usuarioId, string? motivo, CancellationToken cancellationToken = default)
    {
        EnsureActor(usuarioId);
        if (motivo?.Trim().Length > 500)
        {
            throw new ArgumentException("El motivo de rechazo no puede superar 500 caracteres.", nameof(motivo));
        }
        return repository.RejectAsync(proceso, entidadId, usuarioId, motivo, cancellationToken);
    }

    private static void EnsureActor(int usuarioId)
    {
        if (usuarioId <= 0)
        {
            throw new UnauthorizedAccessException("Se requiere un usuario autenticado para cambiar el estado del envío.");
        }
    }

    private static void EnsureToken(Guid token)
    {
        if (token == Guid.Empty)
        {
            throw new ArgumentException("La operación de envío debe conservar su identificador.", nameof(token));
        }
    }
}

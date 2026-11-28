namespace EG.Domain.DTOs.Responses.General;

public sealed record EnvioWorkflowClaimResult(bool Claimed, Guid? OperationToken, EnvioWorkflowEstadoResponse State);

using System.Security.Claims;

namespace EG.Domain.Interfaces;

public interface IUserRequestContext
{
    ClaimsPrincipal? User { get; }
    string? GetHeader(string name);
}

public interface IUserContextQueries
{
    bool CanAccessEmpresa(int usuarioId, int empresaId);
    bool IsActiveAnio(int anioId);
    Task<bool> CanAccessEmpresaAsync(int usuarioId, int empresaId, CancellationToken cancellationToken = default) =>
        Task.FromResult(CanAccessEmpresa(usuarioId, empresaId));
    Task<bool> IsActiveAnioAsync(int anioId, CancellationToken cancellationToken = default) =>
        Task.FromResult(IsActiveAnio(anioId));
}

public interface IUserContextInitializer
{
    Task InitializeAsync(CancellationToken cancellationToken = default);
}

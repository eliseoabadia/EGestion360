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
}

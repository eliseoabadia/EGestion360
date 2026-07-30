using System.Security.Claims;
using EG.Domain.Interfaces;

namespace EG.UnidTest.Support;

internal sealed class FixedUserContext(int? userId, int? empresaId, int? anioId = 1) : IUserContextService
{
    public int GetCurrentUserId()
    {
        return userId ?? throw new InvalidOperationException("No user id configured for this test.");
    }

    public int? TryGetCurrentUserId()
    {
        return userId;
    }

    public int GetCurrentEmpresaId()
    {
        return empresaId ?? throw new InvalidOperationException("No empresa id configured for this test.");
    }

    public int? TryGetCurrentEmpresaId()
    {
        return empresaId;
    }

    public int GetCurrentAnioPresupuestalId()
    {
        return anioId ?? throw new InvalidOperationException("No budget year id configured for this test.");
    }

    public int? TryGetCurrentAnioPresupuestalId()
    {
        return anioId;
    }

    public ClaimsPrincipal? GetUserPrincipal()
    {
        return null;
    }
}

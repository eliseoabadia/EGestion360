using System.Security.Claims;

namespace EG.Domain.Interfaces
{
    public interface IUserContextService
    {
        int GetCurrentUserId();
        int? TryGetCurrentUserId();
        int GetCurrentEmpresaId();
        int? TryGetCurrentEmpresaId();
        int GetCurrentAnioPresupuestalId();
        int? TryGetCurrentAnioPresupuestalId();
        ClaimsPrincipal? GetUserPrincipal();
    }
}

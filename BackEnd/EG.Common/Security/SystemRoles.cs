using System.Security.Claims;

namespace EG.Common.Security;

public static class SystemRoles
{
    public const string SuperAdmin = "SuperAdmin";

    public static bool IsSuperAdmin(ClaimsPrincipal? user) =>
        user?.Identity?.IsAuthenticated == true &&
        (user.IsInRole(SuperAdmin) || user.Claims.Any(claim =>
            (claim.Type == ClaimTypes.Role || claim.Type == "role") &&
            string.Equals(claim.Value, SuperAdmin, StringComparison.OrdinalIgnoreCase)));
}

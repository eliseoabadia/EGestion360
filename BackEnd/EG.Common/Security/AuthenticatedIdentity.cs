using System.Globalization;
using System.Security.Claims;

namespace EG.Common.Security;

public static class AuthenticatedIdentity
{
    private static readonly HashSet<string> UserIdClaims = new(StringComparer.OrdinalIgnoreCase)
    {
        ClaimTypes.NameIdentifier, "sub", "userid", "id"
    };

    public static int? GetUserId(ClaimsPrincipal? user)
    {
        if (user?.Identity?.IsAuthenticated != true)
            return null;

        int? result = null;
        foreach (var claim in user.Claims.Where(claim => UserIdClaims.Contains(claim.Type)))
        {
            if (!TryPositiveId(claim.Value, out var id) || (result.HasValue && result != id))
                return null;
            result = id;
        }
        return result;
    }

    public static bool TryPositiveId(string? value, out int id) =>
        int.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out id) && id > 0;
}

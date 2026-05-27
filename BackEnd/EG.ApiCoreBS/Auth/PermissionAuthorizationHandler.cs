using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace EG.ApiCoreBS.Auth
{
    public sealed class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
    {
        protected override Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            PermissionRequirement requirement)
        {
            if (HasSuperAdminRole(context.User) || HasPermissionTriplet(context.User, requirement))
            {
                context.Succeed(requirement);
            }

            return Task.CompletedTask;
        }

        private static bool HasSuperAdminRole(ClaimsPrincipal user)
        {
            return user.IsInRole("SuperAdmin")
                || user.Claims.Any(c =>
                    string.Equals(c.Type, ClaimTypes.Role, StringComparison.OrdinalIgnoreCase)
                    && string.Equals(c.Value, "SuperAdmin", StringComparison.OrdinalIgnoreCase));
        }

        private static bool HasPermissionTriplet(ClaimsPrincipal user, PermissionRequirement requirement)
        {
            var claims = user.Claims.ToList();

            for (var index = 0; index < claims.Count; index++)
            {
                if (!IsClaim(claims[index], "Group", requirement.Group))
                {
                    continue;
                }

                var subGroup = claims.Skip(index + 1).FirstOrDefault(c => IsClaimType(c, "SubGroup"));
                var values = claims.Skip(index + 1).FirstOrDefault(c => IsClaimType(c, "Values"));

                if (subGroup != null
                    && values != null
                    && string.Equals(subGroup.Value, requirement.SubGroup, StringComparison.OrdinalIgnoreCase)
                    && HasAction(values.Value, requirement.Action))
                {
                    return true;
                }
            }

            return user.Claims.Any(c => IsClaim(c, "Group", requirement.Group))
                && user.Claims.Any(c => IsClaim(c, "SubGroup", requirement.SubGroup))
                && user.Claims.Any(c => IsClaimType(c, "Values") && HasAction(c.Value, requirement.Action));
        }

        private static bool IsClaim(Claim claim, string type, string value)
        {
            return IsClaimType(claim, type)
                && string.Equals(claim.Value, value, StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsClaimType(Claim claim, string type)
        {
            return string.Equals(claim.Type, type, StringComparison.OrdinalIgnoreCase);
        }

        private static bool HasAction(string values, string action)
        {
            return values
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Any(value => string.Equals(value, action, StringComparison.OrdinalIgnoreCase));
        }
    }
}

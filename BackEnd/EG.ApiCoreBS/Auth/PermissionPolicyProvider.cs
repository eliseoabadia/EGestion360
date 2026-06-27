using EG.Common.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;

namespace EG.ApiCoreBS.Auth
{
    public sealed class PermissionPolicyProvider : DefaultAuthorizationPolicyProvider
    {
        private static readonly IReadOnlyList<string> KnownActions = PermissionActionExtensions.GetAllClaimValues();

        public PermissionPolicyProvider(IOptions<AuthorizationOptions> options)
            : base(options)
        {
        }

        public override async Task<AuthorizationPolicy?> GetPolicyAsync(string policyName)
        {
            var existingPolicy = await base.GetPolicyAsync(policyName);
            if (existingPolicy != null)
            {
                return existingPolicy;
            }

            if (!TryParsePolicy(policyName, out var group, out var subGroup, out var action))
            {
                return null;
            }

            return new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .AddRequirements(new PermissionRequirement(group, subGroup, action))
                .Build();
        }

        private static bool TryParsePolicy(string policyName, out string group, out string subGroup, out string action)
        {
            group = string.Empty;
            subGroup = string.Empty;
            action = string.Empty;

            foreach (var knownAction in KnownActions)
            {
                var suffix = "_" + knownAction;
                if (!policyName.EndsWith(suffix, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                var withoutAction = policyName[..^suffix.Length];
                var separator = withoutAction.IndexOf('_');
                if (separator <= 0 || separator >= withoutAction.Length - 1)
                {
                    return false;
                }

                group = withoutAction[..separator];
                subGroup = withoutAction[(separator + 1)..];
                action = knownAction;
                return true;
            }

            return false;
        }
    }
}

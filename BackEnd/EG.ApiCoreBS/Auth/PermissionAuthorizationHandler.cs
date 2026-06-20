using System.Security.Claims;
using EG.Business.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Caching.Memory;

namespace EG.ApiCoreBS.Auth
{
    public sealed class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
    {
        private readonly IAuthService _authService;
        private readonly IMemoryCache _cache;
        private readonly ILogger<PermissionAuthorizationHandler> _logger;

        public PermissionAuthorizationHandler(
            IAuthService authService,
            IMemoryCache cache,
            ILogger<PermissionAuthorizationHandler> logger)
        {
            _authService = authService;
            _cache = cache;
            _logger = logger;
        }

        protected override async Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            PermissionRequirement requirement)
        {
            if (HasSuperAdminRole(context.User))
            {
                context.Succeed(requirement);
                return;
            }

            var userId = GetUserId(context.User);
            if (!userId.HasValue)
                return;

            try
            {
                var permissions = await _cache.GetOrCreateAsync(
                    $"authorization-permissions:{userId.Value}",
                    async entry =>
                    {
                        entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5);
                        return await _authService.ObtenerClaimsUsuarioAsync(userId.Value);
                    }) ?? new List<spGetClaimsByUserResult>();

                if (HasPermission(permissions, requirement))
                    context.Succeed(requirement);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cargando permisos para el usuario {UserId}", userId.Value);
            }
        }

        private static bool HasSuperAdminRole(ClaimsPrincipal user)
        {
            return user.IsInRole("SuperAdmin")
                || user.Claims.Any(c =>
                    string.Equals(c.Type, ClaimTypes.Role, StringComparison.OrdinalIgnoreCase)
                    && string.Equals(c.Value, "SuperAdmin", StringComparison.OrdinalIgnoreCase));
        }

        private static int? GetUserId(ClaimsPrincipal user)
        {
            var value = user.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? user.FindFirstValue("sub")
                ?? user.FindFirstValue("id")
                ?? user.FindFirstValue("Id");

            return int.TryParse(value, out var userId) ? userId : null;
        }

        private static bool HasPermission(
            IEnumerable<spGetClaimsByUserResult> permissions,
            PermissionRequirement requirement)
        {
            return permissions.Any(permission =>
                string.Equals(permission.Group, requirement.Group, StringComparison.OrdinalIgnoreCase)
                && string.Equals(permission.SubGroup, requirement.SubGroup, StringComparison.OrdinalIgnoreCase)
                && HasAction(permission.Values, requirement.Action));
        }

        private static bool HasAction(string values, string action)
        {
            return values
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Any(value => string.Equals(value, action, StringComparison.OrdinalIgnoreCase));
        }
    }
}

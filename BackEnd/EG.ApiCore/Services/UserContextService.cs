using System.Security.Claims;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace EG.ApiCore.Services
{
    public interface IUserContextService
    {
        int GetCurrentUserId();          // lanza si no hay usuario
        int? TryGetCurrentUserId();      // devuelve null si no hay
        ClaimsPrincipal? GetUserPrincipal();
    }
    public class UserContextService : IUserContextService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<UserContextService> _logger;
        private static readonly string[] CandidateClaimTypes = new[]
        {
            ClaimTypes.NameIdentifier,
            "sub",
            "userid",
            "UserId",
            "id",
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
        };

        public UserContextService(IHttpContextAccessor httpContextAccessor, ILogger<UserContextService> logger)
        {
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        public ClaimsPrincipal? GetUserPrincipal()
        {
            return _httpContextAccessor.HttpContext?.User;
        }

        public int? TryGetCurrentUserId()
        {
            var user = GetUserPrincipal();
            if (user == null || !user.Identity?.IsAuthenticated == true)
                return null;

            foreach (var claimType in CandidateClaimTypes)
            {
                var claim = user.Claims.FirstOrDefault(c => string.Equals(c.Type, claimType, StringComparison.OrdinalIgnoreCase));
                if (claim == null) continue;

                // Intento simple
                if (int.TryParse(claim.Value, out var id))
                    return id;

                // Extraer primer número dentro del valor (por ejemplo "1|abc" o "user:1")
                var m = Regex.Match(claim.Value, @"\d+");
                if (m.Success && int.TryParse(m.Value, out id))
                    return id;
            }

            // Intenta con Name (puede contener id en algunos setups)
            var nameClaim = user.Identity?.Name;
            if (!string.IsNullOrEmpty(nameClaim) && int.TryParse(nameClaim, out var nameId))
                return nameId;

            _logger.LogDebug("No se pudo obtener id de usuario desde los claims. Claims disponibles: {Claims}",
                string.Join(", ", user.Claims.Select(c => $"{c.Type}={c.Value}")));

            return null;
        }

        public int GetCurrentUserId()
        {
            var id = TryGetCurrentUserId();
            if (!id.HasValue)
                throw new InvalidOperationException("No se pudo obtener el ID del usuario autenticado.");
            return id.Value;
        }
    }
}
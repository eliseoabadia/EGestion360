using System.Security.Claims;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace EG.ApiCoreBS.Services
{
    public interface IUserContextService
    {
        int GetCurrentUserId();
        int? TryGetCurrentUserId();
        int GetCurrentEmpresaId();
        int? TryGetCurrentEmpresaId();
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

                if (int.TryParse(claim.Value, out var id))
                    return id;

                var m = Regex.Match(claim.Value, @"\d+");
                if (m.Success && int.TryParse(m.Value, out id))
                    return id;
            }

            var nameClaim = user.Identity?.Name;
            if (!string.IsNullOrEmpty(nameClaim) && int.TryParse(nameClaim, out var nameId))
                return nameId;

            _logger.LogDebug("No se pudo obtener id de usuario desde los claims.");
            return null;
        }

        public int GetCurrentUserId()
        {
            var id = TryGetCurrentUserId();
            if (!id.HasValue)
                throw new InvalidOperationException("No se pudo obtener el ID del usuario autenticado.");
            return id.Value;
        }

        public int? TryGetCurrentEmpresaId()
        {
            var user = GetUserPrincipal();
            if (user == null || !user.Identity?.IsAuthenticated == true)
                return null;

            var empresaClaim = user.Claims.FirstOrDefault(c => 
                string.Equals(c.Type, "empresaId", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(c.Type, "EmpresaId", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(c.Type, "empresa", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(c.Type, "Empresa", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(c.Type, "fkidEmpresa", StringComparison.OrdinalIgnoreCase));

            if (empresaClaim != null && int.TryParse(empresaClaim.Value, out var empresaId))
                return empresaId;

            var fkidEmpresaClaim = user.Claims.FirstOrDefault(c => 
                c.Type.StartsWith("fkid", StringComparison.OrdinalIgnoreCase) ||
                c.Type.Contains("Empresa", StringComparison.OrdinalIgnoreCase));

            if (fkidEmpresaClaim != null && int.TryParse(fkidEmpresaClaim.Value, out empresaId))
                return empresaId;

            _logger.LogDebug("No se pudo obtener empresaId desde los claims.");
            return null;
        }

        public int GetCurrentEmpresaId()
        {
            var id = TryGetCurrentEmpresaId();
            if (!id.HasValue)
                throw new InvalidOperationException("No se pudo obtener el ID de la empresa del usuario autenticado.");
            return id.Value;
        }
    }
}
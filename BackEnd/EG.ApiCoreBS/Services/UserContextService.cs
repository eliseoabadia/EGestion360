using System.Security.Claims;
using System.Text.RegularExpressions;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.ApiCoreBS.Services
{
    public class UserContextService : IUserContextService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<UserContextService> _logger;
        private readonly EGestionContext _context;
        private const string EmpresaHeader = "X-Empresa-Id";
        private static readonly string[] CandidateClaimTypes = new[]
        {
            ClaimTypes.NameIdentifier,
            "sub",
            "userid",
            "UserId",
            "id",
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
        };

        public UserContextService(
            IHttpContextAccessor httpContextAccessor,
            ILogger<UserContextService> logger,
            EGestionContext context)
        {
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
            _context = context;
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

            var selectedEmpresaId = TryGetSelectedEmpresaIdFromHeader();
            if (selectedEmpresaId.HasValue && UserCanAccessEmpresa(selectedEmpresaId.Value))
                return selectedEmpresaId.Value;

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

        private int? TryGetSelectedEmpresaIdFromHeader()
        {
            var headers = _httpContextAccessor.HttpContext?.Request?.Headers;
            if (headers == null)
                return null;

            return headers.TryGetValue(EmpresaHeader, out var value) &&
                   int.TryParse(value.FirstOrDefault(), out var empresaId) &&
                   empresaId > 0
                ? empresaId
                : null;
        }

        private bool UserCanAccessEmpresa(int empresaId)
        {
            var usuarioId = TryGetCurrentUserId();
            if (!usuarioId.HasValue || usuarioId.Value <= 0 || empresaId <= 0)
                return false;

            try
            {
                var empresaPrincipal = _context.Usuarios
                    .AsNoTracking()
                    .Any(x =>
                        x.PkIdUsuario == usuarioId.Value &&
                        x.Activo &&
                        x.FkidEmpresaSis == empresaId);

                if (empresaPrincipal)
                    return true;

                return _context.UsuarioSucursals
                    .AsNoTracking()
                    .Include(x => x.FkidSucursalSisNavigation)
                    .Any(x =>
                        x.FkidUsuarioSis == usuarioId.Value &&
                        x.Activo &&
                        x.FkidSucursalSisNavigation.Activo &&
                        x.FkidSucursalSisNavigation.FkidEmpresaSis == empresaId);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo validar acceso del usuario a la empresa {EmpresaId}", empresaId);
                return false;
            }
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

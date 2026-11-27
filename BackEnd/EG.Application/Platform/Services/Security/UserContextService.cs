using System.Security.Claims;
using System.Text.RegularExpressions;
using EG.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Security
{
    public class UserContextService : IUserContextService
    {
        private readonly IUserRequestContext _requestContext;
        private readonly ILogger<UserContextService> _logger;
        private readonly IUserContextQueries _queries;
        private bool empresaResolved;
        private int? currentEmpresaId;
        private bool anioResolved;
        private int? currentAnioId;
        private const string EmpresaHeader = "X-Empresa-Id";
        private const string AnioPresupuestalHeader = "X-Anio-Presupuestal-Id";
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
            IUserRequestContext requestContext,
            ILogger<UserContextService> logger,
            IUserContextQueries queries)
        {
            _requestContext = requestContext;
            _logger = logger;
            _queries = queries;
        }

        public ClaimsPrincipal? GetUserPrincipal()
        {
            return _requestContext.User;
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
            if (!empresaResolved)
            {
                currentEmpresaId = ResolveCurrentEmpresaId();
                empresaResolved = true;
            }
            return currentEmpresaId;
        }

        private int? ResolveCurrentEmpresaId()
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
            var value = _requestContext.GetHeader(EmpresaHeader);
            return int.TryParse(value, out var empresaId) &&
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
                return _queries.CanAccessEmpresa(usuarioId.Value, empresaId);
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

        public int? TryGetCurrentAnioPresupuestalId()
        {
            if (!anioResolved)
            {
                currentAnioId = ResolveCurrentAnioPresupuestalId();
                anioResolved = true;
            }
            return currentAnioId;
        }

        private int? ResolveCurrentAnioPresupuestalId()
        {
            var value = _requestContext.GetHeader(AnioPresupuestalHeader);
            if (!int.TryParse(value, out var anioId) ||
                anioId <= 0)
            {
                return null;
            }

            try
            {
                return _queries.IsActiveAnio(anioId)
                    ? anioId
                    : null;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo validar el ejercicio presupuestal {AnioId}", anioId);
                return null;
            }
        }

        public int GetCurrentAnioPresupuestalId()
        {
            var id = TryGetCurrentAnioPresupuestalId();
            if (!id.HasValue)
                throw new InvalidOperationException("No se pudo obtener el ejercicio presupuestal seleccionado.");
            return id.Value;
        }
    }
}

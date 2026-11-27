using System.Security.Claims;
using EG.Common;
using EG.Common.Security;
using EG.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Security
{
    public class UserContextService : IUserContextService, IUserContextInitializer
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
            return AuthenticatedIdentity.GetUserId(GetUserPrincipal());
        }

        public int GetCurrentUserId()
        {
            var id = TryGetCurrentUserId();
            if (!id.HasValue)
                throw new UnauthorizedAccessException(ApplicationText.Permissions.InvalidIdentity);
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
            var companyId = ResolveRequestedEmpresaId();
            if (companyId.HasValue && !UserCanAccessEmpresa(companyId.Value))
                throw new UnauthorizedAccessException(ApplicationText.Permissions.CompanyDenied);
            return companyId;
        }

        private int? ResolveRequestedEmpresaId()
        {
            var user = GetUserPrincipal();
            if (user == null || !user.Identity?.IsAuthenticated == true)
                return null;

            var selectedCompany = _requestContext.GetHeader(EmpresaHeader);
            if (selectedCompany != null)
            {
                if (!AuthenticatedIdentity.TryPositiveId(selectedCompany, out var selectedId))
                    throw new UnauthorizedAccessException(ApplicationText.Permissions.CompanyDenied);
                return selectedId;
            }

            int? companyId = null;
            foreach (var claim in user.Claims.Where(claim =>
                string.Equals(claim.Type, "empresaId", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(claim.Type, "empresa", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(claim.Type, "fkidEmpresa", StringComparison.OrdinalIgnoreCase)))
            {
                if (!AuthenticatedIdentity.TryPositiveId(claim.Value, out var id) ||
                    (companyId.HasValue && companyId != id))
                    throw new UnauthorizedAccessException(ApplicationText.Permissions.CompanyDenied);
                companyId = id;
            }

            return companyId;
        }

        public async Task InitializeAsync(CancellationToken cancellationToken = default)
        {
            var userId = GetCurrentUserId();
            cancellationToken.ThrowIfCancellationRequested();
            if (!empresaResolved)
            {
                var companyId = ResolveRequestedEmpresaId();
                if (companyId.HasValue)
                {
                    bool allowed;
                    try
                    {
                        allowed = await _queries.CanAccessEmpresaAsync(userId, companyId.Value, cancellationToken);
                    }
                    catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
                    {
                        throw;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "No se pudo validar acceso a la empresa solicitada.");
                        throw new UnauthorizedAccessException(ApplicationText.Permissions.CompanyDenied, ex);
                    }
                    if (!allowed)
                        throw new UnauthorizedAccessException(ApplicationText.Permissions.CompanyDenied);
                }
                currentEmpresaId = companyId;
                empresaResolved = true;
            }

            if (!anioResolved)
            {
                if (AuthenticatedIdentity.TryPositiveId(_requestContext.GetHeader(AnioPresupuestalHeader), out var yearId))
                {
                    try
                    {
                        currentAnioId = await _queries.IsActiveAnioAsync(yearId, cancellationToken) ? yearId : null;
                    }
                    catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
                    {
                        throw;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "No se pudo validar el ejercicio presupuestal solicitado.");
                        currentAnioId = null;
                    }
                }
                anioResolved = true;
            }
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
                throw new UnauthorizedAccessException(ApplicationText.Permissions.CompanyDenied);
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

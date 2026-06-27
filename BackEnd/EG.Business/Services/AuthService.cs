using Mapster;
using EG.Business.Interfaces;
using EG.Common;
using EG.Common.Enums;
using EG.Domain.DTOs.Requests;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Business.Services
{
    public class AuthService : IAuthService
    {
        private readonly IRepository<Usuario> _repository;
        private readonly IRepositorySP<LoginInformationEmployeeResult> _repositorySP;
        private readonly IRepositorySP<spGetClaimsByUserResult> _repositoryClaimsSP;
        private readonly EGestionContext _context;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            IRepository<Usuario> userRepository,
            IRepositorySP<LoginInformationEmployeeResult> repositorySP,
            IRepositorySP<spGetClaimsByUserResult> repositoryClaimsSP,
            EGestionContext context,
            ILogger<AuthService> logger)
        {
            _repository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
            _repositorySP = repositorySP ?? throw new ArgumentNullException(nameof(repositorySP));
            _repositoryClaimsSP = repositoryClaimsSP ?? throw new ArgumentNullException(nameof(repositoryClaimsSP));
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>
        /// Valida las credenciales del usuario y obtiene sus datos
        /// </summary>
        public async Task<LoginInformationEmployeeResult> ValidarCredencialesAsync(LoginRequestDto loginRequest)
        {
            if (loginRequest == null)
                throw new ArgumentNullException(nameof(loginRequest));

            if (string.IsNullOrWhiteSpace(loginRequest.Email) || string.IsNullOrWhiteSpace(loginRequest.Password))
                return null;

            try
            {
                // 🔧 OBTENER INFORMACIÓN DEL USUARIO DESDE BD
                var param = new SqlParameter("@PayrollID", loginRequest.Email);
                var result = await _repositorySP.ExecuteStoredProcedureAsync<LoginInformationEmployeeResult>(
                    "SIS.LoginInformationEmployee",
                    param);

                if (!result.Any())
                    return null;

                var usuarioSP = result.First();

                // 🔧 VALIDAR CONTRASEÑA ENCRIPTADA
                string encryptedPassword = CriptoSecurity.Encrypt(loginRequest.Password);
                
                if (usuarioSP.PasswordHash != encryptedPassword)
                    return null; // Contraseña incorrecta

                var usuario = await _repository.GetByIdAsync(usuarioSP.PkIdUsuario);
                usuarioSP.FkidEmpresaSis = usuario?.FkidEmpresaSis;

                return usuarioSP;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validando credenciales para {Email}", loginRequest.Email);

                throw;
            }
        }

        /// <summary>
        /// Obtiene los claims del usuario desde la base de datos
        /// </summary>
        public async Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId)
        {
            if (usuarioId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0", nameof(usuarioId));

            try
            {
                bool esParaLogin = true;
                // 🔧 PARÁMETROS PARA EL SP
                var parameters = new[]
                {
                    new SqlParameter("@PkIdUser", usuarioId),
                    new SqlParameter("@EsParaLogin", esParaLogin)
                };

                var resultClaims = await _repositorySP.ExecuteStoredProcedureAsync<spGetClaimsByUserResult>(
                    "[SIS].[spGetClaimsByUser]",
                    parameters);

                var claims = resultClaims?.ToList() ?? new List<spGetClaimsByUserResult>();
                if (claims.Count > 0)
                {
                    return claims;
                }

                return await GetClaimsFromRolesAsync(usuarioId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo claims para usuario {UsuarioId}", usuarioId);

                throw;
            }
        }

        private async Task<List<spGetClaimsByUserResult>> GetClaimsFromRolesAsync(int usuarioId)
        {
            var claims = await _context.AspNetClaims
                .AsNoTracking()
                .Include(claim => claim.AspNetClaimValues)
                .Where(claim =>
                    claim.Role != null &&
                    claim.Role.AspNetUserRoles.Any(userRole =>
                        userRole.User != null &&
                        userRole.User.PkIdUsuario == usuarioId &&
                        userRole.User.PkIdUsuarioNavigation != null &&
                        userRole.User.PkIdUsuarioNavigation.Activo))
                .Where(claim => claim.Group != null && claim.SubGroup != null)
                .ToListAsync();

            return claims
                .Select(claim => new spGetClaimsByUserResult
                {
                    Group = claim.Group,
                    SubGroup = claim.SubGroup,
                    Values = BuildClaimValues(claim)
                })
                .DistinctBy(claim => $"{claim.Group}|{claim.SubGroup}|{claim.Values}")
                .OrderBy(claim => claim.Group)
                .ThenBy(claim => claim.SubGroup)
                .ThenBy(claim => claim.Values)
                .ToList();
        }

        private static string BuildClaimValues(AspNetClaim claim)
        {
            var values = claim.AspNetClaimValues
                .Select(value => value.Value)
                .Concat((claim.Values ?? string.Empty).Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Distinct(StringComparer.OrdinalIgnoreCase);

            return string.Join(",", values);
        }
    }
}

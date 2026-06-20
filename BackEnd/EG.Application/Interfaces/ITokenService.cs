using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using System.Security.Claims;

namespace EG.Application.Interfaces
{
    public interface ITokenService
    {
        /// <summary>
        /// Obtiene los claims para el JWT
        /// </summary>
        IEnumerable<Claim> GetClaims(
            string userId,
            string userName,
            string email,
            int? empresaId);

        /// <summary>
        /// Genera el token JWT completo
        /// </summary>
        LoginResponseDto GenTokenkey(
            int pkIdUsuario,
            string userId,
            string userName,
            string email,
            int? empresaId,
            JwtSettings jwtSettings);

        /// <summary>
        /// Valida un token JWT y devuelve el ID del usuario
        /// </summary>
        int? ValidateJwtToken(string token, JwtSettings jwtSettings);

        /// <summary>
        /// Obtiene el principal desde un token expirado
        /// </summary>
        ClaimsPrincipal GetPrincipalFromExpiredToken(string token, JwtSettings jwtSettings);

        /// <summary>
        /// Genera un refresh token
        /// </summary>
        string GenerateRefreshToken();
    }
}

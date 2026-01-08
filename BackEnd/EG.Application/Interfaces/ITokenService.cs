using EG.Application.CommonModel;
using EG.Domain.DTOs.Responses.Auth;
using EG.Domain.Entities;
using System.Security.Claims;

namespace EG.Application.Interfaces
{
    public interface ITokenService
    {
        IEnumerable<Claim> GetClaims( string userId, string userName, string email, DateTime? expiration, IList<spGetClaimsByUserResult> _claims);

        LoginResponseDto GenTokenkey(int _PkIdUsuario,string userId, string userName, string email, IList<spGetClaimsByUserResult> _claims, JwtSettings jwtSettings);

        int? ValidateJwtToken(string token, JwtSettings jwtSettings);

        ClaimsPrincipal GetPrincipalFromExpiredToken(string token, JwtSettings jwtSettings);

        string GenerateRefreshToken();
    }
}
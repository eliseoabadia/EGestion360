using EG.Application.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Infraestructure.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;

namespace EG.Application.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _config;

        public TokenService(IConfiguration config)
        {
            _config = config;
        }

        public IEnumerable<Claim> GetClaims(
            string userId,
            string userName,
            string email,
            DateTime? expiration,
            IList<spGetClaimsByUserResult> _claims)
        {
            var claims = new List<Claim>
            {
                new Claim("Id", userId),
                new Claim("id", userId), // lowercase para compatibilidad
                new Claim(ClaimTypes.NameIdentifier, userId),
                new Claim(ClaimTypes.Name, userName ?? string.Empty),
                new Claim(ClaimTypes.Email, email ?? string.Empty),
                new Claim(ClaimTypes.Expiration, expiration?.ToString("yyyy-MM-ddTHH:mm:ssZ") ?? string.Empty)
            };

            // Agregar claims personalizados desde spGetClaimsByUserResult
            if (_claims != null && _claims.Any())
            {
                foreach (var item in _claims)
                {
                    if (!string.IsNullOrWhiteSpace(item.Group))
                        claims.Add(new Claim("Group", item.Group));

                    if (!string.IsNullOrWhiteSpace(item.SubGroup))
                        claims.Add(new Claim("SubGroup", item.SubGroup));

                    if (!string.IsNullOrWhiteSpace(item.Values))
                        claims.Add(new Claim("Values", item.Values));
                }
            }

            return claims;
        }

        public LoginResponseDto GenTokenkey(
            int pkIdUsuario,
            string userId,
            string userName,
            string email,
            IList<spGetClaimsByUserResult> _claims,
            JwtSettings jwtSettings)
        {
            try
            {
                var resultUser = new LoginResponseDto();

                var key = System.Text.Encoding.ASCII.GetBytes(jwtSettings.IssuerSigningKey);
                DateTime expireTime = DateTime.Now.AddMinutes(jwtSettings.ExpiryMinutes);

                resultUser.CreateAt = DateTime.Now;
                resultUser.UpdateAt = new DateTimeOffset(expireTime).DateTime;

                var JWToken = new JwtSecurityToken(
                    issuer: jwtSettings.ValidIssuer,
                    audience: jwtSettings.ValidAudience,
                    claims: GetClaims(userId, userName, email, new DateTimeOffset(expireTime).DateTime, _claims),
                    notBefore: DateTime.Now,
                    expires: new DateTimeOffset(expireTime).DateTime,
                    signingCredentials: new SigningCredentials(
                        new SymmetricSecurityKey(key),
                        SecurityAlgorithms.HmacSha256)
                );

                resultUser.RefreshTokenExpiryTime = new DateTimeOffset(expireTime).DateTime;
                resultUser.AccessToken = new JwtSecurityTokenHandler().WriteToken(JWToken);
                resultUser.RefreshToken = GenerateRefreshToken();

                resultUser.NombreUsuario = userName;
                resultUser.Id = Guid.NewGuid();
                resultUser.PayrollId = userId;
                resultUser.PkIdUsuario = pkIdUsuario;
                resultUser.IsAuthenticated = true;

                return resultUser;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Error generando token JWT", ex);
            }
        }

        public int? ValidateJwtToken(string token, JwtSettings jwtSettings)
        {
            if (string.IsNullOrWhiteSpace(token))
                return null;

            var key = System.Text.Encoding.ASCII.GetBytes(jwtSettings.IssuerSigningKey);
            var tokenHandler = new JwtSecurityTokenHandler();

            try
            {
                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = jwtSettings.ValidIssuer,
                    ValidateAudience = true,
                    ValidAudience = jwtSettings.ValidAudience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                var jwtToken = (JwtSecurityToken)validatedToken;
                
                // Buscar el claim de ID (puede ser "Id", "id" o "sub")
                var idClaim = jwtToken.Claims.FirstOrDefault(x =>
                    x.Type == ClaimTypes.NameIdentifier ||
                    x.Type == "Id" ||
                    x.Type == "id") ??
                    throw new SecurityTokenException("No ID claim found in token");

                if (int.TryParse(idClaim.Value, out int userId))
                    return userId;

                return null;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public ClaimsPrincipal GetPrincipalFromExpiredToken(string token, JwtSettings jwtSettings)
        {
            if (string.IsNullOrWhiteSpace(token))
                throw new ArgumentNullException(nameof(token));

            var key = System.Text.Encoding.ASCII.GetBytes(jwtSettings.IssuerSigningKey);

            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidIssuer = jwtSettings.ValidIssuer,
                ValidateAudience = true,
                ValidAudience = jwtSettings.ValidAudience,
                ValidateLifetime = false, // No validar expiración
                ClockSkew = TimeSpan.Zero
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

            var jwtSecurityToken = securityToken as JwtSecurityToken;
            if (jwtSecurityToken == null ||
                !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
            {
                throw new SecurityTokenException("Invalid token");
            }

            return principal;
        }

        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}
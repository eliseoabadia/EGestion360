using EG.Application.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
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
            int? empresaId)
        {
            // El JWT viaja en la cabecera Authorization de cada solicitud. Los
            // permisos se consultan por separado para evitar exceder el limite
            // de cabeceras cuando un usuario tiene muchos accesos asignados.
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, userId),
                new Claim(JwtRegisteredClaimNames.UniqueName, userName ?? string.Empty),
                new Claim(JwtRegisteredClaimNames.Email, email ?? string.Empty)
            };

            if (empresaId.HasValue)
                claims.Add(new Claim("empresaId", empresaId.Value.ToString()));

            return claims;
        }

    public LoginResponseDto GenTokenkey(
        int pkIdUsuario,
        string userId,
        string userName,
        string email,
        int? empresaId,
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
                    claims: GetClaims(userId, userName, email, empresaId),
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
                    x.Type == JwtRegisteredClaimNames.Sub ||
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

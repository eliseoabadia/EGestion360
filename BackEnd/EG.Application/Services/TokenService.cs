using EG.Application.CommonModel;
using EG.Application.Interfaces;
using EG.Domain.DTOs.Responses.Auth;
using EG.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace EG.Application.Services
{
    public class TokenService(IConfiguration config) : ITokenService
    {


        public IEnumerable<Claim> GetClaims(string userId, string userName, string email,DateTime? expiration, IList<spGetClaimsByUserResult> _claims)
        {
            var claims = new List<Claim>
            {
                new Claim("Id", userId),
                new Claim(ClaimTypes.Name, userName ?? string.Empty),
                new Claim(ClaimTypes.Email, email ?? string.Empty),
                new Claim(ClaimTypes.NameIdentifier, userId),
                new Claim(ClaimTypes.Expiration, expiration.Value.ToString("yyyy-MM-ddTHH:mm:ssZ")) // ISO 8601
            };

            // Agregar claims personalizados desde el modelo spGetClaimsByUserDboResult
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
       
        public LoginResponseDto GenTokenkey(int _PkIdUsuario, string userId, string userName, string email, IList<spGetClaimsByUserResult> _claims, JwtSettings jwtSettings)
        {
            try
            {
                var resultUser = new LoginResponseDto();

                
                // Get secret key
                var key = System.Text.Encoding.ASCII.GetBytes(jwtSettings.IssuerSigningKey);
                Guid Id = Guid.Empty;
                DateTime expireTime = DateTime.Now.AddMinutes(jwtSettings.ExpiryMinutes);// DateTime.UtcNow.AddMinutes(1);
                resultUser.CreateAt = DateTime.Now;
                resultUser.UpdateAt = new DateTimeOffset(expireTime).DateTime;
                var JWToken = new JwtSecurityToken(
                    issuer: jwtSettings.ValidIssuer,
                    audience: jwtSettings.ValidAudience,
                    claims: GetClaims(userId, userName, email, new DateTimeOffset(expireTime).DateTime, _claims),
                    notBefore: DateTime.Now,
                    expires: new DateTimeOffset(expireTime).DateTime,
                    signingCredentials: new SigningCredentials
                    (new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256)
                );
                resultUser.RefreshTokenExpiryTime = new DateTimeOffset(expireTime).DateTime;
                resultUser.AccessToken = new JwtSecurityTokenHandler().WriteToken(JWToken);
                var idRefreshToken = Guid.NewGuid();

                resultUser.RefreshToken = GenerateRefreshToken();

                resultUser.NombreUsuario = userName;
                resultUser.Id = Guid.NewGuid();
                resultUser.PayrollId = userId;
                resultUser.PkIdUsuario = _PkIdUsuario;
                
                return resultUser;
            }
            catch (Exception)
            {
                throw;
            }
        }

        public int? ValidateJwtToken(string token, JwtSettings jwtSettings)
        {
            if (token == null)
                return null;

            var key = System.Text.Encoding.ASCII.GetBytes(jwtSettings.IssuerSigningKey);
            var tokenHandler = new JwtSecurityTokenHandler();
            try
            {
                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = false,
                    ValidateAudience = false,
                    // set clockskew to zero so tokens expire exactly at token expiration time (instead of 5 minutes later)
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                var jwtToken = (JwtSecurityToken)validatedToken;
                var userId = int.Parse(jwtToken.Claims.First(x => x.Type == "id").Value);

                // return user id from JWT token if validation successful
                return userId;
            }
            catch
            {
                // return null if validation fails
                return null;
            }
        }

        

        public ClaimsPrincipal GetPrincipalFromExpiredToken(string token, JwtSettings jwtSettings)
        {
            var key = System.Text.Encoding.ASCII.GetBytes(jwtSettings.IssuerSigningKey);

            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = false,
                ValidateAudience = false,
                ValidateLifetime = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ClockSkew = TimeSpan.Zero
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);
            JwtSecurityToken jwtSecurityToken = securityToken as JwtSecurityToken;
            if (jwtSecurityToken == null || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
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
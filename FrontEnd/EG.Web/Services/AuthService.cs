using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;
using System.Security.Claims;
using System.Text.RegularExpressions;

namespace EG.Web.Services
{
    public class AuthService(AuthenticationStateProvider authenticationStateProvider, IJSRuntime js)
    {
        private readonly AuthenticationStateProvider _authenticationStateProvider = authenticationStateProvider;
        private readonly IJSRuntime _js = js;

        public async Task<bool> IsAuthenticatedAsync()
        {
            var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = authState.User;
            return user.Identity!.IsAuthenticated;
        }

        public async Task<string?> GetUserNameAsync()
        {
            var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = authState.User;
            return user.FindFirst("unique_name")?.Value;
        }

        public async Task<string?> GetNameAsync()
        {
            var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = authState.User;
            return user.FindFirst("Nombre")?.Value;
        }

        public async Task<string?> GetUserRoleAsync()
        {
            var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = authState.User;
            return user.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role || c.Type == "role")?.Value;
        }

        public async Task<int> GetUserIdAsync()
        {
            var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = authState.User;

            // Buscar múltiples claves comunes en JWT para el id de usuario
            var possibleKeys = new[] { "UserId", "userId", ClaimTypes.NameIdentifier, "sub", "nameid", "id", "pkIdUsuario", "PkIdUsuario" };

            var claim = user.Claims.FirstOrDefault(c => possibleKeys.Any(k => string.Equals(c.Type, k, StringComparison.OrdinalIgnoreCase)));
            if (claim != null)
            {
                // Intentos de parseo directo
                if (int.TryParse(claim.Value, out int userIdInt))
                {
                    return userIdInt;
                }

                if (long.TryParse(claim.Value, out long userIdLong) && userIdLong <= int.MaxValue)
                {
                    return (int)userIdLong;
                }

                // Extraer primer bloque de dígitos si la claim contiene números mezclados
                var m = Regex.Match(claim.Value ?? string.Empty, @"\d+");
                if (m.Success && int.TryParse(m.Value, out int numeric))
                {
                    return numeric;
                }
            }

            // Fallback: intentar leer userId desde localStorage (si está guardado por tu login flow)
            try
            {
                var stored = await _js.InvokeAsync<string>("localStorage.getItem", "userId");
                if (!string.IsNullOrEmpty(stored) && int.TryParse(stored, out int storedId))
                {
                    return storedId;
                }
            }
            catch
            {
                // No hacemos nada: devuelve 0 al final
            }

            return 0;
        }
    }
}
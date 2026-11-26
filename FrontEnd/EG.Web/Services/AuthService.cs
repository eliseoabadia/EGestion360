using Microsoft.AspNetCore.Components.Authorization;
using System.Globalization;
using System.Security.Claims;

namespace EG.Web.Services
{
    public class AuthService(AuthenticationStateProvider authenticationStateProvider)
    {
        private readonly AuthenticationStateProvider _authenticationStateProvider = authenticationStateProvider;

        public async Task<bool> IsAuthenticatedAsync()
        {
            var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = authState.User;
            return user.Identity?.IsAuthenticated == true;
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
            var state = await _authenticationStateProvider.GetAuthenticationStateAsync();
            var user = state.User;
            if (user.Identity?.IsAuthenticated != true) return 0;

            string[] keys = [ClaimTypes.NameIdentifier, "sub", "nameid", "UserId", "id", "pkIdUsuario"];
            foreach (var key in keys)
            {
                var claim = user.Claims.FirstOrDefault(item => string.Equals(item.Type, key, StringComparison.OrdinalIgnoreCase));
                if (claim == null) continue;
                return int.TryParse(claim.Value, NumberStyles.None, CultureInfo.InvariantCulture, out var id) && id > 0
                    ? id
                    : 0;
            }
            return 0;
        }

        public bool HasPermission(string module, string submodule, string permission)
        {
            try
            {
                // No bloquear el hilo de Blazor esperando una tarea asíncrona:
                // en WebAssembly eso puede congelar la interfaz. Los consumidores
                // nuevos deben usar HasPermissionAsync; este método solo aprovecha
                // un estado que ya esté disponible de forma síncrona.
                var authStateTask = _authenticationStateProvider.GetAuthenticationStateAsync();
                if (!authStateTask.IsCompletedSuccessfully)
                    return false;

                var authState = authStateTask.GetAwaiter().GetResult();
                var user = authState.User;

                if (!user.Identity?.IsAuthenticated ?? true)
                    return false;

                // Verificar si es SuperAdmin (tiene todos los permisos)
                if (user.IsInRole("SuperAdmin") || user.HasClaim(c => c.Type == "role" && c.Value == "SuperAdmin"))
                    return true;

                // Formato del claim: "permiso:configuracion.empresas.view"
                var permissionClaim = $"permiso:{module}.{submodule}.{permission}";
                var anyPermissionClaim = $"permiso:{module}.{submodule}.*";
                var modulePermissionClaim = $"permiso:{module}.*.*";

                return user.HasClaim(c => c.Type == "permission" &&
                    (c.Value == permissionClaim ||
                     c.Value == anyPermissionClaim ||
                     c.Value == modulePermissionClaim));
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> HasPermissionAsync(string module, string submodule, string permission)
        {
            try
            {
                var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
                var user = authState.User;

                if (!user.Identity?.IsAuthenticated ?? true)
                    return false;

                if (user.IsInRole("SuperAdmin") || user.HasClaim(c => c.Type == "role" && c.Value == "SuperAdmin"))
                    return true;

                var permissionClaim = $"permiso:{module}.{submodule}.{permission}";
                var anyPermissionClaim = $"permiso:{module}.{submodule}.*";
                var modulePermissionClaim = $"permiso:{module}.*.*";

                return user.HasClaim(c => c.Type == "permission" &&
                    (c.Value == permissionClaim ||
                     c.Value == anyPermissionClaim ||
                     c.Value == modulePermissionClaim));
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<List<string>> GetUserPermissionsAsync()
        {
            var permissions = new List<string>();
            try
            {
                var authState = await _authenticationStateProvider.GetAuthenticationStateAsync();
                var user = authState.User;

                var permissionClaims = user.FindAll(c => c.Type == "permission");
                permissions.AddRange(permissionClaims.Select(c => c.Value));
            }
            catch (Exception)
            {
                // Log error
            }
            return permissions;
        }
    }
}

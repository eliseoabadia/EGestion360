using EG.Web.Helpers;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text.Json;

namespace EG.Web.Auth
{
    public class AuthenticationProviderJWT(IJSRuntime js, HttpClient httpClient) : AuthenticationStateProvider
    {
        private readonly IJSRuntime js = js;
        private readonly HttpClient httpClient = httpClient;
        public static readonly string TOKENKEY = "authToken";
        private static AuthenticationState Anonimo => new(new ClaimsPrincipal(new ClaimsIdentity()));

        // Estructura interna de permisos: Group -> SubGroup -> set(Values)
        private readonly Dictionary<string, Dictionary<string, HashSet<string>>> _permissions = new();

        public override async Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            var token = await js.GetFromLocalStorage(TOKENKEY);

            if (string.IsNullOrEmpty(token))
            {
                return Anonimo;
            }

            return BuildAuthenticationState(token);
        }

        private AuthenticationState BuildAuthenticationState(string token)
        {
            // Normalizar token y asignar header
            var tokenValue = NormalizeToken(token);
            httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", tokenValue);

            // Extraer claims y permisos
            var claims = ParseClaimsFromJwt(tokenValue);
            BuildPermissionStore(claims);

            // Asegurar NameIdentifier si existe id/Id
            var identity = new ClaimsIdentity(claims, "jwt");
            EnsureNameIdentifier(identity);

            return new AuthenticationState(new ClaimsPrincipal(identity));
        }

        private static string NormalizeToken(string rawToken)
        {
            if (string.IsNullOrWhiteSpace(rawToken)) return string.Empty;
            var t = rawToken.Trim();
            if ((t.StartsWith("\"") && t.EndsWith("\"")) || (t.StartsWith("'") && t.EndsWith("'")))
                t = t.Substring(1, t.Length - 2);
            return t.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase) ? t.Substring("Bearer ".Length) : t;
        }

        private static List<Claim> ParseClaimsFromJwt(string jwt)
        {
            try
            {
                var claims = new List<Claim>();
                var payload = jwt.Split('.')[1];
                var jsonBytes = ParseBase64WithoutPadding(payload);
                var keyValuePairs = JsonSerializer.Deserialize<Dictionary<string, object>>(jsonBytes);

                if (keyValuePairs == null)
                    return claims;

                foreach (var kvp in keyValuePairs)
                {
                    // Manejar arrays o valores escalares
                    if (kvp.Value is JsonElement je)
                    {
                        switch (je.ValueKind)
                        {
                            case JsonValueKind.Array:
                                foreach (var el in je.EnumerateArray())
                                {
                                    claims.Add(new Claim(kvp.Key, el.ToString() ?? string.Empty));
                                }
                                break;
                            default:
                                claims.Add(new Claim(kvp.Key, je.ToString() ?? string.Empty));
                                break;
                        }
                    }
                    else
                    {
                        claims.Add(new Claim(kvp.Key, kvp.Value?.ToString() ?? string.Empty));
                    }
                }

                // Mapear role si viene como 'role' o 'roles'
                if (keyValuePairs.TryGetValue("role", out var roleValue) && roleValue != null)
                {
                    claims.Add(new Claim(ClaimTypes.Role, roleValue.ToString()!));
                }
                if (keyValuePairs.TryGetValue("roles", out var rolesValue) && rolesValue != null)
                {
                    // Si roles es array o CSV, agregar cada rol
                    if (rolesValue is JsonElement rje && rje.ValueKind == JsonValueKind.Array)
                    {
                        foreach (var r in rje.EnumerateArray())
                            claims.Add(new Claim(ClaimTypes.Role, r.ToString()!));
                    }
                    else
                    {
                        var s = rolesValue.ToString() ?? string.Empty;
                        foreach (var part in s.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                            claims.Add(new Claim(ClaimTypes.Role, part));
                    }
                }

                return claims;
            }
            catch
            {
                return new List<Claim>();
            }
        }

        private static byte[] ParseBase64WithoutPadding(string base64)
        {
            switch (base64.Length % 4)
            {
                case 2: base64 += "=="; break;
                case 3: base64 += "="; break;
            }
            return Convert.FromBase64String(base64);
        }

        private void BuildPermissionStore(IEnumerable<Claim> claims)
        {
            _permissions.Clear();

            // Recoger todas las claims Group/SubGroup/Values que vienen del servidor
            // Pueden venir repetidas; consolidamos por índice si aparecen como arrays en el token
            var groupClaims = claims.Where(c => string.Equals(c.Type, "Group", StringComparison.OrdinalIgnoreCase)).ToList();
            var subGroupClaims = claims.Where(c => string.Equals(c.Type, "SubGroup", StringComparison.OrdinalIgnoreCase)).ToList();
            var valuesClaims = claims.Where(c => string.Equals(c.Type, "Values", StringComparison.OrdinalIgnoreCase)).ToList();

            // Si no hay group/subgroup/values agrupadas, también soportamos claims individuales con structure 'app://group/subgroup' o claves personalizadas
            if (groupClaims.Any())
            {
                int count = Math.Max(groupClaims.Count, Math.Max(subGroupClaims.Count, valuesClaims.Count));

                for (int i = 0; i < count; i++)
                {
                    var group = i < groupClaims.Count ? groupClaims[i].Value : groupClaims.First().Value;
                    var subgroup = i < subGroupClaims.Count ? subGroupClaims[i].Value : subGroupClaims.FirstOrDefault()?.Value ?? string.Empty;
                    var valuesRaw = i < valuesClaims.Count ? valuesClaims[i].Value : valuesClaims.FirstOrDefault()?.Value ?? string.Empty;

                    AddPermissionEntry(group, subgroup, valuesRaw);
                }
            }
            else
            {
                // Fallback: buscar claims cuyo tipo contenga "app://" o formatos personalizados y parsearlos
                var appClaims = claims.Where(c => c.Value?.Contains("app://", StringComparison.OrdinalIgnoreCase) == true).ToList();
                foreach (var c in appClaims)
                {
                    // ejemplo tokenFormat 'app://{0}/{1}' no contiene valores, así que no es útil; ignoramos
                }

                // También soportar claims con nombre 'administration' y valores 'view,view-menu' (rare)
                var possibleGroups = claims.Where(c => c.Value?.Contains(",") == true).ToList();
                foreach (var c in possibleGroups)
                {
                    // intentar deducir group y values separando por ':' o similar
                    // si no, lo descartamos
                }
            }
        }

        private void AddPermissionEntry(string group, string subgroup, string valuesRaw)
        {
            if (string.IsNullOrWhiteSpace(group)) return;
            group = group.Trim();
            subgroup = (subgroup ?? string.Empty).Trim();

            var actions = (valuesRaw ?? string.Empty)
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(v => v.Trim())
                .Where(v => !string.IsNullOrWhiteSpace(v))
                .ToList();

            if (!_permissions.TryGetValue(group, out var subdict))
            {
                subdict = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
                _permissions[group] = subdict;
            }

            var key = string.IsNullOrWhiteSpace(subgroup) ? string.Empty : subgroup;
            if (!subdict.TryGetValue(key, out var set))
            {
                set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                subdict[key] = set;
            }

            foreach (var a in actions)
                set.Add(a);
        }

        private void EnsureNameIdentifier(ClaimsIdentity identity)
        {
            // Añadir ClaimTypes.NameIdentifier si está presente 'id' o 'Id' como claim distinto
            var idClaim = identity.Claims.FirstOrDefault(c => string.Equals(c.Type, "id", StringComparison.OrdinalIgnoreCase)
                                                           || string.Equals(c.Type, "Id", StringComparison.OrdinalIgnoreCase)
                                                           || string.Equals(c.Type, ClaimTypes.NameIdentifier, StringComparison.OrdinalIgnoreCase));
            if (idClaim != null && !identity.HasClaim(c => c.Type == ClaimTypes.NameIdentifier))
            {
                identity.AddClaim(new Claim(ClaimTypes.NameIdentifier, idClaim.Value));
            }
        }

        // Helpers públicos para consumir permisos desde componentes
        public IReadOnlyDictionary<string, IReadOnlyDictionary<string, IReadOnlyCollection<string>>> GetPermissions()
        {
            return _permissions.ToDictionary(
                g => g.Key,
                g => (IReadOnlyDictionary<string, IReadOnlyCollection<string>>)g.Value.ToDictionary(s => s.Key, s => (IReadOnlyCollection<string>)s.Value.ToList()),
                StringComparer.OrdinalIgnoreCase);
        }

        public bool HasPermission(string group, string subGroup, string action)
        {
            if (string.IsNullOrWhiteSpace(group) || string.IsNullOrWhiteSpace(action))
                return false;

            if (!_permissions.TryGetValue(group.Trim(), out var subdict))
                return false;

            var key = subGroup?.Trim() ?? string.Empty;

            // verificar subgrupo exacto y también clave vacía (permisos generales del grupo)
            if (subdict.TryGetValue(key, out var set) && set.Contains(action.Trim()))
                return true;

            if (subdict.TryGetValue(string.Empty, out var general) && general.Contains(action.Trim()))
                return true;

            return false;
        }

        public int? GetUserId()
        {
            // intenta leer ClaimTypes.NameIdentifier
            var identity = (BuildAuthenticationStateFromCurrent()?.Result.User.Identity) as ClaimsIdentity;
            var claim = identity?.FindFirst(ClaimTypes.NameIdentifier) ?? identity?.FindFirst("id") ?? identity?.FindFirst("Id");
            if (claim == null) return null;
            return int.TryParse(claim.Value, out var id) ? id : null;
        }

        private Task<AuthenticationState> BuildAuthenticationStateFromCurrent()
        {
            // Construye estado a partir del token en localStorage (sin notificar)
            return GetAuthenticationStateAsync();
        }

        public async Task LoginAsync(string token)
        {
            var normalized = NormalizeToken(token);
            await js.SetInLocalStorage(TOKENKEY, normalized);
            var authState = BuildAuthenticationState(normalized);
            NotifyAuthenticationStateChanged(Task.FromResult(authState));
        }

        public async Task Logout()
        {
            httpClient.DefaultRequestHeaders.Authorization = null;
            await js.RemoveItem(TOKENKEY);
            _permissions.Clear();
            NotifyAuthenticationStateChanged(Task.FromResult(Anonimo));
        }
    }
}
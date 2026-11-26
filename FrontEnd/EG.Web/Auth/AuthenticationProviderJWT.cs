using EG.Common.GenericModel;
using EG.Web.Helpers;
using EG.Web.Services;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text;
using System.Text.Json;

namespace EG.Web.Auth
{
    public class AuthenticationProviderJWT : AuthenticationStateProvider
    {
        private readonly IJSRuntime _js;
        private readonly HttpClient _httpClient;
        private readonly ILogger<AuthenticationProviderJWT> _logger;
        private static readonly string TOKEN_KEY = "authToken";
        private static readonly string DB_CLAIMS_KEY = "dbPermissionClaims";
        private static readonly string USER_ID_KEY = "userId";
        private static readonly string USER_NAME_KEY = "userName";
        private static readonly AuthenticationState ANONYMOUS = new(new ClaimsPrincipal(new ClaimsIdentity()));

        // Almacén de permisos: Group -> SubGroup -> HashSet<Action>
        private readonly Dictionary<string, Dictionary<string, HashSet<string>>> _permissions = new(StringComparer.OrdinalIgnoreCase);
        private bool _dbPermissionsRefreshAttempted;
        private string? _activeToken;
        private AuthenticationState? _activeAuthenticationState;
        private bool sessionCleared;
        private int sessionVersion;
        private readonly SemaphoreSlim sessionStorageGate = new(1, 1);
        private readonly SucursalStateService _branchState;
        private readonly AnioPresupuestalStateService _yearState;
        private readonly TimeProvider _clock;

        public AuthenticationProviderJWT(
            IJSRuntime js,
            HttpClient httpClient,
            ILogger<AuthenticationProviderJWT> logger,
            SucursalStateService branchState,
            AnioPresupuestalStateService yearState,
            TimeProvider? clock = null)
        {
            _js = js;
            _httpClient = httpClient;
            _logger = logger;
            _branchState = branchState;
            _yearState = yearState;
            _clock = clock ?? TimeProvider.System;
        }

        public override async Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            if (sessionCleared) return ANONYMOUS;
            var version = sessionVersion;
            var token = await _js.GetFromLocalStorage(TOKEN_KEY);
            if (version != sessionVersion || sessionCleared) return _activeAuthenticationState ?? ANONYMOUS;
            if (string.IsNullOrWhiteSpace(token))
            {
                await ClearStoredSessionAsync();
                return ANONYMOUS;
            }

            var normalizedToken = NormalizeToken(token);
            if (string.IsNullOrWhiteSpace(normalizedToken))
            {
                await ClearStoredSessionAsync();
                return ANONYMOUS;
            }

            if (_activeAuthenticationState != null &&
                string.Equals(_activeToken, normalizedToken, StringComparison.Ordinal))
            {
                if (IsTokenExpired(_activeAuthenticationState.User.Claims))
                {
                    await LogoutAsync();
                    return ANONYMOUS;
                }
                return _activeAuthenticationState;
            }

            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", normalizedToken);

            var authState = BuildAuthenticationState(normalizedToken);
            if (authState == null)
            {
                await ClearStoredSessionAsync();
                return ANONYMOUS;
            }

            var jwtClaims = authState.User.Claims.ToList();
            await LoadPersistedDbPermissions(version);
            if (version != sessionVersion || sessionCleared) return _activeAuthenticationState ?? ANONYMOUS;
            await EnsureDbPermissionsLoadedAsync(jwtClaims, version);
            if (version != sessionVersion || sessionCleared) return _activeAuthenticationState ?? ANONYMOUS;

            SetActiveAuthenticationState(normalizedToken, authState);
            return authState;
        }

        public async Task LoginAsync(string token)
        {
            var version = ++sessionVersion;
            sessionCleared = true;
            _httpClient.DefaultRequestHeaders.Authorization = null;
            _activeToken = null;
            _activeAuthenticationState = null;
            var normalized = NormalizeToken(token);
            _permissions.Clear();
            _dbPermissionsRefreshAttempted = false;
            await _branchState.ClearSucursalAsync();
            if (version != sessionVersion) return;
            await _yearState.ClearAnioAsync();
            if (version != sessionVersion) return;
            await WriteSessionAsync(version, () => _js.RemoveItem(DB_CLAIMS_KEY));
            await WriteSessionAsync(version, () => _js.SetInLocalStorage(TOKEN_KEY, normalized));
            if (version != sessionVersion) return;

            var authState = BuildAuthenticationState(normalized);
            if (authState == null)
            {
                await ClearStoredSessionAsync();
                NotifyAuthenticationStateChanged(Task.FromResult(ANONYMOUS));
                return;
            }

            SetActiveAuthenticationState(normalized, authState);

            // Asegurar que el HttpClient tenga el header Authorization inmediatamente
            try
            {
                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", normalized);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo establecer el encabezado de autorizacion al iniciar sesion.");
            }

            NotifyAuthenticationStateChanged(Task.FromResult(authState));
        }

        public async Task LogoutAsync()
        {
            var closingVersion = sessionVersion + 1;
            await ClearStoredSessionAsync();
            if (sessionVersion == closingVersion)
                NotifyAuthenticationStateChanged(Task.FromResult(ANONYMOUS));
        }

        /// <summary>
        /// Carga los permisos provenientes de la base de datos, los guarda en localStorage
        /// y los añade al almacén en memoria.
        /// Llamar después del login exitoso.
        /// </summary>
        public async Task<bool> LoadClaimsFromDbAsync(List<ClaimItemModel> claimsFromDb, string expectedToken)
        {
            if (sessionCleared || string.IsNullOrWhiteSpace(expectedToken) ||
                !string.Equals(_activeToken, NormalizeToken(expectedToken), StringComparison.Ordinal)) return false;
            var version = sessionVersion;
            claimsFromDb ??= new List<ClaimItemModel>();
            _permissions.Clear();

            // Guardar en localStorage para persistencia
            var json = JsonSerializer.Serialize(claimsFromDb);
            await WriteSessionAsync(version, () => _js.SetInLocalStorage(DB_CLAIMS_KEY, json));
            if (version != sessionVersion || sessionCleared) return false;

            // Cargar en memoria (fusionando)
            foreach (var item in claimsFromDb)
                AddPermissionEntry(item.Group, item.SubGroup, item.Values);

            // Opcional: notificar cambio de estado si quieres que los componentes se actualicen
            NotifyAuthenticationStateChanged(Task.FromResult(_activeAuthenticationState ?? ANONYMOUS));
            return true;
        }

        #region Métodos públicos de permisos

        public bool HasPermission(string group, string subGroup, string action)
        {
            if (sessionCleared || (_activeAuthenticationState != null && IsTokenExpired(_activeAuthenticationState.User.Claims)))
                return false;
            if (EG.Common.Security.SystemRoles.IsSuperAdmin(_activeAuthenticationState?.User))
                return true;
            if (string.IsNullOrWhiteSpace(group) || string.IsNullOrWhiteSpace(action))
                return false;

            var normalizedGroup = group.Trim();
            var normalizedSubGroup = subGroup?.Trim() ?? string.Empty;
            var normalizedAction = action.Trim();

            if (!_permissions.TryGetValue(normalizedGroup, out var subDict))
            {
                subDict = _permissions
                    .FirstOrDefault(permissionGroup =>
                        string.Equals(
                            NormalizePermissionKey(permissionGroup.Key),
                            NormalizePermissionKey(normalizedGroup),
                            StringComparison.OrdinalIgnoreCase))
                    .Value;

                if (subDict == null)
                    return false;
            }

            // Permiso exacto en subgrupo
            if (subDict.TryGetValue(normalizedSubGroup, out var actions) && HasAction(actions, normalizedAction))
                return true;

            // Permiso general del grupo (subgrupo vacío)
            if (subDict.TryGetValue(string.Empty, out var generalActions) && HasAction(generalActions, normalizedAction))
                return true;

            var looseSubGroup = NormalizePermissionKey(normalizedSubGroup);
            foreach (var permissionSubGroup in subDict)
            {
                if (!string.Equals(NormalizePermissionKey(permissionSubGroup.Key), looseSubGroup, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (HasAction(permissionSubGroup.Value, normalizedAction))
                {
                    return true;
                }
            }

            return false;
        }

        public int? GetUserId()
        {
            if (sessionCleared || _activeAuthenticationState == null || IsTokenExpired(_activeAuthenticationState.User.Claims))
                return null;
            return GetUserIdFromClaims(_activeAuthenticationState.User.Claims);
        }

        public async Task<int?> GetUserIdAsync()
        {
            var state = await GetAuthenticationStateAsync();
            return GetUserIdFromClaims(state.User.Claims);
        }

        #endregion

        #region Métodos privados auxiliares

        private static string NormalizeToken(string rawToken)
        {
            if (string.IsNullOrWhiteSpace(rawToken)) return string.Empty;
            var trimmed = rawToken.Trim();
            // Quitar comillas dobles o simples al inicio/fin si existen
            if ((trimmed.StartsWith('"') && trimmed.EndsWith('"')) ||
                (trimmed.StartsWith('\'') && trimmed.EndsWith('\'')))
                trimmed = trimmed[1..^1];
            // Quitar prefijo "Bearer " si existe
            const string bearer = "Bearer ";
            return trimmed.StartsWith(bearer, StringComparison.OrdinalIgnoreCase)
                ? trimmed[bearer.Length..]
                : trimmed;
        }

        private List<Claim> ParseClaimsFromJwt(string jwt)
        {
            try
            {
                var payload = jwt.Split('.')[1];
                var jsonBytes = ParseBase64WithoutPadding(payload);
                var json = Encoding.UTF8.GetString(jsonBytes);
                var keyValuePairs = JsonSerializer.Deserialize<Dictionary<string, object>>(json);
                if (keyValuePairs == null) return new List<Claim>();

                var claims = new List<Claim>();
                foreach (var kvp in keyValuePairs)
                {
                    if (kvp.Value is JsonElement element)
                    {
                        if (element.ValueKind == JsonValueKind.Array)
                        {
                            foreach (var item in element.EnumerateArray())
                                claims.Add(new Claim(kvp.Key, item.ToString()));
                        }
                        else
                        {
                            claims.Add(new Claim(kvp.Key, element.ToString()));
                        }
                    }
                    else if (kvp.Value != null)
                    {
                        claims.Add(new Claim(kvp.Key, kvp.Value.ToString()!));
                    }
                }

                // Normalizar roles
                if (keyValuePairs.TryGetValue("role", out var roleObj) && roleObj != null)
                    claims.Add(new Claim(ClaimTypes.Role, roleObj.ToString()!));
                if (keyValuePairs.TryGetValue("roles", out var rolesObj) && rolesObj != null)
                {
                    var roles = rolesObj.ToString();
                    if (!string.IsNullOrEmpty(roles))
                    {
                        foreach (var role in roles.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                            claims.Add(new Claim(ClaimTypes.Role, role));
                    }
                }

                return claims;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo interpretar el token de autenticacion recibido.");
                return new List<Claim>();
            }
        }

        private bool IsTokenExpired(IEnumerable<Claim> claims)
        {
            var expClaim = claims.FirstOrDefault(claim =>
                string.Equals(claim.Type, "exp", StringComparison.OrdinalIgnoreCase));

            if (expClaim == null || !long.TryParse(expClaim.Value, out var unixSeconds) ||
                unixSeconds < -62135596800L || unixSeconds > 253402300799L)
            {
                return true;
            }

            var expiration = DateTimeOffset.FromUnixTimeSeconds(unixSeconds);
            return expiration <= _clock.GetUtcNow().AddSeconds(30);
        }

        private async Task ClearStoredSessionAsync()
        {
            var version = ++sessionVersion;
            sessionCleared = true;
            _httpClient.DefaultRequestHeaders.Authorization = null;
            _permissions.Clear();
            _dbPermissionsRefreshAttempted = false;
            _activeToken = null;
            _activeAuthenticationState = null;

            foreach (var clear in new Func<Task>[]
            {
                () => WriteSessionAsync(version, () => _js.RemoveItem(TOKEN_KEY)),
                () => WriteSessionAsync(version, () => _js.RemoveItem(DB_CLAIMS_KEY)),
                () => WriteSessionAsync(version, () => _js.RemoveItem(USER_ID_KEY)),
                () => WriteSessionAsync(version, () => _js.RemoveItem(USER_NAME_KEY)),
                () => _branchState.ClearSucursalAsync(),
                () => _yearState.ClearAnioAsync()
            })
            {
                if (version != sessionVersion) return;
                try
                {
                    await clear();
                }
                catch (Exception exception)
                {
                    _logger.LogWarning("No se pudo completar una limpieza local de sesión. Tipo: {ErrorType}", exception.GetType().Name);
                }
            }
        }

        private async Task WriteSessionAsync(int version, Func<ValueTask<object>> write)
        {
            await sessionStorageGate.WaitAsync();
            try
            {
                if (version == sessionVersion) await write();
            }
            finally
            {
                sessionStorageGate.Release();
            }
        }

        private AuthenticationState? BuildAuthenticationState(string normalizedToken)
        {
            var jwtClaims = ParseClaimsFromJwt(normalizedToken);
            if (jwtClaims.Count == 0 || IsTokenExpired(jwtClaims))
            {
                return null;
            }

            _permissions.Clear();
            LoadPermissionsFromClaims(jwtClaims);

            var identity = new ClaimsIdentity(jwtClaims, "jwt");
            EnsureNameIdentifier(identity, jwtClaims);

            return new AuthenticationState(new ClaimsPrincipal(identity));
        }

        private void SetActiveAuthenticationState(string normalizedToken, AuthenticationState authState)
        {
            sessionCleared = false;
            _activeToken = normalizedToken;
            _activeAuthenticationState = authState;
        }

        private static byte[] ParseBase64WithoutPadding(string base64)
        {
            if (string.IsNullOrEmpty(base64))
                return Array.Empty<byte>();

            // Calcular el padding necesario (JWT usa base64 sin padding)
            int mod4 = base64.Length % 4;
            string padded = mod4 switch
            {
                2 => base64 + "==",
                3 => base64 + "=",
                _ => base64
            };
            return Convert.FromBase64String(padded);
        }

        public void LoadPermissionsFromClaims(IEnumerable<Claim> claims)
        {
            var groups = claims.Where(c => string.Equals(c.Type, "Group", StringComparison.OrdinalIgnoreCase)).ToList();
            var subGroups = claims.Where(c => string.Equals(c.Type, "SubGroup", StringComparison.OrdinalIgnoreCase)).ToList();
            var values = claims.Where(c => string.Equals(c.Type, "Values", StringComparison.OrdinalIgnoreCase)).ToList();

            if (!groups.Any()) return;

            int maxCount = Math.Max(groups.Count, Math.Max(subGroups.Count, values.Count));
            for (int i = 0; i < maxCount; i++)
            {
                var group = (i < groups.Count) ? groups[i].Value : groups[0].Value;
                var subgroup = (i < subGroups.Count) ? subGroups[i].Value : (subGroups.FirstOrDefault()?.Value ?? string.Empty);
                var value = (i < values.Count) ? values[i].Value : (values.FirstOrDefault()?.Value ?? string.Empty);
                AddPermissionEntry(group, subgroup, value);
            }
        }

        private async Task LoadPersistedDbPermissions(int version)
        {
            try
            {
                var json = await _js.GetFromLocalStorage(DB_CLAIMS_KEY);
                if (version != sessionVersion || sessionCleared) return;
                if (string.IsNullOrWhiteSpace(json)) return;

                var dbClaims = JsonSerializer.Deserialize<List<ClaimItemModel>>(json);
                if (dbClaims == null) return;

                foreach (var item in dbClaims)
                    AddPermissionEntry(item.Group, item.SubGroup, item.Values);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudieron restaurar los permisos almacenados del usuario.");
            }
        }

        private async Task EnsureDbPermissionsLoadedAsync(IEnumerable<Claim> jwtClaims, int version)
        {
            if (_dbPermissionsRefreshAttempted)
            {
                return;
            }

            _dbPermissionsRefreshAttempted = true;

            var userId = GetUserIdFromClaims(jwtClaims);
            if (!userId.HasValue)
            {
                return;
            }

            try
            {
                var claims = await _httpClient.GetFromJsonAsync<List<ClaimItemModel>>($"api/Navigate/claims/{userId.Value}")
                             ?? new List<ClaimItemModel>();
                if (version != sessionVersion || sessionCleared) return;

                if (claims.Count == 0)
                {
                    return;
                }

                await WriteSessionAsync(version, () => _js.SetInLocalStorage(DB_CLAIMS_KEY, JsonSerializer.Serialize(claims)));
                if (version != sessionVersion || sessionCleared) return;
                foreach (var item in claims)
                {
                    AddPermissionEntry(item.Group, item.SubGroup, item.Values);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudieron actualizar los permisos del usuario desde la API.");
            }
        }

        private static int? GetUserIdFromClaims(IEnumerable<Claim> claims)
        {
            var idClaim = claims.FirstOrDefault(c => string.Equals(c.Type, ClaimTypes.NameIdentifier, StringComparison.OrdinalIgnoreCase)
                                                  || string.Equals(c.Type, "sub", StringComparison.OrdinalIgnoreCase)
                                                  || string.Equals(c.Type, "nameid", StringComparison.OrdinalIgnoreCase)
                                                  || string.Equals(c.Type, "id", StringComparison.OrdinalIgnoreCase)
                                                  || string.Equals(c.Type, "Id", StringComparison.OrdinalIgnoreCase));

            return idClaim != null && int.TryParse(idClaim.Value, out var id) ? id : null;
        }

        private void AddPermissionEntry(string group, string subgroup, string valuesRaw)
        {
            if (string.IsNullOrWhiteSpace(group)) return;

            group = group.Trim();
            subgroup = subgroup?.Trim() ?? string.Empty;

            var actions = valuesRaw?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                                   .Where(v => !string.IsNullOrWhiteSpace(v))
                                   .Select(v => v.Trim())
                                   .ToHashSet(StringComparer.OrdinalIgnoreCase)
                          ?? new HashSet<string>();

            if (!_permissions.TryGetValue(group, out var subDict))
            {
                subDict = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
                _permissions[group] = subDict;
            }

            if (!subDict.TryGetValue(subgroup, out var actionSet))
            {
                actionSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                subDict[subgroup] = actionSet;
            }

            foreach (var action in actions)
                actionSet.Add(action);
        }

        private static bool HasAction(HashSet<string> actions, string action)
        {
            return actions.Contains(action)
                || actions.Any(value => string.Equals(NormalizeActionKey(value), NormalizeActionKey(action), StringComparison.OrdinalIgnoreCase));
        }

        private static string NormalizePermissionKey(string? value)
        {
            var normalized = (value ?? string.Empty)
                .Trim()
                .Normalize(System.Text.NormalizationForm.FormD);

            return new string(normalized
                .Where(ch => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(ch) != System.Globalization.UnicodeCategory.NonSpacingMark)
                .Where(char.IsLetterOrDigit)
                .Select(char.ToLowerInvariant)
                .ToArray());
        }

        private static string NormalizeActionKey(string? action)
        {
            var key = (action ?? string.Empty)
                .Trim()
                .Replace("_", "-", StringComparison.Ordinal)
                .Replace(" ", "-", StringComparison.Ordinal)
                .ToLowerInvariant();

            return key switch
            {
                "viewmenu" or "view-menu" or "menu" => "view-menu",
                "canexporttoexcel" or "can-export-to-excel" or "export" or "export-excel" or "excel" => "excel",
                "new" or "nuevo" or "create" or "crear" or "add" or "agregar" => "new",
                "update" or "editar" or "edit" or "modify" or "modificar" => "update",
                "delete" or "eliminar" or "remove" or "borrar" => "delete",
                "authorize" or "autorizar" or "auth" => "authorize",
                "view" or "ver" => "view",
                _ => key
            };
        }

        private static void EnsureNameIdentifier(ClaimsIdentity identity, IEnumerable<Claim> allClaims)
        {
            if (identity.HasClaim(c => c.Type == ClaimTypes.NameIdentifier))
                return;

            var idClaim = allClaims.FirstOrDefault(c => string.Equals(c.Type, "sub", StringComparison.OrdinalIgnoreCase)
                                                     || string.Equals(c.Type, "nameid", StringComparison.OrdinalIgnoreCase)
                                                     || string.Equals(c.Type, "id", StringComparison.OrdinalIgnoreCase)
                                                     || string.Equals(c.Type, "Id", StringComparison.OrdinalIgnoreCase));
            if (idClaim != null)
                identity.AddClaim(new Claim(ClaimTypes.NameIdentifier, idClaim.Value));
        }

        #endregion
    }
}

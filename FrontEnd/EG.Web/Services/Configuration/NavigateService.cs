using EG.Common.GenericModel;
using EG.Web.Contracts.Configuration;
using EG.Web.Helpers;
using EG.Web.Models.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System.Net.Http.Headers;
using System.Text.Json;
//using Const = EG.Common.Constants;


namespace EG.Web.Services
{
    public class NavigateService : INavigateService
    {
        //private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(NavigateService));
        private readonly IJSRuntime _jsRuntime;
        private readonly HttpClient _httpClient;
        private readonly ILogger<NavigateService> _logger;

        public static readonly string TOKENKEY = "authToken";

        public bool IsAuthenticated { get; private set; } = false;

        public NavigateService(HttpClient httpClient, IJSRuntime jsRuntime, ILogger<NavigateService> logger)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _logger = logger;
        }

        public async Task<MenuResponse> GetMenuAsync(int _userId)
        {
            var resultado = new MenuResponse
            {
                Success = false,
                Message = "No fue posible cargar el menu. Intenta recargar la pagina."
            };

            try
            {
                // Leer token desde localStorage (evitar dependencia de extensiones si hay ambigüedad)
                string? rawToken = null;
                try
                {
                    rawToken = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", TOKENKEY);
                }
                catch (Exception ex)
                {
                    _logger.LogDebug(ex, "No fue posible leer el token con la API directa de localStorage.");
                    // fallback a extensión si existiera
                    rawToken = await _jsRuntime.GetFromLocalStorage(TOKENKEY);
                }

                if (string.IsNullOrWhiteSpace(rawToken))
                {
                    resultado.Message = "Tu sesion ya no esta disponible. Inicia sesion nuevamente.";
                    _logger.LogWarning("No se cargo el menu porque no existe un token para el usuario {UserId}.", _userId);
                    return resultado;
                }

                // Normalizar token: eliminar comillas envolventes y posible prefijo "Bearer "
                rawToken = rawToken.Trim();
                if ((rawToken.StartsWith("\"") && rawToken.EndsWith("\"")) || (rawToken.StartsWith("'") && rawToken.EndsWith("'")))
                {
                    rawToken = rawToken.Substring(1, rawToken.Length - 2);
                }

                string tokenValue = rawToken.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
                    ? rawToken.Substring("Bearer ".Length)
                    : rawToken;

                // Construir petición GET usando el HttpClient inyectado y adjuntar header en el HttpRequestMessage
                var request = new HttpRequestMessage(HttpMethod.Get, $"api/Navigate/{_userId}");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", tokenValue);

                HttpResponseMessage response = await _httpClient.SendAsync(request);

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();

                    // Deserializamos directamente a una lista
                    var items = JsonSerializer.Deserialize<List<MenuItem>>(responseBody, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                    resultado.Items = BuildMenuTreeV2(items ?? new List<MenuItem>()) ?? new List<MenuItem>();
                    resultado.Success = true;
                    resultado.Message = resultado.Items.Count == 0
                        ? "No tienes opciones de menu asignadas. Solicita acceso al administrador."
                        : "Menu cargado correctamente.";

                    return resultado;
                }
                else if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                {
                    resultado.Message = "Tu sesion ya no esta disponible. Inicia sesion nuevamente.";
                    _logger.LogWarning("La API rechazo la carga del menu para el usuario {UserId} por sesion no valida.", _userId);
                    return resultado;
                    // Si recibimos 401, limpiar estado cliente y devolver vacío para forzar re-login desde UI
                }
                _logger.LogError(
                    "La API no pudo cargar el menu. UserId={UserId}; StatusCode={StatusCode}",
                    _userId,
                    (int)response.StatusCode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al cargar el menu del usuario {UserId}.", _userId);
            }

            return resultado;
        }

        private List<MenuItem> BuildMenuTree(List<MenuItem> flatItems)
        {
            var lookup = flatItems.ToLookup(item => item.FkidMenuSis);

            foreach (var item in flatItems)
            {
                item.Children.AddRange(lookup[item.FkidMenuSis].OrderBy(x => x.Orden));
            }

            return lookup[0].OrderBy(x => x.Orden).ToList();
        }

        public static List<MenuItem> BuildMenuTreeV2(List<MenuItem> flatMenuList)
        {
            foreach (var menu in flatMenuList)
            {
                menu.Children.Clear();
            }

            var menuLookup = flatMenuList
                .GroupBy(m => m.PkidMenu)
                .ToDictionary(group => group.Key, group => group.First());
            var rootMenus = new List<MenuItem>();

            foreach (var menuItem in flatMenuList)
            {
                if ((!menuItem.FkidMenuSis.HasValue || menuItem.FkidMenuSis.Value == 0))
                {
                    // Es un menú raíz
                    rootMenus.Add(menuItem);
                }
                else
                {
                    // Es un hijo, lo agregamos al padre correspondiente
                    if (menuLookup.TryGetValue(menuItem.FkidMenuSis.Value, out var parentMenu))
                    {
                        parentMenu.Children.Add(menuItem);
                    }
                }
            }

            // Ordenar los menús y sus hijos por el campo Orden
            foreach (var menu in rootMenus)
            {
                SortMenu(menu);
            }

            return rootMenus.OrderBy(m => m.Orden).ToList();
        }

        private static void SortMenu(MenuItem menu)
        {
            if (menu.Children.Any())
            {
                menu.Children = menu.Children.OrderBy(c => c.Orden).ToList();
                foreach (var child in menu.Children)
                {
                    SortMenu(child);
                }
            }
        }

        /// <summary>
        /// Llama a GET api/Navigate/claims/{userId} y retorna la lista de claims (Group/SubGroup/Values)
        /// </summary>
        public async Task<List<ClaimItemModel>> GetAllClaimsByUserAsync(int userId)
        {
            try
            {
                // Leer y normalizar token
                string? rawToken = null;
                try
                {
                    rawToken = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", TOKENKEY);
                }
                catch (Exception ex)
                {
                    _logger.LogDebug(ex, "No fue posible leer el token para consultar permisos con la API directa de localStorage.");
                    rawToken = await _jsRuntime.GetFromLocalStorage(TOKENKEY);
                }

                if (string.IsNullOrWhiteSpace(rawToken))
                {
                    _logger.LogWarning("No se consultaron los permisos porque no existe un token para el usuario {UserId}.", userId);
                    return new List<ClaimItemModel>();
                }

                rawToken = rawToken.Trim();
                if ((rawToken.StartsWith("\"") && rawToken.EndsWith("\"")) || (rawToken.StartsWith("'") && rawToken.EndsWith("'")))
                    rawToken = rawToken.Substring(1, rawToken.Length - 2);

                string tokenValue = rawToken.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
                    ? rawToken.Substring("Bearer ".Length)
                    : rawToken;

                var request = new HttpRequestMessage(HttpMethod.Get, $"api/Navigate/claims/{userId}");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", tokenValue);

                HttpResponseMessage response = await _httpClient.SendAsync(request);

                if (response.IsSuccessStatusCode)
                {
                    string body = await response.Content.ReadAsStringAsync();
                    var claims = JsonSerializer.Deserialize<List<ClaimItemModel>>(body, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });
                    return claims ?? new List<ClaimItemModel>();
                }

                _logger.LogWarning(
                    "La API no devolvio los permisos del usuario {UserId}. StatusCode={StatusCode}",
                    userId,
                    (int)response.StatusCode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al consultar los permisos del usuario {UserId}.", userId);
            }

            return new List<ClaimItemModel>();
        }

    }
}

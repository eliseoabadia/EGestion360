using EG.Common.GenericModel;
using EG.Common.Helper;
using EG.Web.Contracts.Configuration;
using EG.Web.Helpers;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;
using System.Net.Http.Headers;
using System.Text.Json;
//using Const = EG.Common.Constants;


namespace EG.Web.Services
{
    public class NavigateService : INavigateService
    {
        //private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(NavigateService));
        private readonly ApplicationInstance _application;
        private readonly IJSRuntime _jsRuntime;
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;

        public static readonly string TOKENKEY = "authToken";

        public bool IsAuthenticated { get; private set; } = false;

        public NavigateService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _application = application;
            _baseUrl = httpClient.BaseAddress?.ToString() ?? string.Empty;
        }

        public async Task<MenuResponse> GetMenuAsync(int _userId)
        {
            MenuResponse resultado = new MenuResponse();

            try
            {
                // Leer token desde localStorage (evitar dependencia de extensiones si hay ambigüedad)
                string? rawToken = null;
                try
                {
                    rawToken = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", TOKENKEY);
                }
                catch
                {
                    // fallback a extensión si existiera
                    rawToken = await _jsRuntime.GetFromLocalStorage(TOKENKEY);
                }

                if (string.IsNullOrWhiteSpace(rawToken))
                {
                    Console.WriteLine("NavigateService.GetMenuAsync: token no disponible; se omite la carga del menu.");
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

                Console.WriteLine($"=== NavigateService.GetMenuAsync: Sending request to api/Navigate/{_userId} ===");
                HttpResponseMessage response = await _httpClient.SendAsync(request);
                Console.WriteLine($"Response status: {(int)response.StatusCode} {response.StatusCode}");

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"Response body length: {responseBody.Length}");
                    Console.WriteLine($"Response body (first 300 chars): {responseBody.Substring(0, Math.Min(300, responseBody.Length))}");

                    // Deserializamos directamente a una lista
                    var items = JsonSerializer.Deserialize<List<MenuItem>>(responseBody, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });
                    Console.WriteLine($"Deserialized items count: {items?.Count}");

                    resultado.Items = BuildMenuTreeV2(items ?? new List<MenuItem>()) ?? new List<MenuItem>();
                    Console.WriteLine($"After BuildMenuTreeV2 - root items: {resultado.Items?.Count}");

                    return resultado;
                }
                else if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                {
                    // Si recibimos 401, limpiar estado cliente y devolver vacío para forzar re-login desde UI
                    Console.WriteLine("NavigateService: Unauthorized (401) al obtener menu. SessionGuard administrara la sesion activa.");
                }
                else
                {
                    var errorBody = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"Error al obtener menú: {response.StatusCode}, Body: {errorBody}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al obtener menú: {ex}");
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
            var menuLookup = flatMenuList.ToDictionary(m => m.PkidMenu);
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
                catch
                {
                    rawToken = await _jsRuntime.GetFromLocalStorage(TOKENKEY);
                }

                if (string.IsNullOrWhiteSpace(rawToken))
                {
                    Console.WriteLine("GetAllClaimsByUserAsync: No hay token disponible.");
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
                    Console.WriteLine($"GetAllClaimsByUserAsync: {claims?.Count ?? 0} claims obtenidos.");
                    return claims ?? new List<ClaimItemModel>();
                }

                Console.WriteLine($"GetAllClaimsByUserAsync: Error HTTP {response.StatusCode}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"GetAllClaimsByUserAsync Exception: {ex.Message}");
            }

            return new List<ClaimItemModel>();
        }

    }
}

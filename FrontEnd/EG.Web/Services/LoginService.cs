using EG.Common.Helper;
using EG.Web.Contracs;
using EG.Web.Models;
using EG.Web.Models.Configuration;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.JSInterop;
using System.Text;
using System.Text.Json;
using Const = EG.Common.Constants;

namespace EG.Web.Services
{
    public class LoginService : ILoginService
    {
        private readonly ApplicationInstance _application;
        private readonly IJSRuntime _jsRuntime;
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;
        public bool IsAuthenticated { get; private set; } = false;

        public LoginService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _application = application;
            _baseUrl = httpClient.BaseAddress?.ToString() ?? string.Empty;
        }

        public async Task<UserResult> LoginAsync(string usuario, string password)
        {
            UserResult resultado = new UserResult();

            try
            {
                var jsonParams = new
                {
                    email = usuario,
                    password = password
                };

                string jsonString = JsonSerializer.Serialize(jsonParams);

                var content = new StringContent(jsonString, Encoding.UTF8, "application/json");

                Console.WriteLine($"LoginService: Intentando login en {_httpClient.BaseAddress}api/Auth/Login/");

                HttpResponseMessage response = await _httpClient.PostAsync("api/Auth/Login/", content);

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();

                    resultado = JsonSerializer.Deserialize<UserResult>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? new UserResult();
                    if (!string.IsNullOrWhiteSpace(resultado.PayrollId))
                    {
                        IsAuthenticated = true;
                        _application.SetVariable(Const.KEY_USERID, resultado.PkIdUsuario);
                        _application.SetVariable(Const.KEY_TOKEN, resultado.AccessToken);
                        Console.WriteLine($"LoginService: Login exitoso para usuario {usuario}");
                    }
                }
                else
                {
                    resultado.PayrollId = "0";
                    string responseBody = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"LoginService Error HTTP {response.StatusCode}: {responseBody}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"LoginService Exception: {ex.Message}");
                Console.WriteLine($"Stack: {ex.StackTrace}");
                resultado.PayrollId = "0";
            }

            return resultado;
        }

        public async Task<List<SucursalResponse>> GetSucursalesUsuarioAsync(int usuarioId)
        {
            try
            {
                var token = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", "authToken");
                if (string.IsNullOrEmpty(token))
                {
                    Console.WriteLine("GetSucursalesUsuarioAsync: No hay token en localStorage");
                    return new List<SucursalResponse>();
                }

                // Normalizar el token (remover comillas si existen)
                token = token.Trim('"', '\'');
                if (token.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                {
                    token = token.Substring("Bearer ".Length);
                }

                _httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

                var url = $"api/UsuarioSucursal/usuario/{usuarioId}";
                Console.WriteLine($"GetSucursalesUsuarioAsync: Llamando a {_httpClient.BaseAddress}{url}");

                HttpResponseMessage response = await _httpClient.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    var result = JsonSerializer.Deserialize<ApiResponse<VwUsuarioSucursalResponse>>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                    if (result?.Success == true && result.Items != null)
                    {
                        var sucursales = result.Items.Select(x => new SucursalResponse
                        {
                            PkidSucursal = x.IdSucursal ?? 0,
                            Nombre = x.NombreSucursal ?? string.Empty,
                            Direccion = x.DireccionSucursal ?? string.Empty
                        }).ToList();

                        Console.WriteLine($"GetSucursalesUsuarioAsync: Éxito. Se obtuvieron {sucursales.Count} sucursales");
                        return sucursales;
                    }
                    else
                    {
                        Console.WriteLine($"GetSucursalesUsuarioAsync: Respuesta sin datos o no exitosa");
                    }
                }
                else
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"GetSucursalesUsuarioAsync Error HTTP {response.StatusCode}");
                    Console.WriteLine($"Response: {errorContent}");
                    Console.WriteLine($"Headers: {string.Join(", ", response.Headers.Select(h => $"{h.Key}: {string.Join(",", h.Value)}"))}");
                }
            }
            catch (HttpRequestException ex)
            {
                Console.WriteLine($"GetSucursalesUsuarioAsync HttpRequestException: {ex.Message}");
                Console.WriteLine($"Stack: {ex.StackTrace}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"GetSucursalesUsuarioAsync Exception: {ex.Message}");
                Console.WriteLine($"Stack: {ex.StackTrace}");
            }

            return new List<SucursalResponse>();
        }

        public Task Logout()
        {
            throw new NotImplementedException();
        }
    }
}

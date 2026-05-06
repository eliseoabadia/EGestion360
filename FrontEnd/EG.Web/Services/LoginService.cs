using EG.Common.Helper;
using EG.Domain.DTOs.Responses.General;
using EG.Web.Contracts;
using EG.Web.Models;
using Microsoft.JSInterop;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Const = EG.Common.Constants;

namespace EG.Web.Services
{
    public class LoginService : ILoginService
    {
        private readonly ApplicationInstance _application;
        private readonly IJSRuntime _jsRuntime;
        private readonly IHttpClientFactory _httpClientFactory;
        public bool IsAuthenticated { get; private set; } = false;

        public LoginService(IHttpClientFactory httpClientFactory, IJSRuntime jsRuntime, ApplicationInstance application)
        {
            _httpClientFactory = httpClientFactory;
            _jsRuntime = jsRuntime;
            _application = application;
        }

        public async Task<UserResult> LoginAsync(string usuario, string password)
        {
            UserResult resultado = new UserResult();

            try
            {
                var client = _httpClientFactory.CreateClient("ApiClient");
                var requestBody = new { email = usuario, password = password };
                var response = await client.PostAsJsonAsync("api/Auth/Login", requestBody);

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    resultado = JsonSerializer.Deserialize<UserResult>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? new UserResult();

                    if (!string.IsNullOrWhiteSpace(resultado.PayrollId))
                    {
                        IsAuthenticated = true;
                        _application.SetVariable(Const.KEY_USERID, resultado.PkIdUsuario);
                        _application.SetVariable(Const.KEY_TOKEN, resultado.AccessToken);

                        // Opcional: guardar token en localStorage para persistencia entre recargas
                        await _jsRuntime.InvokeVoidAsync("localStorage.setItem", "authToken", resultado.AccessToken);

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
                // Obtener token desde localStorage (consistente con LoginAsync)
                var token = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", "authToken");
                if (string.IsNullOrEmpty(token))
                {
                    Console.WriteLine("GetSucursalesUsuarioAsync: No hay token en localStorage");
                    return new List<SucursalResponse>();
                }

                // Normalizar el token (remover comillas si existen)
                token = token.Trim('"', '\'');

                // Crear cliente HTTP con la configuración "ApiClient"
                var client = _httpClientFactory.CreateClient("ApiClient");
                // Agregar el token Bearer al cliente para esta petición
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

                var url = $"api/UsuarioSucursal/usuario/{usuarioId}";
                Console.WriteLine($"GetSucursalesUsuarioAsync: Llamando a {client.BaseAddress}{url}");

                HttpResponseMessage response = await client.GetAsync(url);

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

        public async Task Logout()
        {
            // Limpiar estado de autenticación
            IsAuthenticated = false;
            _application.RemoveVariable(Const.KEY_USERID);
            _application.RemoveVariable(Const.KEY_TOKEN);
            await _jsRuntime.InvokeVoidAsync("localStorage.removeItem", "authToken");
            Console.WriteLine("Logout completado");
        }
    }
}
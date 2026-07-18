using EG.Common.Helper;
using EG.Common;
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
        private readonly ILogger<LoginService> _logger;
        public bool IsAuthenticated { get; private set; } = false;

        public LoginService(
            IHttpClientFactory httpClientFactory,
            IJSRuntime jsRuntime,
            ApplicationInstance application,
            ILogger<LoginService> logger)
        {
            _httpClientFactory = httpClientFactory;
            _jsRuntime = jsRuntime;
            _application = application;
            _logger = logger;
        }

        public async Task<UserResult> LoginAsync(string usuario, string password)
        {
            UserResult resultado = FailedLogin("No fue posible iniciar sesion. Intenta nuevamente.");

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

                    }
                }
                else
                {
                    _logger.LogWarning(
                        "Inicio de sesion rechazado. Status={StatusCode}; Usuario={Usuario}",
                        (int)response.StatusCode,
                        usuario);
                    resultado = FailedLogin(response.StatusCode == System.Net.HttpStatusCode.Unauthorized
                        ? "El usuario o la contrasena no son correctos."
                        : UserFacingMessages.OperationFailed("iniciar sesion"));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "No fue posible completar el inicio de sesion para {Usuario}.", usuario);
                resultado = FailedLogin(UserFacingMessages.OperationFailed("iniciar sesion"));
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
                    _logger.LogWarning("No se cargaron sucursales porque no existe una sesion local.");
                    return new List<SucursalResponse>();
                }

                // Normalizar el token (remover comillas si existen)
                token = token.Trim('"', '\'');

                // Crear cliente HTTP con la configuración "ApiClient"
                var client = _httpClientFactory.CreateClient("ApiClient");
                // Agregar el token Bearer al cliente para esta petición
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

                var url = $"api/UsuarioSucursal/usuario/{usuarioId}";

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
                            Direccion = x.DireccionSucursal ?? string.Empty,
                            FkidEmpresaSis = x.PkidEmpresa ?? x.IdEmpresa,
                            NombreEmpresa = x.NombreEmpresa,
                            CodigoSucursal = x.CodigoSucursal
                        }).ToList();

                        return sucursales;
                    }
                }
            }
            catch (HttpRequestException ex)
            {
                _logger.LogWarning(ex, "No fue posible consultar las sucursales del usuario {UsuarioId}.", usuarioId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al cargar sucursales del usuario {UsuarioId}.", usuarioId);
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
        }

        private static UserResult FailedLogin(string message) => new()
        {
            PayrollId = "0",
            Message = message,
            IsAuthenticated = false
        };
    }
}

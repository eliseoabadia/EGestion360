using EG.Common;
using EG.Common.Enums;
using EG.Common.Helper;
using EG.Web.Helpers;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.JSInterop;
using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace EG.Web.Services
{
    public abstract class BaseService
    {
        protected readonly ApplicationInstance _application;
        protected readonly IJSRuntime _jsRuntime;
        protected readonly HttpClient _httpClient;
        protected readonly string _baseUrl;
        protected readonly IConfiguration _configuration;
        protected readonly ILogger _logger;

        public static readonly string TOKENKEY = "authToken";
        private const string EMPRESA_KEY = "empresa_seleccionada";
        private const string EMPRESA_HEADER = "X-Empresa-Id";
        private const string ANIO_PRESUPUESTAL_KEY = "anio_presupuestal_seleccionado";
        private const string ANIO_PRESUPUESTAL_HEADER = "X-Anio-Presupuestal-Id";
        private static readonly TimeSpan TokenCacheDuration = TimeSpan.FromSeconds(30);
        private string? _cachedToken;
        private DateTimeOffset _cachedTokenExpiresAt = DateTimeOffset.MinValue;
        protected readonly JsonSerializerOptions _jsonOptions;

        public bool IsAuthenticated { get; protected set; } = false;

        protected BaseService(
            HttpClient httpClient,
            IJSRuntime jsRuntime,
            ApplicationInstance application,
            IConfiguration configuration,
            ILogger? logger = null)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _application = application;
            _configuration = configuration;
            _logger = logger ?? NullLogger.Instance;
            _baseUrl = httpClient.BaseAddress?.ToString()
              ?? _configuration["ApiSetting:baseUrl"]
              ?? string.Empty;
            _jsonOptions = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };
        }

        protected bool IsClientSide()
        {
            try
            {
                var _ = _jsRuntime.GetType();
                return true;
            }
            catch
            {
                return false;
            }
        }

        protected async Task<string?> GetTokenAsync()
        {
            if (!IsClientSide())
                return null;

            if (!string.IsNullOrWhiteSpace(_cachedToken) && _cachedTokenExpiresAt > DateTimeOffset.UtcNow)
            {
                return _cachedToken;
            }

            string? rawToken = null;
            try
            {
                rawToken = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", TOKENKEY);
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "No fue posible leer el token con la API directa de localStorage; se usara el mecanismo alterno.");
                rawToken = await _jsRuntime.GetFromLocalStorage(TOKENKEY);
            }

            if (string.IsNullOrWhiteSpace(rawToken))
            {
                await ClearAuthDataAsync();
                return null;
            }

            rawToken = rawToken.Trim();
            if ((rawToken.StartsWith("\"") && rawToken.EndsWith("\"")) ||
                (rawToken.StartsWith("'") && rawToken.EndsWith("'")))
            {
                rawToken = rawToken.Substring(1, rawToken.Length - 2);
            }

            _cachedToken = rawToken.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
                ? rawToken.Substring("Bearer ".Length)
                : rawToken;
            _cachedTokenExpiresAt = DateTimeOffset.UtcNow.Add(TokenCacheDuration);

            return _cachedToken;
        }

        protected async Task ClearAuthDataAsync()
        {
            _cachedToken = null;
            _cachedTokenExpiresAt = DateTimeOffset.MinValue;

            if (IsClientSide())
            {
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", "authToken", string.Empty);
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", "userId", string.Empty);
            }
        }

        protected async Task<HttpRequestMessage> CreateAuthenticatedRequestAsync(
            HttpMethod method,
            string endpoint)
        {
            var token = await GetTokenAsync();
            if (string.IsNullOrEmpty(token))
                throw new UnauthorizedAccessException("Token no disponible");

            var request = new HttpRequestMessage(method, endpoint);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            await AddEmpresaHeaderAsync(request);
            await AddAnioPresupuestalHeaderAsync(request);
            return request;
        }

        private async Task AddEmpresaHeaderAsync(HttpRequestMessage request)
        {
            var empresaId = await GetSelectedEmpresaIdAsync();
            if (empresaId.HasValue && empresaId.Value > 0)
            {
                request.Headers.Remove(EMPRESA_HEADER);
                request.Headers.Add(EMPRESA_HEADER, empresaId.Value.ToString());
            }
        }

        private async Task<int?> GetSelectedEmpresaIdAsync()
        {
            if (!IsClientSide())
                return null;

            try
            {
                var empresaIdRaw = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", EMPRESA_KEY);
                return int.TryParse(empresaIdRaw, out var empresaId) && empresaId > 0
                    ? empresaId
                    : null;
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "No fue posible obtener la empresa seleccionada desde localStorage.");
                return null;
            }
        }

        private async Task AddAnioPresupuestalHeaderAsync(HttpRequestMessage request)
        {
            var anioId = await GetSelectedAnioPresupuestalIdAsync();
            if (anioId.HasValue && anioId.Value > 0)
            {
                request.Headers.Remove(ANIO_PRESUPUESTAL_HEADER);
                request.Headers.Add(ANIO_PRESUPUESTAL_HEADER, anioId.Value.ToString());
            }
        }

        private async Task<int?> GetSelectedAnioPresupuestalIdAsync()
        {
            if (!IsClientSide())
                return null;

            try
            {
                var raw = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", ANIO_PRESUPUESTAL_KEY);
                if (string.IsNullOrWhiteSpace(raw))
                    return null;

                using var document = JsonDocument.Parse(raw);
                return document.RootElement.TryGetProperty("Id", out var idElement) &&
                    idElement.TryGetInt32(out var anioId) && anioId > 0
                    ? anioId
                    : null;
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "No fue posible obtener el ejercicio presupuestal seleccionado desde localStorage.");
                return null;
            }
        }

        protected async Task<T?> SendRequestAsync<T>(
            HttpMethod method,
            string endpoint,
            object? content = null,
            bool useBaseUrl = true)
        {
            try
            {
                var fullEndpoint = useBaseUrl ? endpoint : $"{_baseUrl}{endpoint}";
                using var request = await CreateAuthenticatedRequestAsync(method, fullEndpoint);

                if (content != null)
                {
                    var json = JsonSerializer.Serialize(content, _jsonOptions);
                    request.Content = new StringContent(json, Encoding.UTF8, "application/json");
                }

                using var response = await _httpClient.SendAsync(request);
                var responseBody = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    if (string.IsNullOrWhiteSpace(responseBody))
                    {
                        var successContract = CreateSuccessContract<T>("Operacion exitosa");
                        if (successContract != null)
                        {
                            return successContract;
                        }

                        return default;
                    }

                    if (typeof(T) == typeof(bool))
                    {
                        if (bool.TryParse(responseBody, out bool boolResult))
                        {
                            return (T)(object)boolResult;
                        }
                    }

                    var result = DeserializeResponse<T>(responseBody);
                    return NormalizeSuccessfulResponse(responseBody, result);
                }

                var userMessage = ExtractErrorMessage(responseBody, response.StatusCode);
                LogHttpFailure(method, endpoint, response.StatusCode, responseBody);

                var errorResult = DeserializeResponse<T>(responseBody);
                if (errorResult != null)
                {
                    EnsureErrorContract(errorResult, userMessage, ApiResponseCode.Error);
                    return errorResult;
                }

                return CreateErrorContract<T>(userMessage, ApiResponseCode.Error);
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "La solicitud {Method} {Endpoint} no tiene una sesion valida.", method, endpoint);
                return CreateErrorContract<T>("Tu sesion ya no esta disponible. Inicia sesion nuevamente.", ApiResponseCode.Unauthorized);
            }
            catch (OperationCanceledException ex)
            {
                _logger.LogWarning(ex, "La solicitud {Method} {Endpoint} fue cancelada o excedio el tiempo de espera.", method, endpoint);
                return CreateErrorContract<T>("La solicitud tardo demasiado. Intenta nuevamente.", ApiResponseCode.Error);
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "No fue posible comunicar con la API en {Method} {Endpoint}.", method, endpoint);
                return CreateErrorContract<T>("No fue posible comunicar con el servidor. Revisa tu conexion e intenta nuevamente.", ApiResponseCode.Error);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado en la solicitud {Method} {Endpoint}.", method, endpoint);
                return CreateErrorContract<T>(UserFacingMessages.UnexpectedError, ApiResponseCode.Error);
            }
        }

        protected async Task<(T? Result, bool Success, string Message)> SendRequestWithMessageAsync<T>(
            HttpMethod method,
            string endpoint,
            object? content = null,
            bool useBaseUrl = true)
        {
            try
            {
                var fullEndpoint = useBaseUrl ? endpoint : $"{_baseUrl}{endpoint}";
                using var request = await CreateAuthenticatedRequestAsync(method, fullEndpoint);

                if (content != null)
                {
                    var json = JsonSerializer.Serialize(content, _jsonOptions);
                    request.Content = new StringContent(json, Encoding.UTF8, "application/json");
                }

                using var response = await _httpClient.SendAsync(request);
                var responseBody = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    T? result;
                    if (typeof(T) == typeof(bool))
                    {
                        result = bool.TryParse(responseBody, out bool boolResult)
                            ? (T)(object)boolResult
                            : default;
                    }
                    else
                    {
                        result = DeserializeResponse<T>(responseBody);
                    }

                    return (result, true, "Operacion exitosa");
                }

                return (default, false, ExtractErrorMessage(responseBody, response.StatusCode));
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "La solicitud {Method} {Endpoint} no tiene una sesion valida.", method, endpoint);
                return (default, false, "Tu sesion ya no esta disponible. Inicia sesion nuevamente.");
            }
            catch (OperationCanceledException ex)
            {
                _logger.LogWarning(ex, "La solicitud {Method} {Endpoint} fue cancelada o excedio el tiempo de espera.", method, endpoint);
                return (default, false, "La solicitud tardo demasiado. Intenta nuevamente.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado en la solicitud {Method} {Endpoint}.", method, endpoint);
                return (default, false, UserFacingMessages.UnexpectedError);
            }
        }

        protected async Task<T?> GetAsync<T>(string endpoint, bool useBaseUrl = true)
            => await SendRequestAsync<T>(HttpMethod.Get, endpoint, null, useBaseUrl);

        protected async Task<T?> PostAsync<T>(string endpoint, object content, bool useBaseUrl = true)
            => await SendRequestAsync<T>(HttpMethod.Post, endpoint, content, useBaseUrl);

        protected async Task<T?> PutAsync<T>(string endpoint, object content, bool useBaseUrl = true)
            => await SendRequestAsync<T>(HttpMethod.Put, endpoint, content, useBaseUrl);

        protected async Task<T?> DeleteAsync<T>(string endpoint, bool useBaseUrl = true)
            => await SendRequestAsync<T>(HttpMethod.Delete, endpoint, null, useBaseUrl);

        protected async Task<T?> PatchAsync<T>(string endpoint, object content, bool useBaseUrl = true)
            => await SendRequestAsync<T>(HttpMethod.Patch, endpoint, content, useBaseUrl);

        private T? DeserializeResponse<T>(string responseBody)
        {
            if (string.IsNullOrWhiteSpace(responseBody))
            {
                return default;
            }

            try
            {
                return JsonSerializer.Deserialize<T>(responseBody, _jsonOptions);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No fue posible interpretar una respuesta de tipo {ResponseType}.", typeof(T).FullName);
                return default;
            }
        }

        private T? NormalizeSuccessfulResponse<T>(string responseBody, T? result)
        {
            var type = typeof(T);
            if (!IsApiResponseType(type) || LooksLikeApiResponse(responseBody))
            {
                if (result != null && IsApiResponseType(type))
                {
                    SetSuccessfulContract(type, result, "Operacion exitosa", GetTotalCount(type, result));
                }

                return result;
            }

            try
            {
                var dataType = type.GetGenericArguments()[0];
                var response = result ?? Activator.CreateInstance<T>();
                if (response == null)
                {
                    return result;
                }

                using var document = JsonDocument.Parse(responseBody);
                if (document.RootElement.ValueKind == JsonValueKind.Array)
                {
                    var listType = typeof(List<>).MakeGenericType(dataType);
                    var items = JsonSerializer.Deserialize(responseBody, listType, _jsonOptions);
                    var count = items is System.Collections.ICollection collection ? collection.Count : 0;
                    SetSuccessfulContract(type, response, "Operacion exitosa", count);
                    SetPropertyIfWritable(type, response, "Items", items);
                    return response;
                }

                var data = JsonSerializer.Deserialize(responseBody, dataType, _jsonOptions);
                if (data == null)
                {
                    return result;
                }

                SetSuccessfulContract(type, response, "Operacion exitosa", 1);
                SetPropertyIfWritable(type, response, "Data", data);

                var singleListType = typeof(List<>).MakeGenericType(dataType);
                var list = (System.Collections.IList)Activator.CreateInstance(singleListType)!;
                list.Add(data);
                SetPropertyIfWritable(type, response, "Items", list);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No fue posible normalizar una respuesta exitosa de tipo {ResponseType}.", typeof(T).FullName);
                return result;
            }
        }

        private static bool IsApiResponseType(Type type)
        {
            return type.IsGenericType && type.GetGenericTypeDefinition().Name == "ApiResponse`1";
        }

        private bool LooksLikeApiResponse(string responseBody)
        {
            try
            {
                using var document = JsonDocument.Parse(responseBody);
                if (document.RootElement.ValueKind != JsonValueKind.Object)
                {
                    return false;
                }

                foreach (var property in document.RootElement.EnumerateObject())
                {
                    if (property.NameEquals("success") ||
                        property.NameEquals("Success") ||
                        property.NameEquals("data") ||
                        property.NameEquals("Data") ||
                        property.NameEquals("items") ||
                        property.NameEquals("Items") ||
                        property.NameEquals("totalCount") ||
                        property.NameEquals("TotalCount") ||
                        property.NameEquals("message") ||
                        property.NameEquals("Message") ||
                        property.NameEquals("code") ||
                        property.NameEquals("Code"))
                    {
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "La respuesta no tiene el formato de un contrato API.");
            }

            return false;
        }

        private static string ExtractErrorMessage(string responseBody, HttpStatusCode statusCode)
        {
            if ((int)statusCode >= 500)
            {
                return UserFacingMessages.UnexpectedError;
            }

            if (!string.IsNullOrWhiteSpace(responseBody))
            {
                try
                {
                    using var document = JsonDocument.Parse(responseBody);
                    if (document.RootElement.TryGetProperty("message", out var message) ||
                        document.RootElement.TryGetProperty("Message", out message))
                    {
                        var value = message.GetString();
                        if (!string.IsNullOrWhiteSpace(value))
                        {
                            return value;
                        }
                    }
                }
                catch (JsonException)
                {
                    // Las respuestas no estructuradas nunca se muestran directamente al usuario.
                }
            }

            return statusCode switch
            {
                HttpStatusCode.BadRequest => "La informacion enviada no es valida. Revisa los datos e intenta nuevamente.",
                HttpStatusCode.Unauthorized => "Tu sesion ya no esta disponible. Inicia sesion nuevamente.",
                HttpStatusCode.Forbidden => "No tienes permisos para realizar esta operacion.",
                HttpStatusCode.NotFound => "La informacion solicitada ya no existe o no esta disponible.",
                HttpStatusCode.Conflict => "La operacion no puede completarse por el estado actual de la informacion.",
                HttpStatusCode.RequestTimeout => "La solicitud tardo demasiado. Intenta nuevamente.",
                HttpStatusCode.TooManyRequests => "Hay demasiadas solicitudes en curso. Espera un momento e intenta nuevamente.",
                _ => UserFacingMessages.OperationFailed("completar la solicitud")
            };
        }

        private void LogHttpFailure(HttpMethod method, string endpoint, HttpStatusCode statusCode, string responseBody)
        {
            if ((int)statusCode >= 500)
            {
                _logger.LogError(
                    "La API respondio {StatusCode} en {Method} {Endpoint}. Respuesta={ResponseBody}",
                    (int)statusCode,
                    method,
                    endpoint,
                    TruncateForLog(responseBody));
                return;
            }

            _logger.LogWarning(
                "La API respondio {StatusCode} en {Method} {Endpoint}. Respuesta={ResponseBody}",
                (int)statusCode,
                method,
                endpoint,
                TruncateForLog(responseBody));
        }

        private static string TruncateForLog(string value, int maxLength = 600)
        {
            if (string.IsNullOrEmpty(value) || value.Length <= maxLength)
            {
                return value;
            }

            return $"{value[..maxLength]}...";
        }

        private T? CreateErrorContract<T>(string message, ApiResponseCode code)
        {
            var type = typeof(T);
            if (type.IsValueType || type == typeof(string))
            {
                return default;
            }

            try
            {
                var result = Activator.CreateInstance<T>();
                EnsureErrorContract(result, message, code);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No fue posible crear el contrato de error {ResponseType}.", typeof(T).FullName);
                return default;
            }
        }

        private T? CreateSuccessContract<T>(string message)
        {
            var type = typeof(T);
            if (type.IsValueType || type == typeof(string))
            {
                return default;
            }

            try
            {
                var result = Activator.CreateInstance<T>();
                SetSuccessfulContract(type, result, message, 0);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No fue posible interpretar una respuesta de tipo {ResponseType}.", typeof(T).FullName);
                return default;
            }
        }

        private static void SetSuccessfulContract<T>(Type type, T result, string message, int totalCount)
        {
            if (result == null)
            {
                return;
            }

            SetProperty(type, result, "Success", true);

            var messageProperty = type.GetProperty("Message");
            if (messageProperty?.CanWrite == true && string.IsNullOrWhiteSpace(messageProperty.GetValue(result)?.ToString()))
            {
                messageProperty.SetValue(result, message);
            }

            var codeProperty = type.GetProperty("Code");
            var currentCode = codeProperty?.GetValue(result)?.ToString();
            if (codeProperty?.CanWrite == true &&
                (string.IsNullOrWhiteSpace(currentCode) ||
                 string.Equals(currentCode, ApiResponseCode.Error.ToCode(), StringComparison.OrdinalIgnoreCase)))
            {
                codeProperty.SetValue(result, ApiResponseCode.Success.ToCode());
            }

            SetProperty(type, result, "TotalCount", totalCount);
        }

        private static void EnsureErrorContract<T>(T result, string message, ApiResponseCode code)
        {
            if (result == null)
            {
                return;
            }

            var type = result.GetType();
            SetProperty(type, result, "Success", false);

            var messageProperty = type.GetProperty("Message");
            if (messageProperty?.CanWrite == true && string.IsNullOrWhiteSpace(messageProperty.GetValue(result)?.ToString()))
            {
                messageProperty.SetValue(result, message);
            }

            var codeProperty = type.GetProperty("Code");
            if (codeProperty?.CanWrite == true && string.IsNullOrWhiteSpace(codeProperty.GetValue(result)?.ToString()))
            {
                codeProperty.SetValue(result, code.ToCode());
            }

            SetProperty(type, result, "TotalCount", 0);
        }

        private static int GetTotalCount<T>(Type type, T result)
        {
            var totalCountProperty = type.GetProperty("TotalCount");
            if (totalCountProperty != null && totalCountProperty.GetValue(result) is int count)
            {
                return count;
            }

            var itemsProperty = type.GetProperty("Items");
            return itemsProperty?.GetValue(result) is System.Collections.ICollection items
                ? items.Count
                : 0;
        }

        private static void SetPropertyIfWritable<T>(Type type, T result, string propertyName, object? value)
        {
            var property = type.GetProperty(propertyName);
            if (property?.CanWrite == true)
            {
                property.SetValue(result, value);
            }
        }

        private static void SetProperty<T>(Type type, T result, string propertyName, object value)
        {
            var property = type.GetProperty(propertyName);
            if (property?.CanWrite == true)
            {
                property.SetValue(result, value);
            }
        }

        protected async Task<(bool Result, string Message)> ExecuteOperationAsync(
            Func<Task<(bool Result, string Message)>> operation)
        {
            try
            {
                if (!IsClientSide())
                    return (false, "No disponible en servidor");

                return await operation();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al ejecutar una operacion del cliente.");
                return (false, UserFacingMessages.UnexpectedError);
            }
        }
    }
}

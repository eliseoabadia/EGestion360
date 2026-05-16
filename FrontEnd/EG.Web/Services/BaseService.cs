using EG.Common.Enums;
using EG.Common.Helper;
using EG.Web.Helpers;
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

        public static readonly string TOKENKEY = "authToken";
        protected readonly JsonSerializerOptions _jsonOptions;

        public bool IsAuthenticated { get; protected set; } = false;

        protected BaseService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _application = application;
            _configuration = configuration;
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
                await ClearAuthDataAsync();
                return null;
            }

            rawToken = rawToken.Trim();
            if ((rawToken.StartsWith("\"") && rawToken.EndsWith("\"")) ||
                (rawToken.StartsWith("'") && rawToken.EndsWith("'")))
            {
                rawToken = rawToken.Substring(1, rawToken.Length - 2);
            }

            return rawToken.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
                ? rawToken.Substring("Bearer ".Length)
                : rawToken;
        }

        protected async Task ClearAuthDataAsync()
        {
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
            return request;
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
                var request = await CreateAuthenticatedRequestAsync(method, fullEndpoint);

                if (content != null)
                {
                    var json = JsonSerializer.Serialize(content, _jsonOptions);
                    request.Content = new StringContent(json, Encoding.UTF8, "application/json");
                }

                var response = await _httpClient.SendAsync(request);
                var responseBody = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    if (typeof(T) == typeof(bool))
                    {
                        if (bool.TryParse(responseBody, out bool boolResult))
                        {
                            return (T)(object)boolResult;
                        }
                    }

                    return DeserializeResponse<T>(responseBody);
                }

                var errorResult = DeserializeResponse<T>(responseBody);
                if (errorResult != null)
                {
                    EnsureErrorContract(errorResult, ExtractErrorMessage(responseBody, response.StatusCode), ApiResponseCode.Error);
                    return errorResult;
                }

                Console.WriteLine($"Error: {response.StatusCode} - {responseBody}");
                return CreateErrorContract<T>(ExtractErrorMessage(responseBody, response.StatusCode), ApiResponseCode.Error);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error en {method} {endpoint}: {ex.Message}");
                return CreateErrorContract<T>(ex.Message, ApiResponseCode.Error);
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
                var request = await CreateAuthenticatedRequestAsync(method, fullEndpoint);

                if (content != null)
                {
                    var json = JsonSerializer.Serialize(content, _jsonOptions);
                    request.Content = new StringContent(json, Encoding.UTF8, "application/json");
                }

                var response = await _httpClient.SendAsync(request);
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
            catch (Exception ex)
            {
                return (default, false, $"Excepcion: {ex.Message}");
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
            catch
            {
                return default;
            }
        }

        private static string ExtractErrorMessage(string responseBody, HttpStatusCode statusCode)
        {
            if (string.IsNullOrWhiteSpace(responseBody))
            {
                return $"Error {(int)statusCode}: {statusCode}";
            }

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
            catch
            {
            }

            return responseBody;
        }

        private static T? CreateErrorContract<T>(string message, ApiResponseCode code)
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
            catch
            {
                return default;
            }
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
                return (false, $"Error: {ex.Message}");
            }
        }
    }
}

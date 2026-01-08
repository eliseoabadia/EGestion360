using EG.Common.Helper;
using EG.Web.Helpers;
using Microsoft.JSInterop;
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

        public static readonly string TOKENKEY = "authToken";
        protected readonly JsonSerializerOptions _jsonOptions;

        public bool IsAuthenticated { get; protected set; } = false;

        protected BaseService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _application = application;
            _baseUrl = httpClient.BaseAddress?.ToString() ?? string.Empty;
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
                // fallback a extensión si existiera
                rawToken = await _jsRuntime.GetFromLocalStorage(TOKENKEY);
            }

            if (string.IsNullOrWhiteSpace(rawToken))
            {
                await ClearAuthDataAsync();
                return null;
            }

            // Normalizar token
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

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();

                    // Manejo especial para tipos de valor que no pueden ser null
                    if (typeof(T) == typeof(bool))
                    {
                        if (bool.TryParse(responseBody, out bool boolResult))
                        {
                            return (T)(object)boolResult;
                        }
                    }

                    return JsonSerializer.Deserialize<T>(responseBody, _jsonOptions);
                }

                Console.WriteLine($"Error: {response.StatusCode} - {await response.Content.ReadAsStringAsync()}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error en {method} {endpoint}: {ex.Message}");
            }

            // Retornar valor por defecto según el tipo
            if (typeof(T).IsValueType)
            {
                return default(T);
            }
            return default;
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

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    T? result;

                    // Manejo especial para tipos de valor
                    if (typeof(T) == typeof(bool))
                    {
                        if (bool.TryParse(responseBody, out bool boolResult))
                        {
                            result = (T)(object)boolResult;
                        }
                        else
                        {
                            result = default;
                        }
                    }
                    else
                    {
                        result = JsonSerializer.Deserialize<T>(responseBody, _jsonOptions);
                    }

                    return (result, true, "Operación exitosa");
                }

                var errorMessage = await response.Content.ReadAsStringAsync();
                return (default, false, $"Error {response.StatusCode}: {errorMessage}");
            }
            catch (Exception ex)
            {
                return (default, false, $"Excepción: {ex.Message}");
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
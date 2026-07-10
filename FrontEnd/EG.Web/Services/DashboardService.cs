using EG.Domain.DTOs.Responses.General;
using EG.Web.Models;
using Microsoft.JSInterop;
using System.Net.Http.Headers;
using System.Text.Json;

namespace EG.Web.Services
{
    public class DashboardService
    {
        private readonly HttpClient _httpClient;
        private readonly IJSRuntime _jsRuntime;
        private readonly JsonSerializerOptions _jsonOptions;
        private const string TOKENKEY = "authToken";
        private const string EMPRESA_KEY = "empresa_seleccionada";
        private const string EMPRESA_HEADER = "X-Empresa-Id";

        public DashboardService(HttpClient httpClient, IJSRuntime jsRuntime)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _jsonOptions = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        }

        public async Task<DashboardResumenResponse?> GetResumenAsync()
        {
            try
            {
                var token = await GetTokenAsync();
                var request = new HttpRequestMessage(HttpMethod.Get, "api/Dashboard");
                if (!string.IsNullOrEmpty(token))
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

                var empresaId = await GetSelectedEmpresaIdAsync();
                if (empresaId.HasValue)
                    request.Headers.Add(EMPRESA_HEADER, empresaId.Value.ToString());

                var response = await _httpClient.SendAsync(request);
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var result = JsonSerializer.Deserialize<ApiResponse<DashboardResumenResponse>>(json, _jsonOptions);
                    return result?.Data ?? result?.Items?.FirstOrDefault();
                }
            }
            catch
            {
            }
            return null;
        }

        private async Task<string?> GetTokenAsync()
        {
            try
            {
                var rawToken = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", TOKENKEY);
                if (string.IsNullOrWhiteSpace(rawToken))
                    return null;

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
            catch { return null; }
        }

        private async Task<int?> GetSelectedEmpresaIdAsync()
        {
            try
            {
                var empresaIdRaw = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", EMPRESA_KEY);
                return int.TryParse(empresaIdRaw, out var empresaId) && empresaId > 0
                    ? empresaId
                    : null;
            }
            catch { return null; }
        }
    }
}

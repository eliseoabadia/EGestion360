using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using EG.Common.Helper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Web.Contracts.Contabilidad;
using EG.Web.Models;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;

namespace EG.Web.Services.Contabilidad
{
    public class PolizaAiImportService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application)
        : BaseService(httpClient, jsRuntime, application, configuration), IPolizaAiImportService
    {
        private const long MaxClientFileSize = 50 * 1024 * 1024;
        private const string Endpoint = "api/Poliza";

        public async Task<ApiResponse<PolizaAiImportPreviewResponse>> PreviewAsync(PolizaAiImportHeaderRequest header, IBrowserFile file)
        {
            try
            {
                var httpRequest = await CreateAuthenticatedRequestAsync(HttpMethod.Post, $"{_baseUrl}{Endpoint}/ai-import/preview");
                using var form = new MultipartFormDataContent();

                AddString(form, "FkidEmpresaSis", header.FkidEmpresaSis?.ToString());
                AddString(form, "FkidAnioSis", header.FkidAnioSis?.ToString());
                AddString(form, "Anio", header.Anio?.ToString());
                AddString(form, "FkidMesSis", header.FkidMesSis?.ToString());
                AddString(form, "Mes", header.Mes);
                AddString(form, "FkidTipoPolizaSis", header.FkidTipoPolizaSis?.ToString());
                AddString(form, "TipoPoliza", header.TipoPoliza);
                AddString(form, "ClavePoliza", header.ClavePoliza);
                AddString(form, "NombrePoliza", header.NombrePoliza);
                AddString(form, "FechaPoliza", header.FechaPoliza?.ToString("O"));
                AddString(form, "PermitirModificar", header.PermitirModificar.ToString());
                AddString(form, "Autorizado", header.Autorizado.ToString());

                var fileContent = new StreamContent(file.OpenReadStream(MaxClientFileSize));
                fileContent.Headers.ContentType = new MediaTypeHeaderValue(string.IsNullOrWhiteSpace(file.ContentType)
                    ? "application/octet-stream"
                    : file.ContentType);
                form.Add(fileContent, "File", file.Name);
                httpRequest.Content = form;

                var response = await _httpClient.SendAsync(httpRequest);
                var body = await response.Content.ReadAsStringAsync();
                var result = JsonSerializer.Deserialize<ApiResponse<PolizaAiImportPreviewResponse>>(body, _jsonOptions)
                    ?? new ApiResponse<PolizaAiImportPreviewResponse>();

                if (!response.IsSuccessStatusCode)
                {
                    result.Success = false;
                    if (string.IsNullOrWhiteSpace(result.Message))
                        result.Message = body;
                }

                return result;
            }
            catch (Exception ex)
            {
                return new ApiResponse<PolizaAiImportPreviewResponse>
                {
                    Success = false,
                    Message = ex.Message
                };
            }
        }

        public async Task<ApiResponse<PolizaAiImportPreviewResponse>> ConfirmAsync(PolizaAiImportConfirmRequest request)
            => await PostAsync<ApiResponse<PolizaAiImportPreviewResponse>>($"{Endpoint}/ai-import/confirm", request, useBaseUrl: false)
                ?? new ApiResponse<PolizaAiImportPreviewResponse>();

        private static void AddString(MultipartFormDataContent form, string name, string? value)
        {
            if (!string.IsNullOrWhiteSpace(value))
                form.Add(new StringContent(value, Encoding.UTF8), name);
        }
    }
}

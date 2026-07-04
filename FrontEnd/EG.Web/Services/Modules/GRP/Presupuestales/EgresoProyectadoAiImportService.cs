using EG.Common.Helper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Web.Contracts.Modules.GRP.Presupuestales;
using EG.Web.Models;
using EG.Web.Services.Shared;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;

namespace EG.Web.Services.Modules.GRP.Presupuestales
{
    public class EgresoProyectadoAiImportService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application)
        : BaseService(httpClient, jsRuntime, application, configuration), IEgresoProyectadoAiImportService
    {
        private const long MaxClientFileSize = 50 * 1024 * 1024;
        private const string Endpoint = "api/EgresoProyectado";

        public async Task<ApiResponse<EgresoProyectadoAiImportPreviewResponse>> PreviewAsync(EgresoProyectadoAiImportHeaderRequest header, IBrowserFile file)
        {
            try
            {
                var httpRequest = await CreateAuthenticatedRequestAsync(HttpMethod.Post, $"{_baseUrl}{Endpoint}/ai-import/preview");
                using var form = new MultipartFormDataContent();

                MultipartApiHelper.AddString(form, "FkidAnioSis", header.FkidAnioSis?.ToString());
                MultipartApiHelper.AddString(form, "Anio", header.Anio?.ToString());
                MultipartApiHelper.AddString(form, "Fecha", header.Fecha?.ToString("O"));
                MultipartApiHelper.AddFile(form, "File", file, MaxClientFileSize);
                httpRequest.Content = form;

                return await MultipartApiHelper.SendAsync<EgresoProyectadoAiImportPreviewResponse>(_httpClient, httpRequest, _jsonOptions);
            }
            catch (Exception ex)
            {
                return MultipartApiHelper.Failure<EgresoProyectadoAiImportPreviewResponse>(ex);
            }
        }

        public async Task<ApiResponse<EgresoProyectadoAiImportPreviewResponse>> ConfirmAsync(EgresoProyectadoAiImportConfirmRequest request)
            => await PostAsync<ApiResponse<EgresoProyectadoAiImportPreviewResponse>>($"{Endpoint}/ai-import/confirm", request, useBaseUrl: false)
                ?? new ApiResponse<EgresoProyectadoAiImportPreviewResponse>();
    }
}

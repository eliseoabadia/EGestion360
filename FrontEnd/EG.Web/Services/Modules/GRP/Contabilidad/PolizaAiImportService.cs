using EG.Common.Helper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Web.Contracts.Modules.GRP.Contabilidad;
using EG.Web.Models;
using EG.Web.Services.Shared;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;

namespace EG.Web.Services.Modules.GRP.Contabilidad
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

                MultipartApiHelper.AddString(form, "FkidEmpresaSis", header.FkidEmpresaSis?.ToString());
                MultipartApiHelper.AddString(form, "FkidAnioSis", header.FkidAnioSis?.ToString());
                MultipartApiHelper.AddString(form, "Anio", header.Anio?.ToString());
                MultipartApiHelper.AddString(form, "FkidMesSis", header.FkidMesSis?.ToString());
                MultipartApiHelper.AddString(form, "Mes", header.Mes);
                MultipartApiHelper.AddString(form, "FkidTipoPolizaSis", header.FkidTipoPolizaSis?.ToString());
                MultipartApiHelper.AddString(form, "TipoPoliza", header.TipoPoliza);
                MultipartApiHelper.AddString(form, "ClavePoliza", header.ClavePoliza);
                MultipartApiHelper.AddString(form, "NombrePoliza", header.NombrePoliza);
                MultipartApiHelper.AddString(form, "FechaPoliza", header.FechaPoliza?.ToString("O"));
                MultipartApiHelper.AddString(form, "PermitirModificar", header.PermitirModificar.ToString());
                MultipartApiHelper.AddString(form, "Autorizado", header.Autorizado.ToString());
                MultipartApiHelper.AddFile(form, "File", file, MaxClientFileSize);
                httpRequest.Content = form;

                return await MultipartApiHelper.SendAsync<PolizaAiImportPreviewResponse>(_httpClient, httpRequest, _jsonOptions);
            }
            catch (Exception ex)
            {
                return MultipartApiHelper.Failure<PolizaAiImportPreviewResponse>(ex);
            }
        }

        public async Task<ApiResponse<PolizaAiImportPreviewResponse>> ConfirmAsync(PolizaAiImportConfirmRequest request)
            => await PostAsync<ApiResponse<PolizaAiImportPreviewResponse>>($"{Endpoint}/ai-import/confirm", request, useBaseUrl: false)
                ?? new ApiResponse<PolizaAiImportPreviewResponse>();

    }
}

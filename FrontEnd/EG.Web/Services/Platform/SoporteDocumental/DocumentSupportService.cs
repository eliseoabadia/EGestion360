using EG.Common.Helper;
using EG.Common;
using EG.Web.Contracts.Platform.SoporteDocumental;
using EG.Web.Models;
using EG.Web.Models.Platform.SoporteDocumental;
using EG.Web.Services.Shared;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;

namespace EG.Web.Services.Platform.SoporteDocumental
{
    public class DocumentSupportService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application,
        ILogger<DocumentSupportService> logger)
        : BaseService(httpClient, jsRuntime, application, configuration, logger), IDocumentSupportService
    {
        private const long MaxClientFileSize = 50 * 1024 * 1024;
        private const string Endpoint = "api/SoporteDocumental";

        public async Task<ApiResponse<DocumentoResponse>> GetDocumentsAsync(DocumentoEntidadRequest request)
            => await PostAsync<ApiResponse<DocumentoResponse>>($"{Endpoint}/entidad", request, useBaseUrl: false)
                ?? new ApiResponse<DocumentoResponse>();

        public async Task<ApiResponse<DocumentoResumenResponse>> GetSummaryAsync(DocumentoEntidadRequest request)
            => await PostAsync<ApiResponse<DocumentoResumenResponse>>($"{Endpoint}/resumen", request, useBaseUrl: false)
                ?? new ApiResponse<DocumentoResumenResponse>();

        public async Task<ApiResponse<DocumentoResponse>> UploadAsync(DocumentoEntidadRequest request, IBrowserFile file, string? title, string? description)
        {
            try
            {
                var httpRequest = await CreateAuthenticatedRequestAsync(HttpMethod.Post, $"{_baseUrl}{Endpoint}/upload");
                using var form = new MultipartFormDataContent();
                MultipartApiHelper.AddString(form, "Modulo", request.Modulo);
                MultipartApiHelper.AddString(form, "SubModulo", request.SubModulo);
                MultipartApiHelper.AddString(form, "Controlador", request.Controlador);
                MultipartApiHelper.AddString(form, "Servicio", request.Servicio);
                MultipartApiHelper.AddString(form, "EntidadId", request.EntidadId.ToString());
                MultipartApiHelper.AddString(form, "FkidEmpresaSis", request.FkidEmpresaSis?.ToString());
                MultipartApiHelper.AddString(form, "Titulo", title);
                MultipartApiHelper.AddString(form, "Descripcion", description);
                MultipartApiHelper.AddFile(form, "File", file, MaxClientFileSize);
                httpRequest.Content = form;

                return await MultipartApiHelper.SendAsync<DocumentoResponse>(_httpClient, httpRequest, _jsonOptions, _logger);
            }
            catch (Exception ex)
            {
                return MultipartApiHelper.Failure<DocumentoResponse>(ex, _logger);
            }
        }

        public async Task<DocumentoDownloadResult> DownloadAsync(long documentId)
        {
            try
            {
                var request = await CreateAuthenticatedRequestAsync(HttpMethod.Get, $"{_baseUrl}{Endpoint}/{documentId}/download");
                var response = await _httpClient.SendAsync(request);
                if (!response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    _logger.LogWarning(
                        "Descarga documental rechazada. DocumentId={DocumentId}; Status={StatusCode}; Response={Response}",
                        documentId,
                        (int)response.StatusCode,
                        responseBody.Length <= 2000 ? responseBody : $"{responseBody[..2000]}...");
                    return new DocumentoDownloadResult
                    {
                        Success = false,
                        Message = (int)response.StatusCode >= 500
                            ? UserFacingMessages.UnexpectedError
                            : UserFacingMessageSanitizer.SafeOrFallback(
                                responseBody,
                                "No fue posible descargar el documento. Verifica que exista y que tengas permiso.")
                    };
                }

                var content = await response.Content.ReadAsByteArrayAsync();
                var fileName = response.Content.Headers.ContentDisposition?.FileNameStar
                    ?? response.Content.Headers.ContentDisposition?.FileName?.Trim('"')
                    ?? $"documento_{documentId}";

                return new DocumentoDownloadResult
                {
                    Success = true,
                    Content = content,
                    FileName = fileName,
                    ContentType = response.Content.Headers.ContentType?.MediaType ?? "application/octet-stream"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "No se pudo descargar el documento {DocumentId}.", documentId);
                return new DocumentoDownloadResult
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("descargar el documento")
                };
            }
        }

        public async Task<ApiResponse<bool>> DeleteAsync(long documentId)
            => await DeleteAsync<ApiResponse<bool>>($"{Endpoint}/{documentId}", useBaseUrl: false)
                ?? new ApiResponse<bool>();

        public async Task<ApiResponse<DocumentoAnotacionResponse>> GetAnnotationsAsync(long documentId)
            => await GetAsync<ApiResponse<DocumentoAnotacionResponse>>($"{Endpoint}/{documentId}/anotaciones", useBaseUrl: false)
                ?? new ApiResponse<DocumentoAnotacionResponse>();

        public async Task<ApiResponse<DocumentoAnotacionResponse>> CreateAnnotationAsync(DocumentoAnotacionCrearRequest request)
            => await PostAsync<ApiResponse<DocumentoAnotacionResponse>>($"{Endpoint}/anotaciones", request, useBaseUrl: false)
                ?? new ApiResponse<DocumentoAnotacionResponse>();

        public async Task<ApiResponse<bool>> DeleteAnnotationAsync(long annotationId)
            => await DeleteAsync<ApiResponse<bool>>($"{Endpoint}/anotaciones/{annotationId}", useBaseUrl: false)
                ?? new ApiResponse<bool>();

    }
}

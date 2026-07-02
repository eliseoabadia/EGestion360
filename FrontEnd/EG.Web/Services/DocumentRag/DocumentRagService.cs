using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using EG.Common.Helper;
using EG.Web.Contracts.DocumentRag;
using EG.Web.Models;
using EG.Web.Models.DocumentRag;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;

namespace EG.Web.Services.DocumentRag
{
    public class DocumentRagService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application)
        : BaseService(httpClient, jsRuntime, application, configuration), IDocumentRagService
    {
        private const long MaxClientFileSize = 50 * 1024 * 1024;
        private const string Endpoint = "api/DocumentRag";

        public async Task<ApiResponse<DocumentRagSessionResponse>> CreateSessionAsync(DocumentRagSessionRequest request)
            => await PostAsync<ApiResponse<DocumentRagSessionResponse>>($"{Endpoint}/sessions", request, useBaseUrl: false)
                ?? new ApiResponse<DocumentRagSessionResponse>();

        public async Task<ApiResponse<DocumentRagSessionResponse>> GetSessionAsync(Guid sessionId)
            => await GetAsync<ApiResponse<DocumentRagSessionResponse>>($"{Endpoint}/sessions/{sessionId}", useBaseUrl: false)
                ?? new ApiResponse<DocumentRagSessionResponse>();

        public async Task<ApiResponse<DocumentRagDocumentResponse>> UploadAsync(
            DocumentRagSessionRequest request,
            Guid sessionId,
            IBrowserFile file)
        {
            try
            {
                var httpRequest = await CreateAuthenticatedRequestAsync(HttpMethod.Post, $"{_baseUrl}{Endpoint}/documents");
                using var form = new MultipartFormDataContent();
                AddString(form, "SessionId", sessionId.ToString());
                AddString(form, "Modulo", request.Modulo);
                AddString(form, "SubModulo", request.SubModulo);
                AddString(form, "Controlador", request.Controlador);
                AddString(form, "Servicio", request.Servicio);
                AddString(form, "EntidadId", request.EntidadId?.ToString());
                AddString(form, "FkidEmpresaSis", request.FkidEmpresaSis?.ToString());
                AddString(form, "Titulo", request.Titulo);
                AddString(form, "Descripcion", request.Descripcion);

                var fileContent = new StreamContent(file.OpenReadStream(MaxClientFileSize));
                fileContent.Headers.ContentType = new MediaTypeHeaderValue(string.IsNullOrWhiteSpace(file.ContentType)
                    ? "application/octet-stream"
                    : file.ContentType);
                form.Add(fileContent, "File", file.Name);
                httpRequest.Content = form;

                var response = await _httpClient.SendAsync(httpRequest);
                var body = await response.Content.ReadAsStringAsync();
                var result = JsonSerializer.Deserialize<ApiResponse<DocumentRagDocumentResponse>>(body, _jsonOptions)
                    ?? new ApiResponse<DocumentRagDocumentResponse>();

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
                return new ApiResponse<DocumentRagDocumentResponse>
                {
                    Success = false,
                    Message = ex.Message
                };
            }
        }

        public async Task<ApiResponse<DocumentRagAskResponse>> AskAsync(DocumentRagAskRequest request)
            => await PostAsync<ApiResponse<DocumentRagAskResponse>>($"{Endpoint}/ask", request, useBaseUrl: false)
                ?? new ApiResponse<DocumentRagAskResponse>();

        public async Task<ApiResponse<DocumentRagHistoryItemResponse>> GetHistoryAsync(Guid sessionId)
            => await GetAsync<ApiResponse<DocumentRagHistoryItemResponse>>($"{Endpoint}/sessions/{sessionId}/history", useBaseUrl: false)
                ?? new ApiResponse<DocumentRagHistoryItemResponse>();

        public async Task<ApiResponse<bool>> ReleaseSessionAsync(Guid sessionId)
            => await DeleteAsync<ApiResponse<bool>>($"{Endpoint}/sessions/{sessionId}", useBaseUrl: false)
                ?? new ApiResponse<bool>();

        private static void AddString(MultipartFormDataContent form, string name, string? value)
        {
            if (!string.IsNullOrWhiteSpace(value))
                form.Add(new StringContent(value, Encoding.UTF8), name);
        }
    }
}

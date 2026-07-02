using EG.Common.Helper;
using EG.Web.Contracts.Platform.DocumentRag;
using EG.Web.Models;
using EG.Web.Models.Platform.DocumentRag;
using EG.Web.Services.Shared;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;

namespace EG.Web.Services.Platform.DocumentRag
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
                MultipartApiHelper.AddString(form, "SessionId", sessionId.ToString());
                MultipartApiHelper.AddString(form, "Modulo", request.Modulo);
                MultipartApiHelper.AddString(form, "SubModulo", request.SubModulo);
                MultipartApiHelper.AddString(form, "Controlador", request.Controlador);
                MultipartApiHelper.AddString(form, "Servicio", request.Servicio);
                MultipartApiHelper.AddString(form, "EntidadId", request.EntidadId?.ToString());
                MultipartApiHelper.AddString(form, "FkidEmpresaSis", request.FkidEmpresaSis?.ToString());
                MultipartApiHelper.AddString(form, "Titulo", request.Titulo);
                MultipartApiHelper.AddString(form, "Descripcion", request.Descripcion);
                MultipartApiHelper.AddFile(form, "File", file, MaxClientFileSize);
                httpRequest.Content = form;

                return await MultipartApiHelper.SendAsync<DocumentRagDocumentResponse>(_httpClient, httpRequest, _jsonOptions);
            }
            catch (Exception ex)
            {
                return MultipartApiHelper.Failure<DocumentRagDocumentResponse>(ex);
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

    }
}

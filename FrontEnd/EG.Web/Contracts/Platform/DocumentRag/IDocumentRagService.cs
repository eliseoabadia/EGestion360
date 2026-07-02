using EG.Web.Models;
using EG.Web.Models.Platform.DocumentRag;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Contracts.Platform.DocumentRag
{
    public interface IDocumentRagService
    {
        Task<ApiResponse<DocumentRagSessionResponse>> CreateSessionAsync(DocumentRagSessionRequest request);
        Task<ApiResponse<DocumentRagSessionResponse>> GetSessionAsync(Guid sessionId);
        Task<ApiResponse<DocumentRagDocumentResponse>> UploadAsync(DocumentRagSessionRequest request, Guid sessionId, IBrowserFile file);
        Task<ApiResponse<DocumentRagAskResponse>> AskAsync(DocumentRagAskRequest request);
        Task<ApiResponse<DocumentRagHistoryItemResponse>> GetHistoryAsync(Guid sessionId);
        Task<ApiResponse<bool>> ReleaseSessionAsync(Guid sessionId);
    }
}

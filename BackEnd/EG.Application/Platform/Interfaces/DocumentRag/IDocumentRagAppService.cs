using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.DocumentRag;
using EG.Domain.DTOs.Responses.DocumentRag;

namespace EG.Application.Interfaces.DocumentRag
{
    public interface IDocumentRagAppService
    {
        Task<PagedResult<DocumentRagSessionResponse>> CreateSessionAsync(DocumentRagSessionRequest request, int usuarioActual);
        Task<PagedResult<DocumentRagSessionResponse>> GetSessionAsync(Guid sessionId, int usuarioActual);
        Task<PagedResult<DocumentRagDocumentResponse>> UploadAsync(DocumentRagUploadRequest request, int usuarioActual);
        Task<PagedResult<DocumentRagAskResponse>> AskAsync(DocumentRagAskRequest request, int usuarioActual);
        Task<PagedResult<DocumentRagHistoryItemResponse>> GetHistoryAsync(Guid sessionId, int usuarioActual);
        Task<PagedResult<bool>> ReleaseSessionAsync(Guid sessionId, int usuarioActual);
    }
}

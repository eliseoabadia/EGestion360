using EG.Web.Models;
using EG.Web.Models.SoporteDocumental;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Contracts.SoporteDocumental
{
    public interface IDocumentSupportService
    {
        Task<ApiResponse<DocumentoResponse>> GetDocumentsAsync(DocumentoEntidadRequest request);
        Task<ApiResponse<DocumentoResumenResponse>> GetSummaryAsync(DocumentoEntidadRequest request);
        Task<ApiResponse<DocumentoResponse>> UploadAsync(DocumentoEntidadRequest request, IBrowserFile file, string? title, string? description);
        Task<DocumentoDownloadResult> DownloadAsync(long documentId);
        Task<ApiResponse<bool>> DeleteAsync(long documentId);
        Task<ApiResponse<DocumentoAnotacionResponse>> GetAnnotationsAsync(long documentId);
        Task<ApiResponse<DocumentoAnotacionResponse>> CreateAnnotationAsync(DocumentoAnotacionCrearRequest request);
        Task<ApiResponse<bool>> DeleteAnnotationAsync(long annotationId);
    }
}

using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Web.Models;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Contracts.Modules.GRP.Contabilidad
{
    public interface IPolizaAiImportService
    {
        Task<ApiResponse<PolizaAiImportPreviewResponse>> PreviewAsync(PolizaAiImportHeaderRequest header, IBrowserFile file);
        Task<ApiResponse<PolizaAiImportPreviewResponse>> ConfirmAsync(PolizaAiImportConfirmRequest request);
    }
}

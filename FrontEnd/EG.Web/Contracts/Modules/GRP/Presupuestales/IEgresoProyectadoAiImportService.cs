using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Web.Models;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Contracts.Modules.GRP.Presupuestales
{
    public interface IEgresoProyectadoAiImportService
    {
        Task<ApiResponse<EgresoProyectadoAiImportPreviewResponse>> PreviewAsync(EgresoProyectadoAiImportHeaderRequest header, IBrowserFile file);
        Task<ApiResponse<EgresoProyectadoAiImportPreviewResponse>> ConfirmAsync(EgresoProyectadoAiImportConfirmRequest request);
    }
}

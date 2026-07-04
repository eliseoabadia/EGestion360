using EG.Domain.DTOs.Responses.General;
using EG.Web.Models;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Contracts.Configuration
{
    public interface IEmpresaLogoService
    {
        Task<ApiResponse<EmpresaResponse>> UploadAsync(int empresaId, IBrowserFile file);
    }
}

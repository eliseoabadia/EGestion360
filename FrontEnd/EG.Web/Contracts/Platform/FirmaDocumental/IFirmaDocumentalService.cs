using EG.Web.Models;
using EG.Web.Models.Platform.FirmaDocumental;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Contracts.Platform.FirmaDocumental
{
    public interface IFirmaDocumentalService
    {
        Task<ApiResponse<FirmaProveedorResponse>> GetProvidersAsync();
        Task<ApiResponse<FirmaCertificadoUsuarioResponse>> GetCertificatesAsync(int? empresaId = null);
        Task<ApiResponse<FirmaCertificadoUsuarioResponse>> UploadCertificateAsync(string alias, string password, int? empresaId, IBrowserFile file);
    }
}

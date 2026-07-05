using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.FirmaDocumental;
using EG.Domain.DTOs.Responses.FirmaDocumental;

namespace EG.Application.Interfaces.FirmaDocumental
{
    public interface IFirmaDocumentalAppService
    {
        Task<PagedResult<FirmaProveedorResponse>> ObtenerProveedoresAsync();
        Task<PagedResult<FirmaCertificadoUsuarioResponse>> RegistrarCertificadoAsync(FirmaCertificadoUsuarioUploadRequest request, int usuarioActual);
        Task<PagedResult<FirmaCertificadoUsuarioResponse>> ObtenerCertificadosAsync(int usuarioActual, int? empresaId);
        Task<PagedResult<FirmaDocumentoResponse>> FirmarDocumentoAsync(FirmaDocumentoCrearRequest request, int usuarioActual);
        Task<PagedResult<FirmaDocumentoResponse>> ObtenerFirmasAsync(FirmaDocumentoEntidadRequest request, int usuarioActual);
    }
}

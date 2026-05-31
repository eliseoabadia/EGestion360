using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;

namespace EG.Application.Interfaces.SoporteDocumental
{
    public interface ISoporteDocumentalAppService
    {
        Task<PagedResult<DocumentoResponse>> ObtenerPorEntidadAsync(DocumentoEntidadRequest request);
        Task<PagedResult<DocumentoResumenResponse>> ObtenerResumenAsync(DocumentoEntidadRequest request);
        Task<PagedResult<DocumentoResponse>> GuardarAsync(DocumentoUploadRequest request, int usuarioActual);
        Task<DocumentoDownloadResponse?> ObtenerContenidoAsync(long documentoId);
        Task<PagedResult<bool>> EliminarAsync(long documentoId, int usuarioActual);
        Task<PagedResult<DocumentoAnotacionResponse>> ObtenerAnotacionesAsync(long documentoId, bool incluirInactivos = false);
        Task<PagedResult<DocumentoAnotacionResponse>> CrearAnotacionAsync(DocumentoAnotacionCrearRequest request, int usuarioActual);
        Task<PagedResult<bool>> EliminarAnotacionAsync(long anotacionId, int usuarioActual);
    }
}

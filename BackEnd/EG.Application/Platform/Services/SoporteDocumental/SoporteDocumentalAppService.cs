using EG.Application.Interfaces.SoporteDocumental;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.Domain.Interfaces;

namespace EG.Application.Services.SoporteDocumental;

public sealed class SoporteDocumentalAppService(
    ISoporteDocumentalService service,
    IUserContextService userContext) : ISoporteDocumentalAppService
{
    public Task<PagedResult<DocumentoResponse>> ObtenerPorEntidadAsync(DocumentoEntidadRequest request)
    {
        request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
        return service.ObtenerPorEntidadAsync(request);
    }

    public Task<PagedResult<DocumentoResumenResponse>> ObtenerResumenAsync(DocumentoEntidadRequest request)
    {
        request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
        return service.ObtenerResumenAsync(request);
    }

    public Task<PagedResult<DocumentoResponse>> GuardarAsync(DocumentoUploadRequest request, int usuarioActual)
    {
        request.FkidEmpresaSis = userContext.GetCurrentEmpresaId();
        return service.GuardarAsync(request, userContext.GetCurrentUserId());
    }

    public Task<DocumentoDownloadResponse?> ObtenerContenidoAsync(long documentoId, int empresaId) =>
        service.ObtenerContenidoAsync(documentoId, userContext.GetCurrentEmpresaId());

    public Task<PagedResult<bool>> EliminarAsync(long documentoId, int usuarioActual, int empresaId) =>
        service.EliminarAsync(documentoId, userContext.GetCurrentUserId(), userContext.GetCurrentEmpresaId());

    public Task<PagedResult<DocumentoAnotacionResponse>> ObtenerAnotacionesAsync(long documentoId, int empresaId, bool incluirInactivos = false) =>
        service.ObtenerAnotacionesAsync(documentoId, userContext.GetCurrentEmpresaId(), incluirInactivos);

    public Task<PagedResult<DocumentoAnotacionResponse>> CrearAnotacionAsync(DocumentoAnotacionCrearRequest request, int usuarioActual, int empresaId) =>
        service.CrearAnotacionAsync(request, userContext.GetCurrentUserId(), userContext.GetCurrentEmpresaId());

    public Task<PagedResult<bool>> EliminarAnotacionAsync(long anotacionId, int usuarioActual, int empresaId) =>
        service.EliminarAnotacionAsync(anotacionId, userContext.GetCurrentUserId(), userContext.GetCurrentEmpresaId());
}

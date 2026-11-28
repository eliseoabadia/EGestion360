using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IEstudioMercadoDetalleOperations
{
    Task<PagedResult<EstudioMercadoDetalleResponse>> GetAllAsync();
    Task<PagedResult<EstudioMercadoDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<EstudioMercadoDetalleResponse>> CreateAsync(EstudioMercadoDetalleResponse response, int usuarioActual);
    Task<PagedResult<EstudioMercadoDetalleResponse>> UpdateAsync(int id, EstudioMercadoDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<EstudioMercadoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    Task<PagedResult<LookupItem>> GetPaaasLookupAsync(PagedRequest request);
    Task<PagedResult<EstudioMercadoPaaasDetalleResponse>> GetPaaasDetallesAsync(PagedRequest request);
    Task<PagedResult<LookupItem>> GetPaaasDetallesLookupAsync(PagedRequest request);
    Task<PagedResult<EstudioMercadoDetalleSeedResponse>> GetPaaasDetalleSeedAsync(int paaaseDetalleId);
    Task<PagedResult<EstudioMercadoDetalleResponse>> CreateBatchAsync(EstudioMercadoDetalleBatchRequest request, int usuarioActual);
    Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> CreateSolicitudesCotizacionAsync(EstudioMercadoCotizacionRequest request, int usuarioActual);
    Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> GetSolicitudesCotizacionAsync(int estudioMercadoId);
    Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> SendSolicitudesCotizacionEmailAsync(
            int estudioMercadoId,
            int? estudioMercadoDetalleId,
            int usuarioActual);
    Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> RejectSolicitudesCotizacionEmailAsync(
            int estudioMercadoId,
            int? estudioMercadoDetalleId,
            int usuarioActual,
            string? motivo);
    Task<PagedResult<EstudioMercadoCotizacionRecepcionResponse>> GetRecepcionCotizacionesAsync(int estudioMercadoId, int? proveedorId);
    Task<PagedResult<EstudioMercadoCotizacionRecepcionResponse>> SaveRecepcionCotizacionesAsync(EstudioMercadoCotizacionRecepcionRequest request, int usuarioActual);
}

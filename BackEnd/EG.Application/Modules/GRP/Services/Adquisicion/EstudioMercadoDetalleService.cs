using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class EstudioMercadoDetalleService(IEstudioMercadoDetalleOperations service) : IEstudioMercadoDetalleService
{
    public Task<PagedResult<EstudioMercadoDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EstudioMercadoDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EstudioMercadoDetalleResponse>> CreateAsync(EstudioMercadoDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EstudioMercadoDetalleResponse>> UpdateAsync(int id, EstudioMercadoDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EstudioMercadoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public Task<PagedResult<LookupItem>> GetPaaasLookupAsync(PagedRequest request) => service.GetPaaasLookupAsync(request);
    public Task<PagedResult<EstudioMercadoPaaasDetalleResponse>> GetPaaasDetallesAsync(PagedRequest request) => service.GetPaaasDetallesAsync(request);
    public Task<PagedResult<LookupItem>> GetPaaasDetallesLookupAsync(PagedRequest request) => service.GetPaaasDetallesLookupAsync(request);
    public Task<PagedResult<EstudioMercadoDetalleSeedResponse>> GetPaaasDetalleSeedAsync(int paaaseDetalleId) => service.GetPaaasDetalleSeedAsync(paaaseDetalleId);
    public Task<PagedResult<EstudioMercadoDetalleResponse>> CreateBatchAsync(EstudioMercadoDetalleBatchRequest request, int usuarioActual) => service.CreateBatchAsync(request, usuarioActual);
    public Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> CreateSolicitudesCotizacionAsync(EstudioMercadoCotizacionRequest request, int usuarioActual) => service.CreateSolicitudesCotizacionAsync(request, usuarioActual);
    public Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> GetSolicitudesCotizacionAsync(int estudioMercadoId) => service.GetSolicitudesCotizacionAsync(estudioMercadoId);
    public Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> SendSolicitudesCotizacionEmailAsync( int estudioMercadoId, int? estudioMercadoDetalleId, int usuarioActual) => service.SendSolicitudesCotizacionEmailAsync(estudioMercadoId, estudioMercadoDetalleId, usuarioActual);
    public Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> RejectSolicitudesCotizacionEmailAsync( int estudioMercadoId, int? estudioMercadoDetalleId, int usuarioActual, string? motivo) => service.RejectSolicitudesCotizacionEmailAsync(estudioMercadoId, estudioMercadoDetalleId, usuarioActual, motivo);
    public Task<PagedResult<EstudioMercadoCotizacionRecepcionResponse>> GetRecepcionCotizacionesAsync(int estudioMercadoId, int? proveedorId) => service.GetRecepcionCotizacionesAsync(estudioMercadoId, proveedorId);
    public Task<PagedResult<EstudioMercadoCotizacionRecepcionResponse>> SaveRecepcionCotizacionesAsync(EstudioMercadoCotizacionRecepcionRequest request, int usuarioActual) => service.SaveRecepcionCotizacionesAsync(request, usuarioActual);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Requests.Adquisicion;

namespace EG.Business.Interfaces;

public interface ICotizacionOperations
{
    Task<PagedResult<CotizacionResponse>> GetAllAsync();
    Task<PagedResult<CotizacionResponse>> GetByIdAsync(int id);
    Task<PagedResult<CotizacionResponse>> CreateAsync(CotizacionResponse response, int usuarioActual);
    Task<PagedResult<CotizacionResponse>> UpdateAsync(int id, CotizacionResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<CotizacionResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<CotizacionResponse>> SendCotizacionEmailAsync(int cotizacionId, int usuarioActual);
    Task<PagedResult<CotizacionResponse>> RejectCotizacionEmailAsync(int cotizacionId, int usuarioActual, string? motivo);
    Task<PagedResult<CotizacionDetalleResponse>> GetRecepcionCotizacionAsync(int cotizacionId);
    Task<PagedResult<CotizacionDetalleResponse>> SaveRecepcionCotizacionAsync(CotizacionRecepcionRequest request, int usuarioActual);
}

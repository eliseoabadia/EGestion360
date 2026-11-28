using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface ICotizacionDetalleOperations
{
    Task<PagedResult<CotizacionDetalleResponse>> GetAllAsync();
    Task<PagedResult<CotizacionDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<CotizacionDetalleResponse>> CreateAsync(CotizacionDetalleResponse response, int usuarioActual);
    Task<PagedResult<CotizacionDetalleResponse>> UpdateAsync(int id, CotizacionDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<CotizacionDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
}

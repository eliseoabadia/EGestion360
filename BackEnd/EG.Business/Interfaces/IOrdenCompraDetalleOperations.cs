using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IOrdenCompraDetalleOperations
{
    Task<PagedResult<OrdenCompraDetalleResponse>> GetAllAsync();
    Task<PagedResult<OrdenCompraDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<OrdenCompraDetalleResponse>> CreateAsync(OrdenCompraDetalleResponse response, int usuarioActual);
    Task<PagedResult<OrdenCompraDetalleResponse>> UpdateAsync(int id, OrdenCompraDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<OrdenCompraDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
}

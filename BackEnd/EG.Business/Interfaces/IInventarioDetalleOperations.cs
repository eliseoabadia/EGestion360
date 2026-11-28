using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IInventarioDetalleOperations
{
    Task<PagedResult<InventarioDetalleResponse>> GetAllAsync();
    Task<PagedResult<InventarioDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<InventarioDetalleResponse>> CreateAsync(InventarioDetalleResponse response, int usuarioActual);
    Task<PagedResult<InventarioDetalleResponse>> UpdateAsync(int id, InventarioDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<InventarioDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
}

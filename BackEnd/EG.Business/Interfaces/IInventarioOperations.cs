using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IInventarioOperations
{
    Task<PagedResult<InventarioResponse>> GetAllAsync();
    Task<PagedResult<InventarioResponse>> GetByIdAsync(int id);
    Task<PagedResult<InventarioResponse>> CreateAsync(InventarioResponse response, int usuarioActual);
    Task<PagedResult<InventarioResponse>> UpdateAsync(int id, InventarioResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<InventarioResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<EG.Common.GenericModel.PagedResult<InventarioResponse>> AutorizarAsync(int id, int usuarioActual);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IOrdenCompraOperations
{
    Task<PagedResult<OrdenCompraResponse>> GetAllAsync();
    Task<PagedResult<OrdenCompraResponse>> GetByIdAsync(int id);
    Task<PagedResult<OrdenCompraResponse>> CreateAsync(OrdenCompraResponse response, int usuarioActual);
    Task<PagedResult<OrdenCompraResponse>> UpdateAsync(int id, OrdenCompraResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<OrdenCompraResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<OrdenCompraResponse>> AutorizarAsync(int id, int usuarioActual);
}

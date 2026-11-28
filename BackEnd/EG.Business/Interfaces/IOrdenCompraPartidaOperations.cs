using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IOrdenCompraPartidaOperations
{
    Task<PagedResult<OrdenCompraPartidaResponse>> GetAllAsync();
    Task<PagedResult<OrdenCompraPartidaResponse>> GetByIdAsync(int id);
    Task<PagedResult<OrdenCompraPartidaResponse>> CreateAsync(OrdenCompraPartidaResponse response, int usuarioActual);
    Task<PagedResult<OrdenCompraPartidaResponse>> UpdateAsync(int id, OrdenCompraPartidaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<OrdenCompraPartidaResponse>> GetAllPaginadoAsync(PagedRequest request);
}

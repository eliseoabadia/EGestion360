using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IEstudioMercadoOperations
{
    Task<PagedResult<EstudioMercadoResponse>> GetAllAsync();
    Task<PagedResult<EstudioMercadoResponse>> GetByIdAsync(int id);
    Task<PagedResult<EstudioMercadoResponse>> CreateAsync(EstudioMercadoResponse response, int usuarioActual);
    Task<PagedResult<EstudioMercadoResponse>> UpdateAsync(int id, EstudioMercadoResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<EstudioMercadoResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
}

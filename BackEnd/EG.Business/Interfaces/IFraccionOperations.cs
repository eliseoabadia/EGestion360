using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IFraccionOperations
{
    Task<PagedResult<FraccionResponse>> GetAllAsync();
    Task<PagedResult<FraccionResponse>> GetByIdAsync(int id);
    Task<PagedResult<FraccionResponse>> CreateAsync(FraccionResponse response, int usuarioActual);
    Task<PagedResult<FraccionResponse>> UpdateAsync(int id, FraccionResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<FraccionResponse>> GetAllPaginadoAsync(PagedRequest request);
}

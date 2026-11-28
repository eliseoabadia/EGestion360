using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IEstatusInventarioOperations
{
    Task<PagedResult<EstatusInventarioResponse>> GetAllAsync();
    Task<PagedResult<EstatusInventarioResponse>> GetByIdAsync(int id);
    Task<PagedResult<EstatusInventarioResponse>> CreateAsync(EstatusInventarioResponse response, int usuarioActual);
    Task<PagedResult<EstatusInventarioResponse>> UpdateAsync(int id, EstatusInventarioResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<EstatusInventarioResponse>> GetAllPaginadoAsync(PagedRequest request);
}

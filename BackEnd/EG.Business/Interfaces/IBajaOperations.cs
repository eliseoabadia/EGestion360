using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IBajaOperations
{
    Task<PagedResult<BajaResponse>> GetAllAsync();
    Task<PagedResult<BajaResponse>> GetByIdAsync(int id);
    Task<PagedResult<BajaResponse>> CreateAsync(BajaResponse response, int usuarioActual);
    Task<PagedResult<BajaResponse>> UpdateAsync(int id, BajaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<BajaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<EG.Common.GenericModel.PagedResult<BajaResponse>> AplicarAsync(int id, int fkidAnioSis, int usuarioActual);
}

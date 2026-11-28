using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface ITipoBajaOperations
{
    Task<PagedResult<TipoBajaResponse>> GetAllAsync();
    Task<PagedResult<TipoBajaResponse>> GetByIdAsync(int id);
    Task<PagedResult<TipoBajaResponse>> CreateAsync(TipoBajaResponse response, int usuarioActual);
    Task<PagedResult<TipoBajaResponse>> UpdateAsync(int id, TipoBajaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<TipoBajaResponse>> GetAllPaginadoAsync(PagedRequest request);
}

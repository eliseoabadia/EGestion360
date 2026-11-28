using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IResguardoOperations
{
    Task<PagedResult<ResguardoResponse>> GetAllAsync();
    Task<PagedResult<ResguardoResponse>> GetByIdAsync(int id);
    Task<PagedResult<ResguardoResponse>> CreateAsync(ResguardoResponse response, int usuarioActual);
    Task<PagedResult<ResguardoResponse>> UpdateAsync(int id, ResguardoResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<ResguardoResponse>> GetAllPaginadoAsync(PagedRequest request);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IEstatusBajaOperations
{
    Task<PagedResult<EstatusBajaResponse>> GetAllAsync();
    Task<PagedResult<EstatusBajaResponse>> GetByIdAsync(int id);
    Task<PagedResult<EstatusBajaResponse>> CreateAsync(EstatusBajaResponse response, int usuarioActual);
    Task<PagedResult<EstatusBajaResponse>> UpdateAsync(int id, EstatusBajaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<EstatusBajaResponse>> GetAllPaginadoAsync(PagedRequest request);
}

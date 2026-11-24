using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio;

public interface IResguardoMovimientoAppService
{
    Task<PagedResult<ResguardoMovimientoResponse>> GetAllAsync();
    Task<PagedResult<ResguardoMovimientoResponse>> GetByIdAsync(int id);
    Task<PagedResult<ResguardoMovimientoResponse>> GetAllPaginadoAsync(PagedRequest request);
}

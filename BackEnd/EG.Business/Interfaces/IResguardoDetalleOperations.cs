using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IResguardoDetalleOperations
{
    Task<PagedResult<ResguardoDetalleResponse>> GetAllAsync();
    Task<PagedResult<ResguardoDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<ResguardoDetalleResponse>> CreateAsync(ResguardoDetalleResponse response, int usuarioActual);
    Task<PagedResult<ResguardoDetalleResponse>> UpdateAsync(int id, ResguardoDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<ResguardoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
}

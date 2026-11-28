using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Business.Interfaces;

public interface IPolizaDetalleOperations
{
    Task<PagedResult<PolizaDetalleResponse>> GetAllAsync();
    Task<PagedResult<PolizaDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<PolizaDetalleResponse>> CreateAsync(PolizaDetalleResponse response, int usuarioActual);
    Task<PagedResult<PolizaDetalleResponse>> UpdateAsync(int id, PolizaDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<PolizaDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
}

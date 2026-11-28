using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IRequisicionDetalleOperations
{
    Task<PagedResult<RequisicionDetalleResponse>> GetAllAsync();
    Task<PagedResult<RequisicionDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<RequisicionDetalleResponse>> CreateAsync(RequisicionDetalleResponse response, int usuarioActual);
    Task<PagedResult<RequisicionDetalleResponse>> UpdateAsync(int id, RequisicionDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<RequisicionDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
}

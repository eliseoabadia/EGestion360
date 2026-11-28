using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class RequisicionDetalleAppService(IRequisicionDetalleOperations service) : IRequisicionDetalleAppService
{
    public Task<PagedResult<RequisicionDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<RequisicionDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<RequisicionDetalleResponse>> CreateAsync(RequisicionDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<RequisicionDetalleResponse>> UpdateAsync(int id, RequisicionDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<RequisicionDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}

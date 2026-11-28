using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class RequisicionAppService(IRequisicionOperations service) : IRequisicionAppService
{
    public Task<PagedResult<EG.Domain.DTOs.Responses.General.UsuarioAreaResponse>> GetRequestersAsync() => service.GetRequestersAsync();
    public Task<PagedResult<RequisicionResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<RequisicionResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<RequisicionResponse>> CreateAsync(RequisicionResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<RequisicionResponse>> UpdateAsync(int id, RequisicionResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<RequisicionResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<EG.Common.GenericModel.PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
}

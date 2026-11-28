using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class EstatusRequisicionAppService(IEstatusRequisicionOperations service) : IEstatusRequisicionAppService
{
    public Task<PagedResult<EstatusRequisicionResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EstatusRequisicionResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EstatusRequisicionResponse>> CreateAsync(EstatusRequisicionResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EstatusRequisicionResponse>> UpdateAsync(int id, EstatusRequisicionResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EstatusRequisicionResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class RequisicionPartidaAppService(IRequisicionPartidaOperations service) : IRequisicionPartidaAppService
{
    public Task<PagedResult<RequisicionPartidaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<RequisicionPartidaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<RequisicionPartidaResponse>> CreateAsync(RequisicionPartidaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<RequisicionPartidaResponse>> UpdateAsync(int id, RequisicionPartidaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<RequisicionPartidaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}

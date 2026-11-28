using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class DepartamentoAppService(IDepartamentoService service) : IDepartamentoAppService
{
    public Task<PagedResult<DepartamentoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<DepartamentoResponse> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<DepartamentoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<DepartamentoResponse>> GetAllByEmpresaAsync(int empresaId) => service.GetAllByEmpresaAsync(empresaId);
    public Task<DepartamentoResponse> CreateAsync(DepartamentoResponse dto, int usuarioActual) => service.CreateAsync(dto, usuarioActual);
    public Task<DepartamentoResponse> UpdateAsync(int id, DepartamentoResponse dto, int usuarioActual) => service.UpdateAsync(id, dto, usuarioActual);
    public Task DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<DepartamentoResponse>> BuscarAsync(BusquedaRequest request) => service.BuscarAsync(request);
}

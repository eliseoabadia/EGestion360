using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class EmpresaAppService(IEmpresaAdministrationService service) : IEmpresaAppService
{
    public Task<PagedResult<EmpresaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<EmpresaResponse> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EmpresaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest) => service.GetAllPaginadoAsync(pageRequest);
    public Task<EmpresaResponse> CreateAsync(EmpresaDto dto, int usuarioActual) => service.CreateAsync(dto, usuarioActual);
    public Task<EmpresaResponse> UpdateAsync(int id, EmpresaDto dto, int usuarioActual) => service.UpdateAsync(id, dto, usuarioActual);
    public Task<EmpresaResponse> UpdateLogoAsync(int id, string logo, byte[] logoEmpresa, int usuarioActual) => service.UpdateLogoAsync(id, logo, logoEmpresa, usuarioActual);
    public Task<bool> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public Task<PagedResult<EmpresaResponse>> BuscarAsync(BusquedaRequest request) => service.BuscarAsync(request);
}

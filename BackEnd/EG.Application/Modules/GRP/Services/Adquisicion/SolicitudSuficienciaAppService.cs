using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class SolicitudSuficienciaAppService(ISolicitudSuficienciaOperations service) : ISolicitudSuficienciaAppService
{
    public Task<PagedResult<SolicitudSuficienciaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<SolicitudSuficienciaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<SolicitudSuficienciaResponse>> CreateAsync(SolicitudSuficienciaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<SolicitudSuficienciaResponse>> UpdateAsync(int id, SolicitudSuficienciaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<SolicitudSuficienciaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<SolicitudSuficienciaResponse>> GenerarDesdeRequisicionAsync( SolicitudSuficienciaGenerarRequest request, int usuarioActual) => service.GenerarDesdeRequisicionAsync(request, usuarioActual);
}

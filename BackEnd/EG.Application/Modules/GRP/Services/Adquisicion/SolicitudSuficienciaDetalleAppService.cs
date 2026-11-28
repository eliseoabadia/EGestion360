using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class SolicitudSuficienciaDetalleAppService(ISolicitudSuficienciaDetalleOperations service) : ISolicitudSuficienciaDetalleAppService
{
    public Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<SolicitudSuficienciaDetalleResponse>> CreateAsync(SolicitudSuficienciaDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<SolicitudSuficienciaDetalleResponse>> UpdateAsync(int id, SolicitudSuficienciaDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}

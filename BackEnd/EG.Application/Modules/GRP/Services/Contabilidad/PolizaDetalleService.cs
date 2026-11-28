using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class PolizaDetalleService(IPolizaDetalleOperations service) : IPolizaDetalleService
{
    public Task<PagedResult<PolizaDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<PolizaDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<PolizaDetalleResponse>> CreateAsync(PolizaDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<PolizaDetalleResponse>> UpdateAsync(int id, PolizaDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<PolizaDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
}

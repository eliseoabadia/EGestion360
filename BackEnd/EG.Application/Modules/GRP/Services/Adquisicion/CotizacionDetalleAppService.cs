using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class CotizacionDetalleAppService(ICotizacionDetalleOperations service) : ICotizacionDetalleAppService
{
    public Task<PagedResult<CotizacionDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<CotizacionDetalleResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<CotizacionDetalleResponse>> CreateAsync(CotizacionDetalleResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<CotizacionDetalleResponse>> UpdateAsync(int id, CotizacionDetalleResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<CotizacionDetalleResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}

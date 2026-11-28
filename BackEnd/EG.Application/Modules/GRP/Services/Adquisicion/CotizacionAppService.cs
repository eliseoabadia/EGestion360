using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Interfaces;

namespace EG.Application.Services.Adquisicion;

public sealed class CotizacionAppService(ICotizacionOperations service) : ICotizacionAppService
{
    public Task<PagedResult<CotizacionResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<CotizacionResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<CotizacionResponse>> CreateAsync(CotizacionResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<CotizacionResponse>> UpdateAsync(int id, CotizacionResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<CotizacionResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<CotizacionResponse>> SendCotizacionEmailAsync(int cotizacionId, int usuarioActual) => service.SendCotizacionEmailAsync(cotizacionId, usuarioActual);
    public Task<PagedResult<CotizacionResponse>> RejectCotizacionEmailAsync(int cotizacionId, int usuarioActual, string? motivo) => service.RejectCotizacionEmailAsync(cotizacionId, usuarioActual, motivo);
    public Task<PagedResult<CotizacionDetalleResponse>> GetRecepcionCotizacionAsync(int cotizacionId) => service.GetRecepcionCotizacionAsync(cotizacionId);
    public Task<PagedResult<CotizacionDetalleResponse>> SaveRecepcionCotizacionAsync(CotizacionRecepcionRequest request, int usuarioActual) => service.SaveRecepcionCotizacionAsync(request, usuarioActual);
}

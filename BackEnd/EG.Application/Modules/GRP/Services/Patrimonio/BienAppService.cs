using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class BienAppService(IBienOperations service) : IBienAppService
{
    public Task<PagedResult<BienResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<BienResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<BienResponse>> CreateAsync(BienResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<BienResponse>> UpdateAsync(int id, BienResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<BienResponse>> GenerarDesdeDetalleOrdenCompraAsync(int detalleOrdenCompraId, int usuarioActual) => service.GenerarDesdeDetalleOrdenCompraAsync(detalleOrdenCompraId, usuarioActual);
    public Task<PagedResult<BienResponse>> RegistrarRecepcionAsync(int detalleOrdenCompraId, decimal cantidadRecibida, int usuarioActual) => service.RegistrarRecepcionAsync(detalleOrdenCompraId, cantidadRecibida, usuarioActual);
}

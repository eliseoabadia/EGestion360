using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IBienOperations
{
    Task<PagedResult<BienResponse>> GetAllAsync();
    Task<PagedResult<BienResponse>> GetByIdAsync(int id);
    Task<PagedResult<BienResponse>> CreateAsync(BienResponse response, int usuarioActual);
    Task<PagedResult<BienResponse>> UpdateAsync(int id, BienResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<BienResponse>> GenerarDesdeDetalleOrdenCompraAsync(int detalleOrdenCompraId, int usuarioActual);
    Task<PagedResult<BienResponse>> RegistrarRecepcionAsync(int detalleOrdenCompraId, decimal cantidadRecibida, int usuarioActual);
}

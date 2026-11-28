using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Business.Interfaces;

public interface ISolicitudSalidaOperations
{
    Task<PagedResult<SolicitudSalidaResponse>> GetAllAsync();
    Task<PagedResult<SolicitudSalidaResponse>> GetByIdAsync(int id);
    Task<PagedResult<SolicitudSalidaResponse>> CreateAsync(SolicitudSalidaResponse response, int usuarioActual);
    Task<PagedResult<SolicitudSalidaResponse>> UpdateAsync(int id, SolicitudSalidaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<SolicitudSalidaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<SolicitudSalidaResponse>> AutorizarAsync(int id, int usuarioActual);
}

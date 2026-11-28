using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Business.Interfaces;

public interface IEgresoAutorizadoOperations
{
    Task<PagedResult<EgresoAutorizadoResponse>> GetAllAsync();
    Task<PagedResult<EgresoAutorizadoResponse>> GetByIdAsync(int id);
    Task<PagedResult<EgresoAutorizadoResponse>> CreateAsync(EgresoAutorizadoResponse response, int usuarioActual);
    Task<PagedResult<EgresoAutorizadoResponse>> UpdateAsync(int id, EgresoAutorizadoResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<EgresoAutorizadoResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<EgresoAutorizadoResponse>> AutorizarProyectadoAsync(
            int pkidEgresoProyectado,
            int usuarioActual,
            int? fkidPolizaConta,
            string? descripcion);
    Task<PagedResult<bool>> RegresarAProyectadoAsync(int pkidEgresoAutorizado, int usuarioActual);
}

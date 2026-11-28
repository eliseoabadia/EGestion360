using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface ICalendarioInventarioOperations
{
    Task<PagedResult<CalendarioInventarioResponse>> GetAllAsync();
    Task<PagedResult<CalendarioInventarioResponse>> GetByIdAsync(int id);
    Task<PagedResult<CalendarioInventarioResponse>> CreateAsync(CalendarioInventarioResponse response, int usuarioActual);
    Task<PagedResult<CalendarioInventarioResponse>> UpdateAsync(int id, CalendarioInventarioResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<CalendarioInventarioResponse>> GetAllPaginadoAsync(PagedRequest request);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class CalendarioInventarioAppService(ICalendarioInventarioOperations service) : ICalendarioInventarioAppService
{
    public Task<PagedResult<CalendarioInventarioResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<CalendarioInventarioResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<CalendarioInventarioResponse>> CreateAsync(CalendarioInventarioResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<CalendarioInventarioResponse>> UpdateAsync(int id, CalendarioInventarioResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<CalendarioInventarioResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}

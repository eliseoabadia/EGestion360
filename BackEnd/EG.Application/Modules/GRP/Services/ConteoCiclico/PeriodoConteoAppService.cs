using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Interfaces;

namespace EG.Application.Services.ConteoCiclico;

public sealed class PeriodoConteoAppService(IPeriodoConteoOperations service) : IPeriodoConteoAppService
{
    public Task<PagedResult<PeriodoConteoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PeriodoConteoResponse> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual) => service.CreateAsync(dto, usuarioActual);
    public Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual) => service.UpdateAsync(id, dto, usuarioActual);
    public Task<bool> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest) => service.GetAllPaginadoAsync(pageRequest);
    public Task<PeriodoConteoResponse> IniciarAsync(int id, int usuarioActual) => service.IniciarAsync(id, usuarioActual);
    public Task<PeriodoConteoResponse> CompletarAsync(int id, int usuarioActual) => service.CompletarAsync(id, usuarioActual);
    public Task<PeriodoConteoResponse> CerrarAsync(int id, int usuarioActual) => service.CerrarAsync(id, usuarioActual);
    public Task<IReadOnlyList<ConteoPlanificacionResponse>> GetPlanificacionAsync() => service.GetPlanificacionAsync();
    public Task<IReadOnlyList<ConteoPlanificacionResponse>> ActualizarClasificacionAbcAsync(int usuarioActual) => service.ActualizarClasificacionAbcAsync(usuarioActual);
    public Task<ConteoPlanificacionResponse> ActualizarPlanAsync(int id, ConteoPlanificacionUpdateRequest request, int usuarioActual) => service.ActualizarPlanAsync(id, request, usuarioActual);
    public Task<int> GenerarConteosSugeridosAsync(int periodoId, int usuarioActual) => service.GenerarConteosSugeridosAsync(periodoId, usuarioActual);
}

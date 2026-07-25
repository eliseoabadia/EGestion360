using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IPeriodoConteoAppService
    {
        Task<PagedResult<PeriodoConteoResponse>> GetAllAsync();
        Task<PeriodoConteoResponse> GetByIdAsync(int id);
        Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual);
        Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id);
        Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);
        Task<PeriodoConteoResponse> IniciarAsync(int id, int usuarioActual);
        Task<PeriodoConteoResponse> CompletarAsync(int id, int usuarioActual);
        Task<PeriodoConteoResponse> CerrarAsync(int id, int usuarioActual);
        Task<IReadOnlyList<ConteoPlanificacionResponse>> GetPlanificacionAsync();
        Task<IReadOnlyList<ConteoPlanificacionResponse>> ActualizarClasificacionAbcAsync(int usuarioActual);
        Task<ConteoPlanificacionResponse> ActualizarPlanAsync(int id, ConteoPlanificacionUpdateRequest request, int usuarioActual);
        Task<int> GenerarConteosSugeridosAsync(int periodoId, int usuarioActual);
    }
}

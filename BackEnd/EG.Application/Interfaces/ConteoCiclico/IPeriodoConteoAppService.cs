using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IPeriodoConteoAppService
    {
        // Consultas básicas
        Task<PagedResult<PeriodoConteoResponse>> GetAllAsync();
        Task<PeriodoConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);

        // Filtros específicos
        Task<PagedResult<PeriodoConteoResponse>> GetBySucursalIdAsync(int sucursalId);
        Task<PagedResult<PeriodoConteoResponse>> GetByEstatusIdAsync(int estatusId);
        Task<PagedResult<PeriodoConteoResponse>> GetPeriodosAbiertosAsync();
        Task<PagedResult<PeriodoConteoResponse>> GetPeriodosCerradosAsync();

        // Operaciones de escritura
        Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual);
        Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);

        // Acciones de negocio
        Task<bool> CerrarPeriodoAsync(int id, int usuarioActual);
        Task<bool> ReabrirPeriodoAsync(int id, int usuarioActual);
        Task<bool> ActualizarEstadisticasAsync(int id);
        Task<bool> CambiarEstatusAsync(int id, int estatusId, int usuarioActual);
        Task<PagedResult<PeriodoConteoResponse>> GetMisPeriodosAsync(int usuarioId);
    }
}
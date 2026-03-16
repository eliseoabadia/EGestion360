using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IArticuloConteoAppService
    {
        // Consultas básicas
        Task<PagedResult<PeriodoConteoResponse>> GetAllAsync();
        Task<PeriodoConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);

        // Filtros específicos (basados en la vista)
        Task<PagedResult<PeriodoConteoResponse>> GetByPeriodoIdAsync(int periodoId);
        Task<PagedResult<PeriodoConteoResponse>> GetBySucursalIdAsync(int sucursalId);
        Task<PagedResult<PeriodoConteoResponse>> GetPendientesAsync(int periodoId, int sucursalId);
        Task<PagedResult<PeriodoConteoResponse>> GetConcluidosAsync(int periodoId, int sucursalId);

        // Operaciones de escritura
        Task<PeriodoConteoResponse> CreateAsync(ArticuloConteoDto dto, int usuarioActual);
        Task<PeriodoConteoResponse> UpdateAsync(int id, ArticuloConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);

        // Métodos adicionales de negocio
        Task<bool> IniciarConteoAsync(int id, int usuarioActual);
        Task<bool> ConcluirConteoAsync(int id, decimal existenciaFinal, int usuarioActual);
    }
}
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IArticuloConteoAppService
    {
        // Consultas básicas
        Task<PagedResult<ArticuloConteoResponse>> GetAllAsync();
        Task<ArticuloConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<ArticuloConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);

        // Filtros específicos (basados en la vista)
        Task<PagedResult<ArticuloConteoResponse>> GetByPeriodoIdAsync(int periodoId);
        Task<PagedResult<ArticuloConteoResponse>> GetBySucursalIdAsync(int sucursalId);
        Task<PagedResult<ArticuloConteoResponse>> GetPendientesAsync(int periodoId, int sucursalId);
        Task<PagedResult<ArticuloConteoResponse>> GetConcluidosAsync(int periodoId, int sucursalId);

        // Operaciones de escritura
        Task<ArticuloConteoResponse> CreateAsync(ArticuloConteoDto dto, int usuarioActual);
        Task<ArticuloConteoResponse> UpdateAsync(int id, ArticuloConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);

        // Métodos adicionales de negocio
        Task<bool> IniciarConteoAsync(int id, int usuarioActual);
        Task<bool> ConcluirConteoAsync(int id, decimal existenciaFinal, int usuarioActual);
    }
}
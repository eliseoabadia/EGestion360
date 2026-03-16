using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IRegistroConteoAppService
    {
        // Consultas básicas
        Task<PagedResult<RegistroConteoResponse>> GetAllAsync();
        Task<RegistroConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<RegistroConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);

        // Filtros específicos (basados en la vista)
        Task<PagedResult<RegistroConteoResponse>> GetByArticuloConteoIdAsync(int articuloConteoId);
        Task<PagedResult<RegistroConteoResponse>> GetByPeriodoIdAsync(int periodoId);
        Task<PagedResult<RegistroConteoResponse>> GetBySucursalIdAsync(int sucursalId);
        Task<PagedResult<RegistroConteoResponse>> GetByUsuarioIdAsync(int usuarioId);
        Task<PagedResult<RegistroConteoResponse>> GetUltimosConteosPorArticuloAsync(int articuloConteoId, int cantidad = 5);

        // Operaciones de escritura
        Task<RegistroConteoResponse> CreateAsync(RegistroConteoDto dto, int usuarioActual);
        Task<RegistroConteoResponse> UpdateAsync(int id, RegistroConteoDto dto, int usuarioActual);
        Task<bool> DeleteAsync(int id, int usuarioActual);
    }
}
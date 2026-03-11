using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IArticuloConteoAppService
    {
        // Consultas
        Task<PagedResult<VwArticuloConteoResponse>> GetAllAsync();
        Task<VwArticuloConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<VwArticuloConteoResponse>> GetAllPaginadoAsync(PagedRequest request);
        
        // Filtrados
        Task<PagedResult<VwArticuloConteoResponse>> GetAllByPeriodoAsync(int periodoId);
        Task<PagedResult<VwArticuloConteoResponse>> GetPendientesAsync(int periodoId);
        Task<PagedResult<VwArticuloConteoResponse>> GetByEstatusAsync(int periodoId, int estatusId);

        // Comandos
        Task<VwArticuloConteoResponse> CreateAsync(ArticuloConteoDto dto, int usuarioActual);
        Task<VwArticuloConteoResponse> UpdateAsync(int id, ArticuloConteoDto dto, int usuarioActual);
        Task DeleteAsync(int id);

        // Operaciones específicas
        Task CambiarEstatusAsync(int id, int estatusId, int usuarioActual);
        Task ActualizarProgresAsync(int periodoId, int usuarioActual);
    }
}
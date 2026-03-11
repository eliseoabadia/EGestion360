using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IPeriodoConteoAppService
    {
        // Consultas
        Task<PagedResult<VwPeriodoConteoResponse>> GetAllAsync();
        Task<VwPeriodoConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<VwPeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest request);

        // Comandos (CREATE, UPDATE, DELETE)
        Task<VwPeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual);
        Task<VwPeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual);
        Task DeleteAsync(int id);
        
        // Operaciones específicas
        Task CambiarEstatusAsync(int id, int estatusId, int usuarioActual);
        Task CerrarPeriodoAsync(int id, int usuarioActual);
    }
}
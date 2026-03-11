using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IRegistroConteoAppService
    {
        // Consultas
        Task<PagedResult<VwRegistroConteoResponse>> GetAllAsync();
        Task<VwRegistroConteoResponse> GetByIdAsync(int id);
        Task<PagedResult<VwRegistroConteoResponse>> GetAllPaginadoAsync(PagedRequest request);

        // Filtrados
        Task<PagedResult<VwRegistroConteoResponse>> GetAllByArticuloAsync(int articuloId);
        Task<PagedResult<VwRegistroConteoResponse>> GetAllByPeriodoAsync(int periodoId);
        Task<PagedResult<VwRegistroConteoResponse>> GetAllByUsuarioAsync(int usuarioId);

        // Comandos
        Task<VwRegistroConteoResponse> RegistrarConteoAsync(RegistroConteoDto dto, int usuarioActual);
        Task<VwRegistroConteoResponse> UpdateAsync(int id, RegistroConteoDto dto, int usuarioActual);
        Task DeleteAsync(int id);

        // Operaciones específicas
        Task<dynamic> ValidarYProcesarConteoAsync(int articuloId, decimal cantidadContada, int usuarioActual);
    }
}
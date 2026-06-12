using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface ITipoSolicitudCLCService
    {
        Task<TipoSolicitudCLCResponse?> GetByIdAsync(int id);
        Task<TipoSolicitudCLCResponse> CreateAsync(TipoSolicitudCLCDto dto, int usuarioId);
        Task<TipoSolicitudCLCResponse?> UpdateAsync(int id, TipoSolicitudCLCDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<TipoSolicitudCLCResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}

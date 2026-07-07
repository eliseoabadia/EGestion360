using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contratos;

namespace EG.Application.Interfaces.Contratos
{
    public interface IRegistroCompromisoAppService : IAdquisicionCrudAppService<OrcoContratoResponse>
    {
        Task<PagedResult<OrcoContratoResponse>> AutorizarAsync(int id, int usuarioActual);
    }

    public interface IEstadoContratoAppService : IAdquisicionCrudAppService<EstadoContratoResponse>
    {
        Task<PagedResult<EstadoContratoResponse>> AutorizarAsync(int id, int usuarioActual);
        Task<PagedResult<EstadoContratoResponse>> LiberarRemanenteAsync(int id, int usuarioActual);
    }
}

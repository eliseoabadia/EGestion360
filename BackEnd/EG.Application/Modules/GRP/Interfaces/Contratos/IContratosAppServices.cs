using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contratos;

namespace EG.Application.Interfaces.Contratos
{
    public interface IRegistroCompromisoAppService : IAdquisicionCrudAppService<OrcoContratoResponse>
    {
        Task<PagedResult<OrcoContratoResponse>> AutorizarAsync(int id, int usuarioActual);
    }
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IEstudioMercadoService : IAdquisicionCrudAppService<EstudioMercadoResponse>
    {
        Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    }
}

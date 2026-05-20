using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface IPolizaDetalleService : IAdquisicionCrudAppService<PolizaDetalleResponse>
    {
        Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    }
}

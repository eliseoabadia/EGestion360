using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IOrdenCompraAppService : IAdquisicionCrudAppService<OrdenCompraResponse>
    {
        Task<PagedResult<OrdenCompraResponse>> AutorizarAsync(int id, int usuarioActual);
    }
}

using EG.Application.Interfaces.Adquisicion;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IInventarioAppService : IAdquisicionCrudAppService<InventarioResponse>
    {
        Task<EG.Common.GenericModel.PagedResult<InventarioResponse>> AutorizarAsync(int id, int usuarioActual);
    }
}

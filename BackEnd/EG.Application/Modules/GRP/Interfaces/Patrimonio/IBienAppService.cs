using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface IBienAppService : IAdquisicionCrudAppService<BienResponse>
    {
        Task<PagedResult<BienResponse>> GenerarDesdeDetalleOrdenCompraAsync(int detalleOrdenCompraId, int usuarioActual);
    }
}

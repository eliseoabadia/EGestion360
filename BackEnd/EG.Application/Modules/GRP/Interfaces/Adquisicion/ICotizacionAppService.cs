using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface ICotizacionAppService : IAdquisicionCrudAppService<CotizacionResponse>
    {
        Task<PagedResult<CotizacionResponse>> SendCotizacionEmailAsync(int cotizacionId, int usuarioActual);
        Task<PagedResult<CotizacionDetalleResponse>> GetRecepcionCotizacionAsync(int cotizacionId);
        Task<PagedResult<CotizacionDetalleResponse>> SaveRecepcionCotizacionAsync(CotizacionRecepcionRequest request, int usuarioActual);
    }
}

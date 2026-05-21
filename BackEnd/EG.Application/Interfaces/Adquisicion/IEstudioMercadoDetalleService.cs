using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IEstudioMercadoDetalleService : IAdquisicionCrudAppService<EstudioMercadoDetalleResponse>
    {
        Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
        Task<PagedResult<LookupItem>> GetPaaasLookupAsync(PagedRequest request);
        Task<PagedResult<EstudioMercadoPaaasDetalleResponse>> GetPaaasDetallesAsync(PagedRequest request);
        Task<PagedResult<LookupItem>> GetPaaasDetallesLookupAsync(PagedRequest request);
        Task<PagedResult<EstudioMercadoDetalleSeedResponse>> GetPaaasDetalleSeedAsync(int paaaseDetalleId);
        Task<PagedResult<EstudioMercadoDetalleResponse>> CreateBatchAsync(EstudioMercadoDetalleBatchRequest request, int usuarioActual);
    }
}

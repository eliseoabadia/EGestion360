using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Seguridad;
using EG.Domain.DTOs.Responses.Seguridad;

namespace EG.Business.Interfaces;

public interface IBitacoraService
{
    Task<PagedResult<BitacoraResponse>> ConsultarAsync(BitacoraRequest request);
    Task<PagedResult<BitacoraResponse>> ObtenerFiltrosAsync(BitacoraRequest request);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Seguridad;
using EG.Domain.DTOs.Responses.Seguridad;
namespace EG.Application.Interfaces.General;

public interface IBitacoraAppService
{
    Task<PagedResult<BitacoraResponse>> ConsultarAsync(BitacoraRequest request);
    Task<PagedResult<BitacoraResponse>> ObtenerFiltrosAsync(BitacoraRequest request);
}

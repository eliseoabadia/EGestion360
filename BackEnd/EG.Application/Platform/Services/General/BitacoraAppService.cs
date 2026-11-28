using EG.Application.Interfaces.General;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Seguridad;
using EG.Domain.DTOs.Responses.Seguridad;
namespace EG.Application.Services.General;

public sealed class BitacoraAppService(IBitacoraService service) : IBitacoraAppService
{
    public Task<PagedResult<BitacoraResponse>> ConsultarAsync(BitacoraRequest request)
        => service.ConsultarAsync(request);
    public Task<PagedResult<BitacoraResponse>> ObtenerFiltrosAsync(BitacoraRequest request)
        => service.ObtenerFiltrosAsync(request);
}

using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface ISolicitudSuficienciaAppService : IAdquisicionCrudAppService<SolicitudSuficienciaResponse>
    {
        Task<PagedResult<SolicitudSuficienciaResponse>> GenerarDesdeRequisicionAsync(
            SolicitudSuficienciaGenerarRequest request,
            int usuarioActual);
    }
}

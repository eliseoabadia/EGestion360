using EG.Application.Interfaces.Almacen;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Almacen
{
    public class EstatusSolicitudSalidaAppService
        : AdquisicionCrudAppService<EstatusSolicitudSalidum, EstatusSolicitudSalidum, EstatusSolicitudSalidaDto, EstatusSolicitudSalidaResponse>,
            IEstatusSolicitudSalidaAppService
    {
        public EstatusSolicitudSalidaAppService(
            GenericService<EstatusSolicitudSalidum, EstatusSolicitudSalidaDto, EstatusSolicitudSalidaResponse> service,
            GenericService<EstatusSolicitudSalidum, EstatusSolicitudSalidaDto, EstatusSolicitudSalidaResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidEstatusSolicitudSalida",
                "Estatus de solicitud de salida",
                (dto, id) => dto.PkidEstatusSolicitudSalida = id)
        {
        }
    }
}

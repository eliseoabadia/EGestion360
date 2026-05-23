using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class SolicitudSuficienciaDetalleAppService
        : AdquisicionCrudAppService<SolicitudSuficienciaDetalle, VwSolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalleResponse>,
            ISolicitudSuficienciaDetalleAppService
    {
        public SolicitudSuficienciaDetalleAppService(
            GenericService<SolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalleResponse> service,
            GenericService<VwSolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalleResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidSolicitudSuficienciaDetalle",
                "Detalle de solicitud de suficiencia",
                (dto, id) => dto.PkidSolicitudSuficienciaDetalle = id)
        {
        }
    }
}

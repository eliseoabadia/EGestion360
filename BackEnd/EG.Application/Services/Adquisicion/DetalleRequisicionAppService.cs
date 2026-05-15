using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class DetalleRequisicionAppService
        : AdquisicionCrudAppService<DetalleRequisicion, VwDetalleRequisicion, DetalleRequisicionDto, DetalleRequisicionResponse>,
            IDetalleRequisicionAppService
    {
        public DetalleRequisicionAppService(
            GenericService<DetalleRequisicion, DetalleRequisicionDto, DetalleRequisicionResponse> service,
            GenericService<VwDetalleRequisicion, DetalleRequisicionDto, DetalleRequisicionResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidDetalleRequisicion",
                "Detalle de requisicion",
                (dto, id) => dto.PkidDetalleRequisicion = id)
        {
        }
    }
}

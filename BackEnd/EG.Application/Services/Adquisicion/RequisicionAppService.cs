using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class RequisicionAppService
        : AdquisicionCrudAppService<Requisicion, VwRequisicion, RequisicionDto, RequisicionResponse>,
            IRequisicionAppService
    {
        public RequisicionAppService(
            GenericService<Requisicion, RequisicionDto, RequisicionResponse> service,
            GenericService<VwRequisicion, RequisicionDto, RequisicionResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidRequisicion",
                "Requisicion",
                (dto, id) => dto.PkidRequisicion = id)
        {
        }
    }
}

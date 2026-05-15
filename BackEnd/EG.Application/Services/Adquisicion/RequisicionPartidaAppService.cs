using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class RequisicionPartidaAppService
        : AdquisicionCrudAppService<RequisicionPartidum, VwRequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse>,
            IRequisicionPartidaAppService
    {
        public RequisicionPartidaAppService(
            GenericService<RequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse> service,
            GenericService<VwRequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidRequisicionPartida",
                "Partida de requisicion",
                (dto, id) => dto.PkidRequisicionPartida = id)
        {
        }
    }
}

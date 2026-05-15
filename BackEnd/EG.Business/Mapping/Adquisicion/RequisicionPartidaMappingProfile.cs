using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class RequisicionPartidaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<RequisicionPartidum, RequisicionPartidaResponse>();
            config.NewConfig<VwRequisicionPartidum, RequisicionPartidaResponse>();
            config.NewConfig<RequisicionPartidaResponse, RequisicionPartidaDto>().IgnoreNullValues(true);

            config.NewConfig<RequisicionPartidaDto, RequisicionPartidum>()
                .Ignore(dest => dest.PkidRequisicionPartida);
        }
    }
}

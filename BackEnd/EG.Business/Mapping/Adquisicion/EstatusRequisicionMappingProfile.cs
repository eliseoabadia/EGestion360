using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class EstatusRequisicionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<EstatusRequisicion, EstatusRequisicionDto>().TwoWays();
            config.NewConfig<EstatusRequisicion, EstatusRequisicionResponse>();
            config.NewConfig<EstatusRequisicionResponse, EstatusRequisicionDto>()
                .Ignore(dest => dest.PkidEstatusRequisicion)
                .IgnoreNullValues(true);
        }
    }
}
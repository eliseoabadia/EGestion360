using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class RequisicionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Requisicion, RequisicionResponse>();
            config.NewConfig<VwRequisicion, RequisicionResponse>();
            config.NewConfig<RequisicionResponse, RequisicionDto>().IgnoreNullValues(true);

            config.NewConfig<RequisicionDto, Requisicion>()
                .Ignore(dest => dest.PkidRequisicion);
        }
    }
}

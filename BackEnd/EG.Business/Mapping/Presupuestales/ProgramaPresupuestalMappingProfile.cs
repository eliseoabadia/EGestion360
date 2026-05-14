using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ProgramaPresupuestalMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Pp, ProgramaPresupuestalDto>().TwoWays();
            config.NewConfig<Pp, ProgramaPresupuestalResponse>();
            config.NewConfig<ProgramaPresupuestalResponse, ProgramaPresupuestalDto>()
                .Ignore(dest => dest.PkidPp)
                .IgnoreNullValues(true);
        }
    }
}

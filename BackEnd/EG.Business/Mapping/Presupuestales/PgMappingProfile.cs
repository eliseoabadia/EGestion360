using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class PgMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Pg, PgDto>().TwoWays();
            config.NewConfig<Pg, PgResponse>();
            config.NewConfig<PgResponse, PgDto>()
                .Ignore(dest => dest.PkidPg)
                .IgnoreNullValues(true);
        }
    }
}

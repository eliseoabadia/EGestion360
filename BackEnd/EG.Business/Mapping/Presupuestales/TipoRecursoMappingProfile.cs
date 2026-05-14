using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class TipoRecursoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoRecurso, TipoRecursoDto>().TwoWays();
            config.NewConfig<TipoRecurso, TipoRecursoResponse>();
            config.NewConfig<TipoRecursoResponse, TipoRecursoDto>()
                .Ignore(dest => dest.PkidTipoRecurso)
                .IgnoreNullValues(true);
        }
    }
}

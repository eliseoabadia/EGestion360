using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class AniosMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Anio, AniosDto>().TwoWays();
            config.NewConfig<Anio, AniosResponse>();
            config.NewConfig<AniosResponse, AniosDto>()
                .Ignore(dest => dest.PkidAnio)
                .IgnoreNullValues(true);
        }
    }
}

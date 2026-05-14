using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ProyectoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Proyecto, ProyectoDto>().TwoWays();
            config.NewConfig<Proyecto, ProyectoResponse>();
            config.NewConfig<ProyectoResponse, ProyectoDto>()
                .Ignore(dest => dest.PkidProyecto)
                .IgnoreNullValues(true);
        }
    }
}

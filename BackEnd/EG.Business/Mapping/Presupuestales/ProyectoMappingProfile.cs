using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ProyectoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Py, ProyectoDto>().TwoWays();
            config.NewConfig<Py, ProyectoResponse>();
            config.NewConfig<ProyectoResponse, ProyectoDto>()
                .Ignore(dest => dest.PkidPy)
                .IgnoreNullValues(true);
        }
    }
}

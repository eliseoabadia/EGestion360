using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class FinalidadMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Fn, FnResponse>().TwoWays();
            config.NewConfig<Fn, FnDto>().TwoWays();
        }
    }
}

using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class NivelMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Nivel, NivelDto>().TwoWays();
            config.NewConfig<Nivel, NivelResponse>().TwoWays();
        }
    }
}

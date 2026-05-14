using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class PersonaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Persona, PersonaDto>().TwoWays();
            config.NewConfig<Persona, PersonaResponse>().TwoWays();
            config.NewConfig<PersonaResponse, PersonaDto>()
                .Ignore(dest => dest.PkidPersona)
                .IgnoreNullValues(true);
        }
    }
}
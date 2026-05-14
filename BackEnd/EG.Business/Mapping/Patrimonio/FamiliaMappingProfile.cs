using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class FamiliaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Familium, FamiliaDto>().TwoWays();
            config.NewConfig<Familium, FamiliaResponse>();
            config.NewConfig<FamiliaResponse, FamiliaDto>()
                .Ignore(dest => dest.PkidFamilia)
                .IgnoreNullValues(true);
        }
    }
}

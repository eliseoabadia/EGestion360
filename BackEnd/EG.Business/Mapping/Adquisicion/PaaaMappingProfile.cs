using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Paaa, PaaaDto>().TwoWays();

            config.NewConfig<VwPaaa, PaaaResponse>();

            config.NewConfig<PaaaResponse, PaaaDto>()
                .Ignore(dest => dest.PkidPaaas)
                .IgnoreNullValues(true);
        }
    }
}

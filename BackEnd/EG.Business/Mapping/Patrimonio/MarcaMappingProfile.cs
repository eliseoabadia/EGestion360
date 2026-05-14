using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class MarcaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Marca, MarcaDto>().TwoWays();
            config.NewConfig<Marca, MarcaResponse>().TwoWays();
            config.NewConfig<MarcaResponse, MarcaDto>()
                .Ignore(dest => dest.PkidMarca)
                .IgnoreNullValues(true);
        }
    }
}

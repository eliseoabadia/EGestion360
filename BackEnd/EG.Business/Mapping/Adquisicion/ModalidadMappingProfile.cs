using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ModalidadMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Modalidad, ModalidadDto>().TwoWays();
            config.NewConfig<Modalidad, ModalidadResponse>();
            config.NewConfig<ModalidadResponse, ModalidadDto>()
                .Ignore(dest => dest.PkidModalidad)
                .IgnoreNullValues(true);
        }
    }
}
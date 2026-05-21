using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Adquisicion
{
    public class EstudioMercadoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<EstudioMercado, EstudioMercadoDto>().TwoWays();
            config.NewConfig<EstudioMercado, EstudioMercadoResponse>();
            config.NewConfig<VwEstudioMercado, EstudioMercadoResponse>();
            config.NewConfig<EstudioMercadoResponse, EstudioMercadoDto>()
                .Ignore(dest => dest.PkidEstudioMercado)
                .IgnoreNullValues(true);
        }
    }
}

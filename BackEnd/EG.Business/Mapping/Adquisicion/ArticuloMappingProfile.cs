using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ArticuloMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Articulo, ArticuloDto>().TwoWays();
            config.NewConfig<Articulo, ArticuloResponse>();
            config.NewConfig<ArticuloResponse, ArticuloDto>()
                .Ignore(dest => dest.PkidArticulo)
                .IgnoreNullValues(true);
        }
    }
}
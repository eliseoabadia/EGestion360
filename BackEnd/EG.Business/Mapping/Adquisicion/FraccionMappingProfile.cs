using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class FraccionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Fraccion, FraccionDto>().TwoWays();
            config.NewConfig<Fraccion, FraccionResponse>()
                .Map(dest => dest.NombreArticulo, src => src.FkidArticuloOrcoNavigation != null ? src.FkidArticuloOrcoNavigation.Descripcion : string.Empty);
            config.NewConfig<VwFraccion, FraccionResponse>()
                .Map(dest => dest.NombreArticulo, src => src.ArticuloDescripcion);
            config.NewConfig<FraccionResponse, FraccionDto>()
                .Ignore(dest => dest.PkidFraccion)
                .IgnoreNullValues(true);
        }
    }
}

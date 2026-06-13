using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class FinalidadMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Fn, FnDto>().TwoWays();
            config.NewConfig<Fn, FnResponse>()
                .Map(dest => dest.GfClave, src => src.FkidGfPresNavigation != null ? src.FkidGfPresNavigation.Clave : (int?)null)
                .Map(dest => dest.GfDescripcion, src => src.FkidGfPresNavigation != null ? src.FkidGfPresNavigation.Descripcion : string.Empty)
                .Map(dest => dest.GfClaveNombre, src => src.FkidGfPresNavigation != null ? $"{src.FkidGfPresNavigation.Clave} - {src.FkidGfPresNavigation.Descripcion}" : string.Empty)
                .Map(dest => dest.ClaveNombre, src => $"{src.Clave} - {src.Descripcion}");
            config.NewConfig<VwFn, FnDto>();
            config.NewConfig<VwFn, FnResponse>()
                .Map(dest => dest.GfClave, src => src.Gfclave)
                .Map(dest => dest.GfDescripcion, src => src.Gfdescripcion)
                .Map(dest => dest.GfClaveNombre, src => src.GfclaveNombre);
            config.NewConfig<FnResponse, FnDto>();
        }
    }
}

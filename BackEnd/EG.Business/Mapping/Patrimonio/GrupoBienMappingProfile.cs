using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class GrupoBienMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<GrupoBien, GrupoBienDto>().TwoWays();
            config.NewConfig<GrupoBien, GrupoBienResponse>()
                .Map(dest => dest.GrupoBienDescripcion, src => src.Descripcion)
                .Map(dest => dest.GrupoBienClave, src => src.Clave)
                .Map(dest => dest.FamiliaDescripcion, src => src.FkidFamiliaAlmaNavigation != null ? src.FkidFamiliaAlmaNavigation.Descripcion : null)
                .Map(dest => dest.FamiliaClave, src => src.FkidFamiliaAlmaNavigation != null ? src.FkidFamiliaAlmaNavigation.Clave : null);
            config.NewConfig<VwGrupoBien, GrupoBienResponse>()
                .Map(dest => dest.GrupoBienDescripcion, src => src.Descripcion)
                .Map(dest => dest.GrupoBienClave, src => src.Clave)
                .Map(dest => dest.FamiliaDescripcion, src => src.FamiliaDescripcion)
                .Map(dest => dest.FamiliaClave, src => src.FamiliaClave);
            config.NewConfig<GrupoBienResponse, GrupoBienDto>()
                .Ignore(dest => dest.PkidGrupoBien)
                .Map(dest => dest.Descripcion, src => src.GrupoBienDescripcion)
                .Map(dest => dest.Clave, src => src.GrupoBienClave)
                .IgnoreNullValues(true);
        }
    }
}

using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class UnidadResponsableMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Mapeo de Area a UnidadResponsableDto (para operaciones de escritura)
            config.NewConfig<Area, UnidadResponsableDto>()
                .Map(dest => dest.PkidUnidadResponsable, src => src.PkidArea)
                .Map(dest => dest.FkidAreaSis, src => src.FkidAreaSis)
                .Map(dest => dest.Clave, src => src.Clave)
                .Map(dest => dest.Descripcion, src => src.Nombre)
                .Map(dest => dest.Activo, src => src.Activo)
                .Map(dest => dest.FechaCreacion, src => src.FechaCreacion)
                .Map(dest => dest.UsuarioCreacion, src => src.UsuarioCreacion)
                .Map(dest => dest.FechaModificacion, src => src.FechaModificacion)
                .Map(dest => dest.UsuarioModificacion, src => src.UsuarioModificacion)
                .Ignore(dest => dest.Children);

            config.NewConfig<UnidadResponsableDto, Area>()
                .Map(dest => dest.PkidArea, src => src.PkidUnidadResponsable)
                .Map(dest => dest.FkidAreaSis, src => src.FkidAreaSis)
                .Map(dest => dest.Nombre, src => src.Descripcion)
                .Ignore(dest => dest.InverseFkidAreaSisNavigation);

            // Mapeo de Area a UnidadResponsableResponse (para consultas/lectura)
            config.NewConfig<Area, UnidadResponsableResponse>()
                .Map(dest => dest.PkidUnidadResponsable, src => src.PkidArea)
                .Map(dest => dest.FkidAreaSis, src => src.FkidAreaSis)
                .Map(dest => dest.Clave, src => src.Clave)
                .Map(dest => dest.Descripcion, src => src.Nombre)
                .Map(dest => dest.Activo, src => src.Activo)
                .Map(dest => dest.FechaCreacion, src => src.FechaCreacion)
                .Ignore(dest => dest.Children);

            // Mapeo de VwArea a UnidadResponsableResponse (para consultas con vista)
            config.NewConfig<VwArea, UnidadResponsableResponse>()
                .Map(dest => dest.PkidUnidadResponsable, src => src.PkidArea)
                .Map(dest => dest.FkidAreaSis, src => src.FkidAreaSis)
                .Map(dest => dest.Clave, src => src.Clave)
                .Map(dest => dest.Descripcion, src => src.Nombre)
                .Map(dest => dest.Activo, src => src.Activo)
                .Map(dest => dest.FechaCreacion, src => src.FechaCreacion)
                .Map(dest => dest.FechaModificacion, src => src.FechaModificacion)
                .Map(dest => dest.UsuarioCreacion, src => src.UsuarioCreacion)
                .Map(dest => dest.UsuarioModificacion, src => src.UsuarioModificacion)
                .Map(dest => dest.AreaPadreNombre, src => src.AreaPadreNombre)
                .Map(dest => dest.AreaPadreClave, src => src.AreaPadreClave)
                .Ignore(dest => dest.Children);

            // Mapeo de Response a Dto (para actualizaciones)
            config.NewConfig<UnidadResponsableResponse, UnidadResponsableDto>()
                .Map(dest => dest.PkidUnidadResponsable, src => src.PkidUnidadResponsable)
                .Map(dest => dest.FkidAreaSis, src => src.FkidAreaSis)
                .Ignore(dest => dest.Children)
                .IgnoreNullValues(true);
        }
    }
}

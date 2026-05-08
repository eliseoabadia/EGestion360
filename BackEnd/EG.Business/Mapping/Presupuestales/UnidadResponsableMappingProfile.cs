using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class UnidadResponsableMappingProfile : Profile
    {
        public UnidadResponsableMappingProfile()
        {
            // Mapeo de Area a UnidadResponsableDto (para operaciones de escritura)
            CreateMap<Area, UnidadResponsableDto>()
                .ForMember(dest => dest.PkidUnidadResponsable, opt => opt.MapFrom(src => src.PkidArea))
                .ForMember(dest => dest.FkidAreaSis, opt => opt.MapFrom(src => src.FkidAreaSis))
                .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.Children, opt => opt.Ignore())
                .ReverseMap()
                .ForMember(dest => dest.PkidArea, opt => opt.MapFrom(src => src.PkidUnidadResponsable))
                .ForMember(dest => dest.FkidAreaSis, opt => opt.MapFrom(src => src.FkidAreaSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.InverseFkidAreaSisNavigation, opt => opt.Ignore());

            // Mapeo de Area a UnidadResponsableResponse (para consultas/lectura)
            CreateMap<Area, UnidadResponsableResponse>()
                .ForMember(dest => dest.PkidUnidadResponsable, opt => opt.MapFrom(src => src.PkidArea))
                .ForMember(dest => dest.FkidAreaSis, opt => opt.MapFrom(src => src.FkidAreaSis))
                .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.Children, opt => opt.Ignore());

            // Mapeo de VwArea a UnidadResponsableResponse (para consultas con vista)
            CreateMap<VwArea, UnidadResponsableResponse>()
                .ForMember(dest => dest.PkidUnidadResponsable, opt => opt.MapFrom(src => src.PkidArea))
                .ForMember(dest => dest.FkidAreaSis, opt => opt.MapFrom(src => src.FkidAreaSis))
                .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.AreaPadreNombre, opt => opt.MapFrom(src => src.AreaPadreNombre))
                .ForMember(dest => dest.AreaPadreClave, opt => opt.MapFrom(src => src.AreaPadreClave))
                .ForMember(dest => dest.Children, opt => opt.Ignore());

            // Mapeo de Response a Dto (para actualizaciones)
            CreateMap<UnidadResponsableResponse, UnidadResponsableDto>()
                .ForMember(dest => dest.PkidUnidadResponsable, opt => opt.MapFrom(src => src.PkidUnidadResponsable))
                .ForMember(dest => dest.FkidAreaSis, opt => opt.MapFrom(src => src.FkidAreaSis))
                .ForMember(dest => dest.Children, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

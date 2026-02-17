using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Mapping.Entidades
{
    public class MenuMappingProfile : Profile
    {
        public MenuMappingProfile()
        {
            // Mapeo de VwMenu a MenuItemsResponse (para consultas/lectura)
            CreateMap<VwMenu, MenuItemsResponse>()
                .ForMember(dest => dest.PkidMenu, opt => opt.MapFrom(src => src.PkidMenu))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Tipo, opt => opt.MapFrom(src => src.Tipo))
                .ForMember(dest => dest.TipoDescripcion, opt => opt.MapFrom(src => src.TipoDescripcion))
                .ForMember(dest => dest.FkidMenuSis, opt => opt.MapFrom(src => src.FkidMenuSis))
                .ForMember(dest => dest.NombreMenuPadre, opt => opt.MapFrom(src => src.NombreMenuPadre))
                .ForMember(dest => dest.TipoMenuPadre, opt => opt.MapFrom(src => src.TipoMenuPadre))
                .ForMember(dest => dest.TipoMenuPadreDescripcion, opt => opt.MapFrom(src => src.TipoMenuPadreDescripcion))
                .ForMember(dest => dest.LegacyName, opt => opt.MapFrom(src => src.LegacyName))
                .ForMember(dest => dest.Ruta, opt => opt.MapFrom(src => src.Ruta))
                .ForMember(dest => dest.ImageUrl, opt => opt.MapFrom(src => src.ImageUrl))
                .ForMember(dest => dest.Lenguaje, opt => opt.MapFrom(src => src.Lenguaje))
                .ForMember(dest => dest.Orden, opt => opt.MapFrom(src => src.Orden))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.Estado, opt => opt.MapFrom(src => src.Estado))
                .ForMember(dest => dest.CreatedByOperatorId, opt => opt.MapFrom(src => src.CreatedByOperatorId))
                .ForMember(dest => dest.CreatedDateTime, opt => opt.MapFrom(src => src.CreatedDateTime))
                .ForMember(dest => dest.ModifiedByOperatorId, opt => opt.MapFrom(src => src.ModifiedByOperatorId))
                .ForMember(dest => dest.ModifiedDateTime, opt => opt.MapFrom(src => src.ModifiedDateTime))
                .ForMember(dest => dest.NivelJerarquico, opt => opt.MapFrom(src => src.NivelJerarquico))
                .ForMember(dest => dest.RutaCompleta, opt => opt.MapFrom(src => src.RutaCompleta))
                .ForMember(dest => dest.TieneSubmenus, opt => opt.MapFrom(src => src.TieneSubmenus))
                .ForMember(dest => dest.ValidacionEstructura, opt => opt.MapFrom(src => src.ValidacionEstructura))
                .ForMember(dest => dest.Children, opt => opt.Ignore()); // Los hijos se asignan manualmente

            // Mapeo de MenuItemsDto a Menu (para operaciones de escritura: Create/Update)
            //CreateMap<MenuItemsDto, Menu>()
            //    .ForMember(dest => dest.PkidMenu, opt => opt.Ignore()) // Ignorar ID para nuevos registros
            //    .ForMember(dest => dest.FkidMenuSisNavigation, opt => opt.Ignore())
            //    .ForMember(dest => dest.InverseFkidMenuSisNavigation, opt => opt.Ignore())
            //    .ForMember(dest => dest.MenuRoles, opt => opt.Ignore())
            //    // Estas propiedades se asignan en el servicio/repositorio
            //    .ForMember(dest => dest.CreatedDateTime, opt => opt.Ignore())
            //    .ForMember(dest => dest.ModifiedDateTime, opt => opt.Ignore())
            //    .ForMember(dest => dest.CreatedByOperatorId, opt => opt.Ignore())
            //    .ForMember(dest => dest.ModifiedByOperatorId, opt => opt.Ignore());

            // Mapeo de Menu a MenuItemsDto (para cuando necesitas convertir de Entity a DTO)
            //CreateMap<Menu, MenuItemsDto>()
            //    .ForMember(dest => dest.PkidMenu, opt => opt.MapFrom(src => src.PkidMenu))
            //    .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
            //    .ForMember(dest => dest.Tipo, opt => opt.MapFrom(src => src.Tipo))
            //    .ForMember(dest => dest.FkidMenuSis, opt => opt.MapFrom(src => src.FkidMenuSis))
            //    .ForMember(dest => dest.LegacyName, opt => opt.MapFrom(src => src.LegacyName))
            //    .ForMember(dest => dest.Ruta, opt => opt.MapFrom(src => src.Ruta))
            //    .ForMember(dest => dest.ImageUrl, opt => opt.MapFrom(src => src.ImageUrl))
            //    .ForMember(dest => dest.Lenguaje, opt => opt.MapFrom(src => src.Lenguaje))
            //    .ForMember(dest => dest.Orden, opt => opt.MapFrom(src => src.Orden))
            //    .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
            //    .ForMember(dest => dest.CreatedByOperatorId, opt => opt.MapFrom(src => src.CreatedByOperatorId))
            //    .ForMember(dest => dest.CreatedDateTime, opt => opt.MapFrom(src => src.CreatedDateTime))
            //    .ForMember(dest => dest.ModifiedByOperatorId, opt => opt.MapFrom(src => src.ModifiedByOperatorId))
            //    .ForMember(dest => dest.ModifiedDateTime, opt => opt.MapFrom(src => src.ModifiedDateTime));
            CreateMap<Menu, MenuItemsDto>().ReverseMap();

            // Si necesitas mapear desde VwMenu a MenuItemsDto (útil para actualizaciones)
            CreateMap<VwMenu, MenuItemsDto>()
                .ForMember(dest => dest.PkidMenu, opt => opt.MapFrom(src => src.PkidMenu))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Tipo, opt => opt.MapFrom(src => src.Tipo))
                .ForMember(dest => dest.FkidMenuSis, opt => opt.MapFrom(src => src.FkidMenuSis))
                .ForMember(dest => dest.LegacyName, opt => opt.MapFrom(src => src.LegacyName))
                .ForMember(dest => dest.Ruta, opt => opt.MapFrom(src => src.Ruta))
                .ForMember(dest => dest.ImageUrl, opt => opt.MapFrom(src => src.ImageUrl))
                .ForMember(dest => dest.Lenguaje, opt => opt.MapFrom(src => src.Lenguaje))
                .ForMember(dest => dest.Orden, opt => opt.MapFrom(src => src.Orden))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.CreatedByOperatorId, opt => opt.MapFrom(src => src.CreatedByOperatorId))
                .ForMember(dest => dest.CreatedDateTime, opt => opt.MapFrom(src => src.CreatedDateTime))
                .ForMember(dest => dest.ModifiedByOperatorId, opt => opt.MapFrom(src => src.ModifiedByOperatorId))
                .ForMember(dest => dest.ModifiedDateTime, opt => opt.MapFrom(src => src.ModifiedDateTime));
        }
    }
}

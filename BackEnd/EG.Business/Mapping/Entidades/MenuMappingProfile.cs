using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Mapping.Entidades
{
    public class MenuMappingProfile : Profile
    {
        public MenuMappingProfile()
        {
            // Mapeo de Request DTO a Entity
            CreateMap<MenuItemsDto, Menu>()
                .ForMember(dest => dest.PkidMenu, opt => opt.MapFrom(src => src.PkidMenu))
                .ForMember(dest => dest.FkidMenuSis, opt => opt.MapFrom(src => src.FkidMenuSis))
                .ReverseMap();

            // Mapeo de View a Response (con estructura jerárquica)
            CreateMap<VwMenu, MenuItemsResponse>()
                .ForMember(dest => dest.Children, opt => opt.Ignore()); // Los hijos se llenan manualmente

            // Mapeo de Entity a Response (para operaciones CRUD básicas)
            CreateMap<Menu, MenuItemsResponse>()
                .ForMember(dest => dest.PkidMenu, opt => opt.MapFrom(src => src.PkidMenu))
                .ForMember(dest => dest.FkidMenuSis, opt => opt.MapFrom(src => src.FkidMenuSis))
                .ForMember(dest => dest.NombreMenuPadre, opt => opt.Ignore())
                .ForMember(dest => dest.TipoDescripcion, opt => opt.MapFrom(src =>
                    src.Tipo == 1 ? "Contenedor" :
                    src.Tipo == 2 ? "Item final" : "Desconocido"))
                .ForMember(dest => dest.Estado, opt => opt.MapFrom(src =>
                    src.Activo ? "Activo" : "Inactivo"))
                .ForMember(dest => dest.NivelJerarquico, opt => opt.MapFrom(src =>
                    src.FkidMenuSis.HasValue ? 1 : 0))
                .ForMember(dest => dest.TieneSubmenus, opt => opt.Ignore())
                .ForMember(dest => dest.ValidacionEstructura, opt => opt.Ignore())
                .ForMember(dest => dest.RutaCompleta, opt => opt.Ignore())
                .ForMember(dest => dest.Children, opt => opt.Ignore());

            
        }
    }
}

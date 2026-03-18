using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Almacen
{
    public class BienMappingProfile : Profile
    {
        public BienMappingProfile()
        {
            // Mapeo bidireccional entre entidad Bien y su DTO de solicitud
            CreateMap<Bien, BienDto>().ReverseMap();

            // Mapeo de la vista VwBien al DTO de respuesta
            CreateMap<VwBien, BienResponse>();

            // Opcional: mapeo directo desde Bien (con includes) a BienResponse
            // Esto podría ser útil si se necesita usar la entidad directamente en lugar de la vista.
            
            CreateMap<Bien, BienResponse>()
                .ForMember(dest => dest.GrupoBienDescripcion, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.GrupoBienClave, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Clave : null))
                .ForMember(dest => dest.TipoBienCodigoClave, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.CodigoClave : null))
                .ForMember(dest => dest.TipoBienDescripcion, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.TipoBienCabms, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.Cabms : null))
                .ForMember(dest => dest.TipoBienIdentificador, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.Identificador : null))
                .ForMember(dest => dest.TipoBienCucopPlus, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.CucopPlus : null))
                .ForMember(dest => dest.AreaNombre, opt => opt.MapFrom(src => src.FkidAreaSisNavigation != null ? src.FkidAreaSisNavigation.Nombre : null))
                .ForMember(dest => dest.AreaClave, opt => opt.MapFrom(src => src.FkidAreaSisNavigation != null ? src.FkidAreaSisNavigation.Clave : null))
                .ForMember(dest => dest.ProveedorNombre, opt => opt.MapFrom(src => src.FkidProveedorSisNavigation != null ? src.FkidProveedorSisNavigation.Nombre : null))
                .ForMember(dest => dest.ProveedorRfc, opt => opt.MapFrom(src => src.FkidProveedorSisNavigation != null ? src.FkidProveedorSisNavigation.Rfc : null))
                .ForMember(dest => dest.ProveedorClave, opt => opt.MapFrom(src => src.FkidProveedorSisNavigation != null ? src.FkidProveedorSisNavigation.Clave : null))
                .ForMember(dest => dest.EstadoBienDescripcionGeneral, opt => opt.MapFrom(src => src.FkidEstadoBienAlmaNavigation != null ? src.FkidEstadoBienAlmaNavigation.DescripcionGeneral : null))
                .ForMember(dest => dest.EstadoBienDescripcionEspecifica, opt => opt.MapFrom(src => src.FkidEstadoBienAlmaNavigation != null ? src.FkidEstadoBienAlmaNavigation.DescripcionEspecifica : null))
                .ForMember(dest => dest.EstadoBienDescripcionCorta, opt => opt.MapFrom(src => src.FkidEstadoBienAlmaNavigation != null ? src.FkidEstadoBienAlmaNavigation.DescripcionCorta : null))
                .ForMember(dest => dest.TipoPatrimonioDescripcion, opt => opt.MapFrom(src => src.FkidTipoPatrimonioAlmaNavigation != null ? src.FkidTipoPatrimonioAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.MarcaDescripcion, opt => opt.MapFrom(src => src.FkidMarcaAlmaNavigation != null ? src.FkidMarcaAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.MaterialDescripcion, opt => opt.MapFrom(src => src.FkidMaterialAlmaNavigation != null ? src.FkidMaterialAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.TipoAdquisicionClave, opt => opt.MapFrom(src => src.FkidTipoAdqAlmaNavigation != null ? src.FkidTipoAdqAlmaNavigation.Clave : null))
                .ForMember(dest => dest.TipoAdquisicionDescripcion, opt => opt.MapFrom(src => src.FkidTipoAdqAlmaNavigation != null ? src.FkidTipoAdqAlmaNavigation.Descripcion : null))
                //.ForMember(dest => dest.tipoa, opt => opt.MapFrom(src => src.FkidTipoAdqAlmaNavigation != null ? src.FkidTipoAdqAlmaNavigation.DescripcionMovto : null))
                .ForMember(dest => dest.PartidaClave, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Clave : null))
                .ForMember(dest => dest.PartidaDescripcion, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Descripcion : null));
            
        }
    }
}

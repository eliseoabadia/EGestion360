using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaasdetalleMappingProfile : Profile
    {
        public PaaasdetalleMappingProfile()
        {
            CreateMap<Paaasdetalle, PaaasdetalleResponse>()
                .ForMember(dest => dest.TipoBienCodigoClave, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.CodigoClave : string.Empty))
                .ForMember(dest => dest.TipoBienDescripcion, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.CodigoClave + " - " + src.FkidTipoBienAlmaNavigation.Descripcion : string.Empty))
                .ForMember(dest => dest.Unidad, opt => opt.MapFrom(src => src.FkidUnidadesAlmaNavigation != null ? src.FkidUnidadesAlmaNavigation.Descripcion : string.Empty))
                .ReverseMap();

            CreateMap<VwPaaasdetalle, PaaasdetalleResponse>()
                .ForMember(dest => dest.TipoBienCodigoClave, opt => opt.MapFrom(src => src.TipoBienCodigoClave ?? string.Empty))
                .ForMember(dest => dest.TipoBienDescripcion, opt => opt.MapFrom(src => src.BienClaveNombre ?? string.Empty))
                .ForMember(dest => dest.Unidad, opt => opt.MapFrom(src => src.UnidadMedida ?? string.Empty));

            CreateMap<PaaasdetalleDto, Paaasdetalle>()
                .ForMember(dest => dest.PkidPaaasdetalle, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.EstudioMercadoDetalles, opt => opt.Ignore())
                .ForMember(dest => dest.FkidEmpresaSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPaaaspartidaOrcoNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidTipoBienAlmaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUnidadesAlmaNavigation, opt => opt.Ignore());
        }
    }
}

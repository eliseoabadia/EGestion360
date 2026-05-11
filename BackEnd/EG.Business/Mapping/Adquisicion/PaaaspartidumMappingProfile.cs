using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaaspartidumMappingProfile : Profile
    {
        public PaaaspartidumMappingProfile()
        {
            CreateMap<Paaaspartidum, PaaaspartidumResponse>()
                .ForMember(dest => dest.FkidPaaas, opt => opt.MapFrom(src => src.FkidPaaasOrco))
                .ForMember(dest => dest.FkidPaaasOrco, opt => opt.MapFrom(src => src.FkidPaaasOrco))
                .ForMember(dest => dest.ClavePartida, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Clave : src.FkidPartidaConta.ToString()))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Descripcion : string.Empty))
                .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Observaciones ?? string.Empty))
                .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => 0m))
                .ForMember(dest => dest.Cantidad, opt => opt.MapFrom(src => src.Paaasdetalles.Count(d => d.Activo)))
                .ForMember(dest => dest.Unidad, opt => opt.MapFrom(src => string.Empty))
                .ReverseMap();

            CreateMap<VwPaaaspartidum, PaaaspartidumResponse>()
                .ForMember(dest => dest.FkidPaaas, opt => opt.MapFrom(src => src.FkidPaaasOrco))
                .ForMember(dest => dest.FkidPaaasOrco, opt => opt.MapFrom(src => src.FkidPaaasOrco))
                .ForMember(dest => dest.ClavePartida, opt => opt.MapFrom(src => src.PartidaClave ?? string.Empty))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.PartidaDescripcion ?? string.Empty))
                .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Observaciones ?? string.Empty))
                .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => 0m))
                .ForMember(dest => dest.Cantidad, opt => opt.MapFrom(src => 0))
                .ForMember(dest => dest.Unidad, opt => opt.MapFrom(src => string.Empty));

            CreateMap<PaaaspartidaDto, Paaaspartidum>()
                .ForMember(dest => dest.PkidPaaaspartida, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidEmpresaSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPaaasOrcoNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPartidaContaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.Paaasdetalles, opt => opt.Ignore());
        }
    }
}

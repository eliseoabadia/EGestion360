using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class GrupoBienMappingProfile : Profile
    {
        public GrupoBienMappingProfile()
        {
            CreateMap<GrupoBien, GrupoBienDto>().ReverseMap();
            CreateMap<GrupoBien, GrupoBienResponse>()
                .ForMember(dest => dest.GrupoBienDescripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.GrupoBienClave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.FamiliaDescripcion, opt => opt.MapFrom(src => src.FkidFamiliaAlmaNavigation != null ? src.FkidFamiliaAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.FamiliaClave, opt => opt.MapFrom(src => src.FkidFamiliaAlmaNavigation != null ? src.FkidFamiliaAlmaNavigation.Clave : null));
            CreateMap<VwGrupoBien, GrupoBienResponse>()
                .ForMember(dest => dest.GrupoBienDescripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.GrupoBienClave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.FamiliaDescripcion, opt => opt.MapFrom(src => src.FamiliaDescripcion))
                .ForMember(dest => dest.FamiliaClave, opt => opt.MapFrom(src => src.FamiliaClave));
            CreateMap<GrupoBienResponse, GrupoBienDto>()
                .ForMember(dest => dest.PkidGrupoBien, opt => opt.Ignore())
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.GrupoBienDescripcion))
                .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.GrupoBienClave))
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

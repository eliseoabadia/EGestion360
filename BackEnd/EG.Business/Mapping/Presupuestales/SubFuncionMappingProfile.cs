using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class SubFuncionMappingProfile : Profile
    {
        public SubFuncionMappingProfile()
        {
            CreateMap<Sf, SubFuncionDto>().ReverseMap();
            CreateMap<Sf, SubFuncionResponse>()
                .ForMember(dest => dest.SubFuncionClave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.SubFuncionDescripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.FuncionClave, opt => opt.MapFrom(src => src.FkidFnPresNavigation != null ? src.FkidFnPresNavigation.Clave : (int?)null))
                .ForMember(dest => dest.FuncionDescripcion, opt => opt.MapFrom(src => src.FkidFnPresNavigation != null ? src.FkidFnPresNavigation.Descripcion : null))
                .ForMember(dest => dest.SubFuncionClaveNombre, opt => opt.Ignore())
                .ForMember(dest => dest.FuncionClaveNombre, opt => opt.Ignore());
            CreateMap<VwSubFuncion, SubFuncionDto>()
                .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.SubFuncionClave))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.SubFuncionDescripcion))
                .ForMember(dest => dest.PkidSf, opt => opt.Ignore());
            CreateMap<VwSubFuncion, SubFuncionResponse>();
            CreateMap<SubFuncionResponse, SubFuncionDto>()
                .ForMember(dest => dest.PkidSf, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

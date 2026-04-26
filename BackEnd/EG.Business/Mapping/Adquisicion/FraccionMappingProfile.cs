using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class FraccionMappingProfile : Profile
    {
        public FraccionMappingProfile()
        {
            CreateMap<Fraccion, FraccionDto>().ReverseMap();
            CreateMap<Fraccion, FraccionResponse>()
                .ForMember(dest => dest.NombreArticulo, opt => opt.MapFrom(src => src.FkidArticuloOrcoNavigation != null ? src.FkidArticuloOrcoNavigation.Descripcion : string.Empty));
            CreateMap<FraccionResponse, FraccionDto>()
                .ForMember(dest => dest.PkidFraccion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidArticuloOrco, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ArticuloMappingProfile : Profile
    {
        public ArticuloMappingProfile()
        {
            CreateMap<Articulo, ArticuloDto>().ReverseMap();
            CreateMap<Articulo, ArticuloResponse>();
            CreateMap<ArticuloResponse, ArticuloDto>()
                .ForMember(dest => dest.PkidArticulo, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
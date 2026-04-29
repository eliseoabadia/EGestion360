using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class AniosMappingProfile : Profile
    {
        public AniosMappingProfile()
        {
            CreateMap<Anio, AniosDto>().ReverseMap();
            CreateMap<Anio, AniosResponse>();
            CreateMap<AniosResponse, AniosDto>()
                .ForMember(dest => dest.PkidAnio, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

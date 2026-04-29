using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class SectorMappingProfile : Profile
    {
        public SectorMappingProfile()
        {
            CreateMap<Sector, SectorDto>().ReverseMap();
            CreateMap<Sector, SectorResponse>();
            CreateMap<SectorResponse, SectorDto>()
                .ForMember(dest => dest.PkidSector, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

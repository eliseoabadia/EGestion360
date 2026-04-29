using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class RamoMappingProfile : Profile
    {
        public RamoMappingProfile()
        {
            CreateMap<Ramo, RamoDto>().ReverseMap();
            CreateMap<Ramo, RamoResponse>();
            CreateMap<RamoResponse, RamoDto>()
                .ForMember(dest => dest.PkidRamo, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

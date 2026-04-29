using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ActividadInstitucionalMappingProfile : Profile
    {
        public ActividadInstitucionalMappingProfile()
        {
            CreateMap<ActividadInstitucional, ActividadInstitucionalDto>().ReverseMap();
            CreateMap<ActividadInstitucional, ActividadInstitucionalResponse>();
            CreateMap<ActividadInstitucionalResponse, ActividadInstitucionalDto>()
                .ForMember(dest => dest.PkidActividadInstitucional, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

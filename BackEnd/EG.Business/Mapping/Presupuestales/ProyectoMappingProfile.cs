using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ProyectoMappingProfile : Profile
    {
        public ProyectoMappingProfile()
        {
            CreateMap<Proyecto, ProyectoDto>().ReverseMap();
            CreateMap<Proyecto, ProyectoResponse>();
            CreateMap<ProyectoResponse, ProyectoDto>()
                .ForMember(dest => dest.PkidProyecto, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

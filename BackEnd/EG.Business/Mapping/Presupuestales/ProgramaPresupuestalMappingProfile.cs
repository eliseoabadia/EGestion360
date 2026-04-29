using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ProgramaPresupuestalMappingProfile : Profile
    {
        public ProgramaPresupuestalMappingProfile()
        {
            CreateMap<Pp, ProgramaPresupuestalDto>().ReverseMap();
            CreateMap<Pp, ProgramaPresupuestalResponse>();
            CreateMap<ProgramaPresupuestalResponse, ProgramaPresupuestalDto>()
                .ForMember(dest => dest.PkidPp, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

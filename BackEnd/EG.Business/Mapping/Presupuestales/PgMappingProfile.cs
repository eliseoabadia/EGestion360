using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class PgMappingProfile : Profile
    {
        public PgMappingProfile()
        {
            CreateMap<Pg, PgDto>().ReverseMap();
            CreateMap<Pg, PgResponse>();
            CreateMap<PgResponse, PgDto>()
                .ForMember(dest => dest.PkidPg, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

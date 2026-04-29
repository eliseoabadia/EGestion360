using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class TipoRecursoMappingProfile : Profile
    {
        public TipoRecursoMappingProfile()
        {
            CreateMap<TipoRecurso, TipoRecursoDto>().ReverseMap();
            CreateMap<TipoRecurso, TipoRecursoResponse>();
            CreateMap<TipoRecursoResponse, TipoRecursoDto>()
                .ForMember(dest => dest.PkidTipoRecurso, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

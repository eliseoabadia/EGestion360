using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class NivelMappingProfile : Profile
    {
        public NivelMappingProfile()
        {
            CreateMap<Nivel, NivelDto>().ReverseMap();
            CreateMap<Nivel, NivelResponse>().ReverseMap();
        }
    }
}

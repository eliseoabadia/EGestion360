using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class GrupoFuncionalMappingProfile : Profile
    {
        public GrupoFuncionalMappingProfile()
        {
            CreateMap<Gf, GfResponse>().ReverseMap();
            CreateMap<Gf, GfDto>().ReverseMap();
        }
    }
}

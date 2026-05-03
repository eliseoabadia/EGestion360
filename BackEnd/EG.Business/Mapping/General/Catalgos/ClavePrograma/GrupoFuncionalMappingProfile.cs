using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General.Catalgos.ClavePrograma
{
    public class ClaveProgramaMappingProfile : Profile
    {
        public ClaveProgramaMappingProfile()
        {
            // Mapeo bidireccional entre entidad y DTO
            CreateMap<Gf, GfDto>().ReverseMap();

            // Mapeo bidireccional entre entidad y Response
            CreateMap<Gf, GfResponse>().ReverseMap();

            // Mapeo directo entre DTO y Response (si alguna vez lo necesitas)
            CreateMap<GfDto, GfResponse>().ReverseMap();
        }
    }
}

using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class FinalidadMappingProfile : Profile
    {
        public FinalidadMappingProfile()
        {
            CreateMap<Fn, FnResponse>().ReverseMap();
            CreateMap<Fn, FnDto>().ReverseMap();
        }
    }
}

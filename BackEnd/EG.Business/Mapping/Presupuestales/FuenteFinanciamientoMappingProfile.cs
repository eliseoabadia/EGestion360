using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class FuenteFinanciamientoMappingProfile : Profile
    {
        public FuenteFinanciamientoMappingProfile()
        {
            CreateMap<FuenteFinanciamiento, FuenteFinanciamientoDto>().ReverseMap();
            CreateMap<FuenteFinanciamiento, FuenteFinanciamientoResponse>();
            CreateMap<FuenteFinanciamientoResponse, FuenteFinanciamientoDto>()
                .ForMember(dest => dest.PkidFuenteFinanciamiento, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

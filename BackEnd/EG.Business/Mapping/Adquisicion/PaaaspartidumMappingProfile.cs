using AutoMapper;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaaspartidumMappingProfile : Profile
    {
        public PaaaspartidumMappingProfile()
        {
            CreateMap<Paaaspartidum, PaaaspartidumResponse>()
                .ForMember(dest => dest.ClavePartida, opt => opt.MapFrom(src => src.PkidPaaaspartida.ToString()))
                .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => src.PkidPaaaspartida))
                .ForMember(dest => dest.Cantidad, opt => opt.MapFrom(src => src.PkidPaaaspartida))
                .ForMember(dest => dest.Unidad, opt => opt.MapFrom(src => "PIEZA"))
                .ReverseMap();
        }
    }
}

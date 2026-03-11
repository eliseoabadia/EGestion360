using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class RegistroConteoMappingProfile : Profile
    {
        public RegistroConteoMappingProfile()
        {

            // RegistroConteo <-> RegistroConteoDto
            CreateMap<RegistroConteo, RegistroConteoDto>()
                .ReverseMap()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore());

            // RegistroConteo -> RegistroConteoResponse
            CreateMap<RegistroConteo, RegistroConteoResponse>();

            // VwRegistroConteo -> RegistroConteoDto
            CreateMap<VwRegistroConteo, RegistroConteoDto>()
                .ForMember(dest => dest.PkidRegistroConteo, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.FkidArticuloConteoAlma, opt => opt.MapFrom(src => src.ArticuloConteoId))
                .ForMember(dest => dest.FkidPeriodoConteoAlma, opt => opt.MapFrom(src => src.PeriodoId))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.SucursalId))
                .ForMember(dest => dest.FkidUsuarioSis, opt => opt.MapFrom(src => src.UsuarioId))
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore());

            // VwRegistroConteo -> VwRegistroConteoResponse
            CreateMap<VwRegistroConteo, VwRegistroConteoResponse>();

        }


    }
}

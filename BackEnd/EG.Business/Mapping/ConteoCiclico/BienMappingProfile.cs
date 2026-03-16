using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class BienMappingProfile : Profile
    {
        public BienMappingProfile()
        {
            // Bien <-> BienDto
            CreateMap<Bien, BienDto>()
                .ReverseMap()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore());

            // Bien -> BienResponse
            CreateMap<Bien, BienResponse>();

            // VwBien -> BienDto
            CreateMap<VwBien, BienDto>()
                .ForMember(dest => dest.PkidBien, opt => opt.MapFrom(src => src.PkidBien))
                .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.Clave))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion));

            // VwBien -> BienResponse
            CreateMap<VwBien, BienResponse>();
        }
    }
}

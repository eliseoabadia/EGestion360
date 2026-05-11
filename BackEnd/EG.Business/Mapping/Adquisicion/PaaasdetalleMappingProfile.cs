using AutoMapper;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaasdetalleMappingProfile : Profile
    {
        public PaaasdetalleMappingProfile()
        {
            CreateMap<Paaasdetalle, PaaasdetalleResponse>()
                .ForMember(dest => dest.TipoBienDescripcion, opt => opt.MapFrom(src => src.FkidTipoBienAlmaNavigation.Descripcion))
                .ForMember(dest => dest.Unidad, opt => opt.MapFrom(src => src.FkidUnidadesAlmaNavigation.Descripcion))
                .ReverseMap();
        }
    }
}

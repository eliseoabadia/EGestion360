using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class ConteoDetalleMappingProfile : Profile
{
    public ConteoDetalleMappingProfile()
    {
        CreateMap<ConteoDetalle, ConteoDetalleDto>().ReverseMap();

        CreateMap<VwBien, BienResponse>()
            .ForMember(dest => dest.PkidBien, opt => opt.MapFrom(src => src.PkidBien))
            .ForMember(dest => dest.Clave, opt => opt.MapFrom(src => src.Clave))
            .ForMember(dest => dest.ClaveAnt, opt => opt.MapFrom(src => src.ClaveAnt))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
            .ForMember(dest => dest.Modelo, opt => opt.MapFrom(src => src.Modelo))
            .ForMember(dest => dest.Serie, opt => opt.MapFrom(src => src.Serie))
            .ForMember(dest => dest.Costo, opt => opt.MapFrom(src => src.Costo))
            .ForMember(dest => dest.FechaAdq, opt => opt.MapFrom(src => src.FechaAdq))
            .ForMember(dest => dest.Factura, opt => opt.MapFrom(src => src.Factura))
            .ForMember(dest => dest.Ubicacion, opt => opt.MapFrom(src => src.Ubicacion))
            .ForMember(dest => dest.Estatus, opt => opt.MapFrom(src => src.Estatus))
            .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
            .ForMember(dest => dest.GrupoBienDescripcion, opt => opt.MapFrom(src => src.GrupoBienDescripcion))
            .ForMember(dest => dest.GrupoBienClave, opt => opt.MapFrom(src => src.GrupoBienClave))
            .ForMember(dest => dest.TipoBienCodigoClave, opt => opt.MapFrom(src => src.TipoBienCodigoClave))
            .ForMember(dest => dest.TipoBienDescripcion, opt => opt.MapFrom(src => src.TipoBienDescripcion))
            .ForMember(dest => dest.MarcaDescripcion, opt => opt.MapFrom(src => src.MarcaDescripcion))
            .ForMember(dest => dest.EstadoBienDescripcionGeneral, opt => opt.MapFrom(src => src.EstadoBienDescripcionGeneral));
    }
}

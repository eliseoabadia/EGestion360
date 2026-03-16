using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class RegistroConteoMappingProfile : Profile
    {
        public RegistroConteoMappingProfile()
        {

            // Mapeo de Entidad a DTO
            CreateMap<RegistroConteo, RegistroConteoDto>().ReverseMap();

            // Mapeo de Vista a Response
            CreateMap<VwRegistroConteo, RegistroConteoResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.ArticuloConteoId, opt => opt.MapFrom(src => src.ArticuloConteoId))
                .ForMember(dest => dest.PeriodoId, opt => opt.MapFrom(src => src.PeriodoId))
                .ForMember(dest => dest.SucursalId, opt => opt.MapFrom(src => src.SucursalId))
                .ForMember(dest => dest.CodigoPeriodo, opt => opt.MapFrom(src => src.CodigoPeriodo))
                .ForMember(dest => dest.PeriodoNombre, opt => opt.MapFrom(src => src.PeriodoNombre))
                .ForMember(dest => dest.SucursalNombre, opt => opt.MapFrom(src => src.SucursalNombre))
                .ForMember(dest => dest.TipoBienId, opt => opt.MapFrom(src => src.TipoBienId))
                .ForMember(dest => dest.CodigoArticulo, opt => opt.MapFrom(src => src.CodigoArticulo))
                .ForMember(dest => dest.DescripcionArticulo, opt => opt.MapFrom(src => src.DescripcionArticulo))
                .ForMember(dest => dest.ExistenciaSistema, opt => opt.MapFrom(src => src.ExistenciaSistema))
                .ForMember(dest => dest.NumeroConteo, opt => opt.MapFrom(src => src.NumeroConteo))
                .ForMember(dest => dest.CantidadContada, opt => opt.MapFrom(src => src.CantidadContada))
                .ForMember(dest => dest.FechaConteo, opt => opt.MapFrom(src => src.FechaConteo))
                .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Observaciones))
                .ForMember(dest => dest.EsReconteo, opt => opt.MapFrom(src => src.EsReconteo))
                .ForMember(dest => dest.FotoPath, opt => opt.MapFrom(src => src.FotoPath))
                .ForMember(dest => dest.Latitud, opt => opt.MapFrom(src => src.Latitud))
                .ForMember(dest => dest.Longitud, opt => opt.MapFrom(src => src.Longitud))
                .ForMember(dest => dest.UsuarioId, opt => opt.MapFrom(src => src.UsuarioId))
                .ForMember(dest => dest.UsuarioNombre, opt => opt.MapFrom(src => src.UsuarioNombre))
                .ForMember(dest => dest.UsuarioEmail, opt => opt.MapFrom(src => src.UsuarioEmail))
                .ForMember(dest => dest.UsuarioIniciales, opt => opt.MapFrom(src => src.UsuarioIniciales))
                .ForMember(dest => dest.PromedioConteos, opt => opt.MapFrom(src => src.PromedioConteos))
                .ForMember(dest => dest.DiferenciaVsSistema, opt => opt.MapFrom(src => src.DiferenciaVsSistema))
                .ForMember(dest => dest.PorcentajeVsSistema, opt => opt.MapFrom(src => src.PorcentajeVsSistema))
                .ForMember(dest => dest.ConteoDescripcion, opt => opt.MapFrom(src => src.ConteoDescripcion))
                .ForMember(dest => dest.ColorConteo, opt => opt.MapFrom(src => src.ColorConteo))
                .ForMember(dest => dest.IconoConteo, opt => opt.MapFrom(src => src.IconoConteo))
                .ForMember(dest => dest.EsUltimoConteo, opt => opt.MapFrom(src => src.EsUltimoConteo))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion));

            // Si necesitas mapear de DTO a Entidad (para actualizaciones), ya está cubierto por el ReverseMap inicial.

        }


    }
}

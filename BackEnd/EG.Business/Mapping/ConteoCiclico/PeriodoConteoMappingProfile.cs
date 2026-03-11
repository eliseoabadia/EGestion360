using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class PeriodoConteoMappingProfile : Profile
    {
        public PeriodoConteoMappingProfile()
        {

            // PeriodoConteo <-> PeriodoConteoDto
            CreateMap<PeriodoConteo, PeriodoConteoDto>()
                .ReverseMap()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore());

            // PeriodoConteo -> VwPeriodoConteoResponse (si se requiere desde entidad)
            CreateMap<PeriodoConteo, VwPeriodoConteoResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.SucursalId, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.TipoConteoId, opt => opt.MapFrom(src => src.FkidTipoConteoAlma))
                .ForMember(dest => dest.EstatusId, opt => opt.MapFrom(src => src.FkidEstatusAlma))
                .ForMember(dest => dest.ResponsableId, opt => opt.MapFrom(src => src.FkidResponsableSis))
                .ForMember(dest => dest.SupervisorId, opt => opt.MapFrom(src => src.FkidSupervisorSis))
                //.ForMember(dest => dest.UsuarioCreacionNombre, opt => opt.Ignore())  // Se obtiene de navegación
                //.ForMember(dest => dest.UsuarioModificacionNombre, opt => opt.Ignore())
                ;

            // VwPeriodoConteo (vista) -> PeriodoConteoDto (para inputs de creación/actualización)
            CreateMap<VwPeriodoConteo, PeriodoConteoDto>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.SucursalId))
                .ForMember(dest => dest.FkidTipoConteoAlma, opt => opt.MapFrom(src => src.TipoConteoId))
                .ForMember(dest => dest.FkidEstatusAlma, opt => opt.MapFrom(src => src.EstatusId))
                .ForMember(dest => dest.FkidResponsableSis, opt => opt.MapFrom(src => src.ResponsableId))
                .ForMember(dest => dest.FkidSupervisorSis, opt => opt.MapFrom(src => src.SupervisorId))
                //.ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                //.ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                //.ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                //.ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                ;

            // VwPeriodoConteo -> VwPeriodoConteoResponse (directo)
            CreateMap<VwPeriodoConteo, VwPeriodoConteoResponse>();


        }
    }
}

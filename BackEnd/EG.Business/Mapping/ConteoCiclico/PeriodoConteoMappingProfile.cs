using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class PeriodoConteoMappingProfile : Profile
    {
        public PeriodoConteoMappingProfile()
        {

            // Mapeo de Entidad a DTO y viceversa
            CreateMap<PeriodoConteo, PeriodoConteoDto>().ReverseMap();

            // Mapeo de Vista a Response
            CreateMap<VwPeriodoConteo, PeriodoConteoResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.SucursalId, opt => opt.MapFrom(src => src.SucursalId))
                .ForMember(dest => dest.SucursalNombre, opt => opt.MapFrom(src => src.SucursalNombre))
                .ForMember(dest => dest.TipoConteoId, opt => opt.MapFrom(src => src.TipoConteoId))
                .ForMember(dest => dest.TipoConteoNombre, opt => opt.MapFrom(src => src.TipoConteoNombre))
                .ForMember(dest => dest.EstatusId, opt => opt.MapFrom(src => src.EstatusId))
                .ForMember(dest => dest.EstatusNombre, opt => opt.MapFrom(src => src.EstatusNombre))
                .ForMember(dest => dest.CodigoPeriodo, opt => opt.MapFrom(src => src.CodigoPeriodo))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.FechaInicio, opt => opt.MapFrom(src => src.FechaInicio))
                .ForMember(dest => dest.FechaFin, opt => opt.MapFrom(src => src.FechaFin))
                .ForMember(dest => dest.FechaCierre, opt => opt.MapFrom(src => src.FechaCierre))
                .ForMember(dest => dest.MaximoConteosPorArticulo, opt => opt.MapFrom(src => src.MaximoConteosPorArticulo))
                .ForMember(dest => dest.RequiereAprobacionSupervisor, opt => opt.MapFrom(src => src.RequiereAprobacionSupervisor))
                .ForMember(dest => dest.ResponsableId, opt => opt.MapFrom(src => src.ResponsableId))
                .ForMember(dest => dest.ResponsableNombre, opt => opt.MapFrom(src => src.ResponsableNombre))
                .ForMember(dest => dest.SupervisorId, opt => opt.MapFrom(src => src.SupervisorId))
                .ForMember(dest => dest.SupervisorNombre, opt => opt.MapFrom(src => src.SupervisorNombre))
                .ForMember(dest => dest.TotalArticulos, opt => opt.MapFrom(src => src.TotalArticulos))
                .ForMember(dest => dest.ArticulosConcluidos, opt => opt.MapFrom(src => src.ArticulosConcluidos))
                .ForMember(dest => dest.ArticulosConDiferencia, opt => opt.MapFrom(src => src.ArticulosConDiferencia))
                .ForMember(dest => dest.ArticulosPendientes, opt => opt.MapFrom(src => src.ArticulosPendientes))
                .ForMember(dest => dest.PorcentajeAvance, opt => opt.MapFrom(src => src.PorcentajeAvance))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacionNombre, opt => opt.MapFrom(src => src.UsuarioCreacionNombre))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacionNombre, opt => opt.MapFrom(src => src.UsuarioModificacionNombre));

            // Si también se necesita mapear de DTO a Response para algún caso especial, se puede agregar.
            // Por ahora, con estos mappings es suficiente.


        }
    }
}

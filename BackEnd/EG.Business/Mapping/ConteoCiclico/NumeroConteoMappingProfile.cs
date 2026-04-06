using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class NumeroConteoMappingProfile : Profile
    {
        public NumeroConteoMappingProfile()
        {
            // ==================== TIPO CONTEO ====================
            CreateMap<TipoConteo, TipoConteoDto>().ReverseMap();
            CreateMap<TipoConteo, TipoConteoResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PkidTipoConteo));

            // ==================== VISTA -> RESPONSE (consultas) ====================
            CreateMap<VwPeriodoConteo, NumeroConteoResponse>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.CodigoPeriodo, opt => opt.MapFrom(src => src.CodigoPeriodo))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.FechaInicio, opt => opt.MapFrom(src => src.FechaInicio))
                .ForMember(dest => dest.FechaFin, opt => opt.MapFrom(src => src.FechaFin))
                .ForMember(dest => dest.FechaCierre, opt => opt.MapFrom(src => src.FechaCierre))
                .ForMember(dest => dest.MaximoConteosPorArticulo, opt => opt.MapFrom(src => src.MaximoConteosPorArticulo))
                .ForMember(dest => dest.RequiereAprobacionSupervisor, opt => opt.MapFrom(src => src.RequiereAprobacionSupervisor))
                .ForMember(dest => dest.TotalArticulos, opt => opt.MapFrom(src => src.TotalArticulos))
                .ForMember(dest => dest.ArticulosConcluidos, opt => opt.MapFrom(src => src.ArticulosConcluidos))
                .ForMember(dest => dest.ArticulosConDiferencia, opt => opt.MapFrom(src => src.ArticulosConDiferencia))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.IdSucursal, opt => opt.MapFrom(src => src.IdSucursal))
                .ForMember(dest => dest.Sucursal, opt => opt.MapFrom(src => src.Sucursal))
                .ForMember(dest => dest.IdTipoConteo, opt => opt.MapFrom(src => src.IdTipoConteo))
                .ForMember(dest => dest.TipoConteo, opt => opt.MapFrom(src => src.TipoConteo))
                .ForMember(dest => dest.DescripcionTipoConteo, opt => opt.MapFrom(src => src.DescripcionTipoConteo))
                .ForMember(dest => dest.IdEstatusPeriodo, opt => opt.MapFrom(src => src.IdEstatusPeriodo))
                .ForMember(dest => dest.EstatusPeriodo, opt => opt.MapFrom(src => src.EstatusPeriodo))
                .ForMember(dest => dest.DescripcionEstatusPeriodo, opt => opt.MapFrom(src => src.DescripcionEstatusPeriodo))
                .ForMember(dest => dest.IdResponsable, opt => opt.MapFrom(src => src.IdResponsable))
                .ForMember(dest => dest.Responsable, opt => opt.MapFrom(src => src.Responsable))
                .ForMember(dest => dest.IdSupervisor, opt => opt.MapFrom(src => src.IdSupervisor))
                .ForMember(dest => dest.Supervisor, opt => opt.MapFrom(src => src.Supervisor));

            // Response -> DTO (para creación/actualización)
            CreateMap<NumeroConteoResponse, NumeroConteoDto>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.IdSucursal))
                .ForMember(dest => dest.FkidTipoConteoAlma, opt => opt.MapFrom(src => src.IdTipoConteo))
                .ForMember(dest => dest.FkidEstatusAlma, opt => opt.MapFrom(src => src.IdEstatusPeriodo))
                .ForMember(dest => dest.CodigoPeriodo, opt => opt.MapFrom(src => src.CodigoPeriodo))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.FechaInicio, opt => opt.MapFrom(src => src.FechaInicio))
                .ForMember(dest => dest.FechaFin, opt => opt.MapFrom(src => src.FechaFin))
                .ForMember(dest => dest.FechaCierre, opt => opt.MapFrom(src => src.FechaCierre))
                .ForMember(dest => dest.MaximoConteosPorArticulo, opt => opt.MapFrom(src => src.MaximoConteosPorArticulo))
                .ForMember(dest => dest.RequiereAprobacionSupervisor, opt => opt.MapFrom(src => src.RequiereAprobacionSupervisor))
                .ForMember(dest => dest.FkidResponsableSis, opt => opt.MapFrom(src => src.IdResponsable))
                .ForMember(dest => dest.FkidSupervisorSis, opt => opt.MapFrom(src => src.IdSupervisor))
                .ForMember(dest => dest.TotalArticulos, opt => opt.MapFrom(src => src.TotalArticulos))
                .ForMember(dest => dest.ArticulosConcluidos, opt => opt.MapFrom(src => src.ArticulosConcluidos))
                .ForMember(dest => dest.ArticulosConDiferencia, opt => opt.MapFrom(src => src.ArticulosConDiferencia))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                // Las propiedades descriptivas (Sucursal, TipoConteo, etc.) se ignoran porque no existen en el DTO
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));

            // DTO -> Entidad (para persistencia)
            CreateMap<NumeroConteoDto, PeriodoConteo>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.FkidTipoConteoAlma, opt => opt.MapFrom(src => src.FkidTipoConteoAlma))
                .ForMember(dest => dest.FkidEstatusAlma, opt => opt.MapFrom(src => src.FkidEstatusAlma))
                .ForMember(dest => dest.CodigoPeriodo, opt => opt.MapFrom(src => src.CodigoPeriodo))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.FechaInicio, opt => opt.MapFrom(src => src.FechaInicio))
                .ForMember(dest => dest.FechaFin, opt => opt.MapFrom(src => src.FechaFin))
                .ForMember(dest => dest.FechaCierre, opt => opt.MapFrom(src => src.FechaCierre))
                .ForMember(dest => dest.MaximoConteosPorArticulo, opt => opt.MapFrom(src => src.MaximoConteosPorArticulo))
                .ForMember(dest => dest.RequiereAprobacionSupervisor, opt => opt.MapFrom(src => src.RequiereAprobacionSupervisor))
                .ForMember(dest => dest.FkidResponsableSis, opt => opt.MapFrom(src => src.FkidResponsableSis))
                .ForMember(dest => dest.FkidSupervisorSis, opt => opt.MapFrom(src => src.FkidSupervisorSis))
                .ForMember(dest => dest.TotalArticulos, opt => opt.MapFrom(src => src.TotalArticulos))
                .ForMember(dest => dest.ArticulosConcluidos, opt => opt.MapFrom(src => src.ArticulosConcluidos))
                .ForMember(dest => dest.ArticulosConDiferencia, opt => opt.MapFrom(src => src.ArticulosConDiferencia))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion));

            // Opcional: si se necesita mapeo inverso de Entidad -> DTO
            CreateMap<PeriodoConteo, NumeroConteoDto>();

            // PeriodoConteo -> NumeroConteoResponse (para respuestas desde la entidad)
            CreateMap<PeriodoConteo, NumeroConteoResponse>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.CodigoPeriodo, opt => opt.MapFrom(src => src.CodigoPeriodo))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.FechaInicio, opt => opt.MapFrom(src => src.FechaInicio))
                .ForMember(dest => dest.FechaFin, opt => opt.MapFrom(src => src.FechaFin))
                .ForMember(dest => dest.FechaCierre, opt => opt.MapFrom(src => src.FechaCierre))
                .ForMember(dest => dest.MaximoConteosPorArticulo, opt => opt.MapFrom(src => src.MaximoConteosPorArticulo))
                .ForMember(dest => dest.RequiereAprobacionSupervisor, opt => opt.MapFrom(src => src.RequiereAprobacionSupervisor))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.IdSucursal, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.IdTipoConteo, opt => opt.MapFrom(src => src.FkidTipoConteoAlma))
                .ForMember(dest => dest.IdEstatusPeriodo, opt => opt.MapFrom(src => src.FkidEstatusAlma))
                .ForMember(dest => dest.IdResponsable, opt => opt.MapFrom(src => src.FkidResponsableSis))
                .ForMember(dest => dest.IdSupervisor, opt => opt.MapFrom(src => src.FkidSupervisorSis));
        }
    }
}

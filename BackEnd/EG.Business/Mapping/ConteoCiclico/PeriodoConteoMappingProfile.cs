using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class PeriodoConteoMappingProfile : Profile
    {
        public PeriodoConteoMappingProfile()
        {

            // Mapeo de PeriodoConteo (entidad) a PeriodoConteoResponse
            CreateMap<PeriodoConteo, PeriodoConteoResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.SucursalId, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.SucursalNombre, opt => opt.MapFrom(src => src.FkidSucursalSisNavigation != null ? src.FkidSucursalSisNavigation.Nombre : null))
                .ForMember(dest => dest.TipoConteoId, opt => opt.MapFrom(src => src.FkidTipoConteoAlma))
                .ForMember(dest => dest.TipoConteoNombre, opt => opt.MapFrom(src => src.FkidTipoConteoAlmaNavigation != null ? src.FkidTipoConteoAlmaNavigation.Nombre : null))
                .ForMember(dest => dest.EstatusId, opt => opt.MapFrom(src => src.FkidEstatusAlma))
                .ForMember(dest => dest.EstatusNombre, opt => opt.MapFrom(src => src.FkidEstatusAlmaNavigation != null ? src.FkidEstatusAlmaNavigation.Nombre : null))
                .ForMember(dest => dest.ResponsableId, opt => opt.MapFrom(src => src.FkidResponsableSis))
                .ForMember(dest => dest.ResponsableNombre, opt => opt.MapFrom(src => src.FkidResponsableSisNavigation != null ?
                    $"{src.FkidResponsableSisNavigation.Nombre} {src.FkidResponsableSisNavigation.ApellidoPaterno}" : null))
                .ForMember(dest => dest.SupervisorId, opt => opt.MapFrom(src => src.FkidSupervisorSis))
                .ForMember(dest => dest.SupervisorNombre, opt => opt.MapFrom(src => src.FkidSupervisorSisNavigation != null ?
                    $"{src.FkidSupervisorSisNavigation.Nombre} {src.FkidSupervisorSisNavigation.ApellidoPaterno}" : null))
                //.ForMember(dest => dest.UsuarioCreacionNombre, opt => opt.MapFrom(src => src.UsuarioCreacionNavigation != null ?
                //    $"{src.UsuarioCreacionNavigation.Nombre} {src.UsuarioCreacionNavigation.ApellidoPaterno}" : null))
                //.ForMember(dest => dest.UsuarioModificacionNombre, opt => opt.MapFrom(src => src.UsuarioModificacionNavigation != null ?
                //    $"{src.UsuarioModificacionNavigation.Nombre} {src.UsuarioModificacionNavigation.ApellidoPaterno}" : null))
                .ForMember(dest => dest.ArticulosPendientes, opt => opt.MapFrom(src =>
                    src.TotalArticulos - src.ArticulosConcluidos - src.ArticulosConDiferencia)) // Cálculo simple
                .ForMember(dest => dest.PorcentajeAvance, opt => opt.MapFrom(src =>
                    src.TotalArticulos > 0 ? (decimal)(src.ArticulosConcluidos + src.ArticulosConDiferencia) / src.TotalArticulos * 100 : 0));

            // Mapeo de VwPeriodoConteo (vista) a PeriodoConteoResponse (directo, ya que la vista tiene todos los campos)
            CreateMap<VwPeriodoConteo, PeriodoConteoResponse>();

            // Mapeo de PeriodoConteoDto a PeriodoConteo (para crear/actualizar)
            CreateMap<PeriodoConteoDto, PeriodoConteo>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.Ignore()) // ID autogenerado
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
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore()) // Se asigna en el servicio/repositorio
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.ArticuloConteos, opt => opt.Ignore()) // Colecciones
                .ForMember(dest => dest.RegistroConteos, opt => opt.Ignore())
                .ForMember(dest => dest.FkidSucursalSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidTipoConteoAlmaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidEstatusAlmaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidResponsableSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidSupervisorSisNavigation, opt => opt.Ignore());

            // Mapeo inverso (PeriodoConteo a PeriodoConteoDto) si es necesario
            CreateMap<PeriodoConteo, PeriodoConteoDto>()
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

            // Mapeo de PeriodoConteoResponse a PeriodoConteoDto (para actualizaciones desde el frontend)
            CreateMap<PeriodoConteoResponse, PeriodoConteoDto>()
                .ForMember(dest => dest.PkidPeriodoConteo, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.SucursalId))
                .ForMember(dest => dest.FkidTipoConteoAlma, opt => opt.MapFrom(src => src.TipoConteoId))
                .ForMember(dest => dest.FkidEstatusAlma, opt => opt.MapFrom(src => src.EstatusId))
                .ForMember(dest => dest.FkidResponsableSis, opt => opt.MapFrom(src => src.ResponsableId))
                .ForMember(dest => dest.FkidSupervisorSis, opt => opt.MapFrom(src => src.SupervisorId))
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
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore());


        }
    }
}

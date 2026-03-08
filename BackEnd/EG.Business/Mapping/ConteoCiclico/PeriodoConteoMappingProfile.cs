using AutoMapper;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class PeriodoConteoMappingProfile : Profile
    {
        public PeriodoConteoMappingProfile()
        {

            // PeriodoConteo mappings
            CreateMap<PeriodoConteo, PeriodoConteoDto>()
                .ReverseMap();

            CreateMap<VwPeriodoConteo, VwPeriodoConteoResponse>()
                .ReverseMap();

            CreateMap<PeriodoConteo, VwPeriodoConteoResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PkidPeriodoConteo))
                .ForMember(dest => dest.SucursalId, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.SucursalNombre, opt => opt.MapFrom(src =>
                    src.FkidSucursalSisNavigation != null ? src.FkidSucursalSisNavigation.Nombre : null))

                .ForMember(dest => dest.TipoConteoId, opt => opt.MapFrom(src => src.FkidTipoConteoAlma))
                .ForMember(dest => dest.TipoConteoNombre, opt => opt.MapFrom(src =>
                    src.FkidTipoConteoAlmaNavigation != null ? src.FkidTipoConteoAlmaNavigation.Nombre : null))

                .ForMember(dest => dest.EstatusId, opt => opt.MapFrom(src => src.FkidEstatusAlma))
                .ForMember(dest => dest.EstatusNombre, opt => opt.MapFrom(src =>
                    src.FkidEstatusAlmaNavigation != null ? src.FkidEstatusAlmaNavigation.Nombre : null))

                .ForMember(dest => dest.ResponsableId, opt => opt.MapFrom(src => src.FkidResponsableSis))
                .ForMember(dest => dest.ResponsableNombre, opt => opt.MapFrom(src =>
                    src.FkidResponsableSisNavigation != null ?
                    src.FkidResponsableSisNavigation.Nombre + " " + src.FkidResponsableSisNavigation.ApellidoPaterno : null))

                .ForMember(dest => dest.SupervisorId, opt => opt.MapFrom(src => src.FkidSupervisorSis))
                .ForMember(dest => dest.SupervisorNombre, opt => opt.MapFrom(src =>
                    src.FkidSupervisorSisNavigation != null ?
                    src.FkidSupervisorSisNavigation.Nombre + " " + src.FkidSupervisorSisNavigation.ApellidoPaterno : null))

                // UsuarioCreacionNombre - Opción 1: Usar solo el ID
                .ForMember(dest => dest.UsuarioCreacionNombre, opt => opt.MapFrom(src =>
                    src.UsuarioCreacion > 0 ? $"Usuario {src.UsuarioCreacion}" : null))

                // UsuarioModificacionNombre - Opción 1: Usar solo el ID
                .ForMember(dest => dest.UsuarioModificacionNombre, opt => opt.MapFrom(src =>
                    src.UsuarioModificacion.HasValue && src.UsuarioModificacion.Value > 0 ?
                    $"Usuario {src.UsuarioModificacion.Value}" : null))

                .ForMember(dest => dest.ArticulosPendientes, opt => opt.MapFrom(src =>
                    src.TotalArticulos.HasValue && src.ArticulosConcluidos.HasValue ?
                    src.TotalArticulos - src.ArticulosConcluidos : (int?)null))

                .ForMember(dest => dest.PorcentajeAvance, opt => opt.MapFrom(src =>
                    src.TotalArticulos.HasValue && src.TotalArticulos > 0 && src.ArticulosConcluidos.HasValue ?
                    Math.Round((decimal)src.ArticulosConcluidos.Value / src.TotalArticulos.Value * 100, 2) : (decimal?)null));

            }


    }
}

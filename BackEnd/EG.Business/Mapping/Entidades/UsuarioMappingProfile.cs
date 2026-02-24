using AutoMapper;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Mapping.Entidades
{
    public class UsuarioMappingProfile : Profile
    {
        public UsuarioMappingProfile()
        {
            // Mapeo específico para el servicio genérico de Usuario
            CreateMap<Usuario, UsuarioDto>()
                .ReverseMap()
                // Optimización: Solo mapear cuando tenga valor para evitar sobreescritura innecesaria
                .ForMember(dest => dest.FechaModificacion, opt => opt.Condition(src => src.FechaModificacion.HasValue))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Condition(src => src.UsuarioModificacion.HasValue));

            // Mapeo para la vista - Necesitas ajustar según la estructura real de VwUsuarioEmpresa
            CreateMap<VwUsuarioEmpresa, UsuarioResponse>()
                .ForMember(dest => dest.PkIdUsuario, opt => opt.MapFrom(src => src.PkIdUsuario))
                .ForMember(dest => dest.NombreCompleto, opt => opt.MapFrom(src => src.NombreCompleto))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email))
                .ForMember(dest => dest.NombreEmpresa, opt => opt.MapFrom(src => src.NombreEmpresa))
                .ForMember(dest => dest.RfcEmpresa, opt => opt.MapFrom(src => src.RfcEmpresa))
                .ForMember(dest => dest.RolPrincipal, opt => opt.MapFrom(src => src.RolPrincipal ?? "Usuario"))
                .ForMember(dest => dest.UsuarioActivo, opt => opt.MapFrom(src => src.UsuarioActivo))
                //.ForMember(dest => dest.TotalSucursales, opt => opt.MapFrom(src => src.TotalSucursales ?? 0))
                .ForMember(dest => dest.TotalDepartamentos, opt => opt.MapFrom(src => src.TotalDepartamentos ?? 0))

                // Ignorar el resto para mejorar rendimiento
                //.ForAllOtherMembers(opt => opt.Ignore())
                ;
        }
    }
}
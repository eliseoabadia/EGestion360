using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
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
            // Mapeo para la vista VwUsuarioEmpresa a UsuarioDto
            CreateMap<VwUsuarioEmpresa, UsuarioDto>()
                .ForMember(dest => dest.PkIdUsuario, opt => opt.MapFrom(src => src.PkIdUsuario))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.IdEmpresa))
                .ForMember(dest => dest.AspNetUserId, opt => opt.MapFrom(src => src.AspNetUserId))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.ApellidoMaterno))
                .ForMember(dest => dest.Iniciales, opt => opt.MapFrom(src => src.Iniciales))
                .ForMember(dest => dest.PayrollId, opt => opt.MapFrom(src => src.PayrollId))
                .ForMember(dest => dest.CodigoPostal, opt => opt.MapFrom(src => src.CodigoPostalUsuario))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.TelefonoUsuario))
                .ForMember(dest => dest.Direccion1, opt => opt.MapFrom(src => src.Direccion1))
                .ForMember(dest => dest.Direccion2, opt => opt.MapFrom(src => src.Direccion2))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email))
                .ForMember(dest => dest.NumeroSocial, opt => opt.MapFrom(src => src.NumeroSocial))
                .ForMember(dest => dest.Gafete, opt => opt.MapFrom(src => src.Gafete))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Sexo))
                .ForMember(dest => dest.FechaIngreso, opt => opt.MapFrom(src => src.FechaIngreso))
                .ForMember(dest => dest.FkidIdiomaPreferidoSis, opt => opt.MapFrom(src => src.IdIdiomaPreferido))
                .ForMember(dest => dest.FkidMonedaPreferidaSis, opt => opt.MapFrom(src => src.IdMonedaPreferida))
                .ForMember(dest => dest.EsAdministrador, opt => opt.MapFrom(src => src.EsAdministrador))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.UsuarioActivo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.UsuarioFechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreadorId))
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore()) // No disponible en la vista
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore()); // No disponible en la vista
        }
    }
}
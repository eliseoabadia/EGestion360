using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Entidades
{
    public class UsuarioSucursalMappingProfile : Profile
    {
        public UsuarioSucursalMappingProfile()
        {
            // Mapeo Entidad -> DTO
            CreateMap<UsuarioSucursal, UsuarioSucursalDto>()
                .ForMember(dest => dest.FkidUsuarioSis, opt => opt.MapFrom(src => src.FkidUsuarioSis))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.PuedeAcceder, opt => opt.MapFrom(src => src.PuedeAcceder))
                .ForMember(dest => dest.PuedeConfigurar, opt => opt.MapFrom(src => src.PuedeConfigurar))
                .ForMember(dest => dest.PuedeOperar, opt => opt.MapFrom(src => src.PuedeOperar))
                .ForMember(dest => dest.PuedeReportes, opt => opt.MapFrom(src => src.PuedeReportes))
                .ForMember(dest => dest.EsGerente, opt => opt.MapFrom(src => src.EsGerente))
                .ForMember(dest => dest.EsSupervisor, opt => opt.MapFrom(src => src.EsSupervisor))
                .ForMember(dest => dest.FechaAsignacion, opt => opt.MapFrom(src => src.FechaAsignacion))
                .ForMember(dest => dest.FechaFinAsignacion, opt => opt.MapFrom(src => src.FechaFinAsignacion))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ReverseMap()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUsuarioSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidSucursalSisNavigation, opt => opt.Ignore());

            // Mapeo Vista -> Response
            CreateMap<VwUsuarioSucursal, VwUsuarioSucursalResponse>()
                .ForMember(dest => dest.PkIdUsuario, opt => opt.MapFrom(src => src.PkIdUsuario))
                .ForMember(dest => dest.AspNetUserId, opt => opt.MapFrom(src => src.AspNetUserId))
                .ForMember(dest => dest.IdEmpresa, opt => opt.MapFrom(src => src.IdEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.ApellidoMaterno))
                .ForMember(dest => dest.NombreCompleto, opt => opt.MapFrom(src => src.NombreCompleto))
                .ForMember(dest => dest.Iniciales, opt => opt.MapFrom(src => src.Iniciales))
                .ForMember(dest => dest.InicialesNombre, opt => opt.MapFrom(src => src.InicialesNombre))
                .ForMember(dest => dest.PayrollId, opt => opt.MapFrom(src => src.PayrollId))
                .ForMember(dest => dest.CodigoPostalUsuario, opt => opt.MapFrom(src => src.CodigoPostalUsuario))
                .ForMember(dest => dest.TelefonoUsuario, opt => opt.MapFrom(src => src.TelefonoUsuario))
                .ForMember(dest => dest.Direccion1, opt => opt.MapFrom(src => src.Direccion1))
                .ForMember(dest => dest.Direccion2, opt => opt.MapFrom(src => src.Direccion2))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email))
                .ForMember(dest => dest.NumeroSocial, opt => opt.MapFrom(src => src.NumeroSocial))
                .ForMember(dest => dest.Gafete, opt => opt.MapFrom(src => src.Gafete))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Sexo))
                .ForMember(dest => dest.SexoDescripcion, opt => opt.MapFrom(src => src.SexoDescripcion))
                .ForMember(dest => dest.FechaIngreso, opt => opt.MapFrom(src => src.FechaIngreso))
                .ForMember(dest => dest.FechaIngresoFormat, opt => opt.MapFrom(src => src.FechaIngresoFormat))
                .ForMember(dest => dest.AntigüedadAños, opt => opt.MapFrom(src => src.AntigüedadAños))
                .ForMember(dest => dest.IdIdiomaPreferido, opt => opt.MapFrom(src => src.IdIdiomaPreferido))
                .ForMember(dest => dest.IdiomaPreferido, opt => opt.MapFrom(src => src.IdiomaPreferido))
                .ForMember(dest => dest.IdMonedaPreferida, opt => opt.MapFrom(src => src.IdMonedaPreferida))
                .ForMember(dest => dest.MonedaPreferida, opt => opt.MapFrom(src => src.MonedaPreferida))
                .ForMember(dest => dest.SimboloMoneda, opt => opt.MapFrom(src => src.SimboloMoneda))
                .ForMember(dest => dest.EsAdministrador, opt => opt.MapFrom(src => src.EsAdministrador))
                .ForMember(dest => dest.UsuarioActivo, opt => opt.MapFrom(src => src.UsuarioActivo))
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.NombreEmpresa, opt => opt.MapFrom(src => src.NombreEmpresa))
                .ForMember(dest => dest.RfcEmpresa, opt => opt.MapFrom(src => src.RfcEmpresa))
                .ForMember(dest => dest.RazonSocialEmpresa, opt => opt.MapFrom(src => src.RazonSocialEmpresa))
                .ForMember(dest => dest.GiroEmpresa, opt => opt.MapFrom(src => src.GiroEmpresa))
                .ForMember(dest => dest.IdMonedaBaseEmpresa, opt => opt.MapFrom(src => src.IdMonedaBaseEmpresa))
                .ForMember(dest => dest.MonedaBaseEmpresa, opt => opt.MapFrom(src => src.MonedaBaseEmpresa))
                .ForMember(dest => dest.SimboloMonedaBase, opt => opt.MapFrom(src => src.SimboloMonedaBase))
                .ForMember(dest => dest.EmpresaFechaCreacion, opt => opt.MapFrom(src => src.EmpresaFechaCreacion))
                .ForMember(dest => dest.IdSucursal, opt => opt.MapFrom(src => src.IdSucursal))
                .ForMember(dest => dest.NombreSucursal, opt => opt.MapFrom(src => src.NombreSucursal))
                .ForMember(dest => dest.CodigoSucursal, opt => opt.MapFrom(src => src.CodigoSucursal))
                .ForMember(dest => dest.DireccionSucursal, opt => opt.MapFrom(src => src.DireccionSucursal))
                .ForMember(dest => dest.EsMatriz, opt => opt.MapFrom(src => src.EsMatriz))
                .ForMember(dest => dest.PuedeAcceder, opt => opt.MapFrom(src => src.PuedeAcceder))
                .ForMember(dest => dest.PuedeConfigurar, opt => opt.MapFrom(src => src.PuedeConfigurar))
                .ForMember(dest => dest.PuedeOperar, opt => opt.MapFrom(src => src.PuedeOperar))
                .ForMember(dest => dest.PuedeReportes, opt => opt.MapFrom(src => src.PuedeReportes))
                .ForMember(dest => dest.EsGerente, opt => opt.MapFrom(src => src.EsGerente))
                .ForMember(dest => dest.EsSupervisor, opt => opt.MapFrom(src => src.EsSupervisor))
                .ForMember(dest => dest.AsignacionActiva, opt => opt.MapFrom(src => src.AsignacionActiva))
                .ForMember(dest => dest.EsJefeEnSucursal, opt => opt.MapFrom(src => src.EsJefeEnSucursal));


            // debes hacerlo mapeando solo las propiedades que coinciden
            CreateMap<VwUsuarioSucursalResponse, UsuarioSucursalDto>()
                .ForMember(dest => dest.FkidUsuarioSis, opt => opt.MapFrom(src => src.PkIdUsuario))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.IdSucursal))
                .ForMember(dest => dest.PuedeAcceder, opt => opt.MapFrom(src => src.PuedeAcceder))
                .ForMember(dest => dest.PuedeConfigurar, opt => opt.MapFrom(src => src.PuedeConfigurar))
                .ForMember(dest => dest.PuedeOperar, opt => opt.MapFrom(src => src.PuedeOperar))
                .ForMember(dest => dest.PuedeReportes, opt => opt.MapFrom(src => src.PuedeReportes))
                .ForMember(dest => dest.EsGerente, opt => opt.MapFrom(src => src.EsGerente))
                .ForMember(dest => dest.EsSupervisor, opt => opt.MapFrom(src => src.EsSupervisor))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.AsignacionActiva))
                .ReverseMap()
                .ForMember(dest => dest.PkIdUsuario, opt => opt.MapFrom(src => src.FkidUsuarioSis))
                .ForMember(dest => dest.IdSucursal, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.AsignacionActiva, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.PuedeAcceder, opt => opt.MapFrom(src => src.PuedeAcceder))
                .ForMember(dest => dest.PuedeConfigurar, opt => opt.MapFrom(src => src.PuedeConfigurar))
                .ForMember(dest => dest.PuedeOperar, opt => opt.MapFrom(src => src.PuedeOperar))
                .ForMember(dest => dest.PuedeReportes, opt => opt.MapFrom(src => src.PuedeReportes))
                .ForMember(dest => dest.EsGerente, opt => opt.MapFrom(src => src.EsGerente))
                .ForMember(dest => dest.EsSupervisor, opt => opt.MapFrom(src => src.EsSupervisor))
                // Ignorar propiedades que no existen en UsuarioSucursalDto
                .ForMember(dest => dest.Nombre, opt => opt.Ignore())
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.Ignore())
                .ForMember(dest => dest.Email, opt => opt.Ignore())
                .ForMember(dest => dest.NombreEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.NombreSucursal, opt => opt.Ignore())
                // ... ignorar todas las demás propiedades que no se pueden mapear
                ;
        }
    }
}
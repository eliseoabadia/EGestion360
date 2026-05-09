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
            // Mapeo de Usuario (entidad) a UsuarioResponse
            CreateMap<Usuario, UsuarioResponse>()
                .ForMember(dest => dest.IdEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.NombreCompleto,
                    opt => opt.MapFrom(src => $"{src.Nombre} {src.ApellidoPaterno} {src.ApellidoMaterno}".Trim()))
                .ForMember(dest => dest.InicialesNombre,
                    opt => opt.MapFrom(src => string.IsNullOrEmpty(src.Iniciales) ?
                        (src.Nombre.Length > 0 ? src.Nombre[0].ToString() : "") + (src.ApellidoPaterno.Length > 0 ? src.ApellidoPaterno.ToString() : "") : src.Iniciales))
                .ForMember(dest => dest.SexoDescripcion, opt => opt.MapFrom(src => src.Sexo ? "Masculino" : "Femenino"))
                .ForMember(dest => dest.FechaIngresoFormat,
                    opt => opt.MapFrom(src => src.FechaIngreso.HasValue ? src.FechaIngreso.Value.ToString("dd/MM/yyyy") : null))
                .ForMember(dest => dest.AntigüedadAños,
                    opt => opt.MapFrom(src => src.FechaIngreso.HasValue ? DateTime.Now.Year - src.FechaIngreso.Value.Year : (int?)null))
                .ForMember(dest => dest.UsuarioActivo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.PkidEmpresa : 0))
                .ForMember(dest => dest.NombreEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Nombre : null))
                .ForMember(dest => dest.RfcEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Rfc : null))
                .ForMember(dest => dest.RazonSocialEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.RazonSocial : null))
                .ForMember(dest => dest.GiroEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Giro : null))
                .ForMember(dest => dest.IdMonedaBaseEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.FkidMonedaBaseSis : 0))
                // MonedaBaseEmpresa y SimboloMonedaBase requerirían cargar navegación adicional, se pueden obtener de otra tabla
                .ForMember(dest => dest.IdPersona, opt => opt.MapFrom(src => src.FkidPersonaNom))
                .ForMember(dest => dest.ClavePersona, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Clave : null))
                .ForMember(dest => dest.PersonaNombre, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Nombre : null))
                .ForMember(dest => dest.PersonaPaterno, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Paterno : null))
                .ForMember(dest => dest.PersonaMaterno, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Materno : null))
                .ForMember(dest => dest.NombreCompletoPersona, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ?
                    $"{src.FkidPersonaNomNavigation.Nombre} {src.FkidPersonaNomNavigation.Paterno} {src.FkidPersonaNomNavigation.Materno}".Trim() : null))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Rfc : null))
                .ForMember(dest => dest.Curp, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Curp : null))
                .ForMember(dest => dest.EmailPersona, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.CorreoElectronico : null))
                .ForMember(dest => dest.TelefonoParticular, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.TelefonoMovil : null))
                .ForMember(dest => dest.TelefonoMovil, opt => opt.MapFrom(src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.TelefonoMovil : null))
                // Los campos de sucursal, roles, permisos, etc. se deben calcular a partir de relaciones muchos-a-muchos
                // Recomendación: usar VwUsuarioEmpresa para lecturas complejas.
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            // Mapeo desde la vista VwUsuarioEmpresa a UsuarioResponse (más completo)
            CreateMap<VwUsuarioEmpresa, UsuarioResponse>()
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
                //.ForMember(dest => dest.ListaDepartamentos, opt => opt.MapFrom(src => src.ListaDepartamentos))
                //.ForMember(dest => dest.TotalDepartamentos, opt => opt.MapFrom(src => src.TotalDepartamentos))
                .ForMember(dest => dest.EsJefeEnSucursal, opt => opt.MapFrom(src => src.EsJefeAlgunDepartamento))
                //.ForMember(dest => dest.ListaSucursales, opt => opt.MapFrom(src => src.ListaSucursales))
                //.ForMember(dest => dest.TotalSucursales, opt => opt.MapFrom(src => src.TotalSucursales))
                //.ForMember(dest => dest.RolPrincipal, opt => opt.MapFrom(src => src.RolPrincipal))
                //.ForMember(dest => dest.CoberturaSucursales, opt => opt.MapFrom(src => src.CoberturaSucursales))
                //.ForMember(dest => dest.NumeroEmpleado, opt => opt.MapFrom(src => src.NumeroEmpleado))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.UsuarioFechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreadorId))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.UsuarioFechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificadorId))
                .ForMember(dest => dest.IdPersona, opt => opt.MapFrom(src => src.IdPersona))
                .ForMember(dest => dest.ClavePersona, opt => opt.MapFrom(src => src.ClavePersona))
                .ForMember(dest => dest.PersonaNombre, opt => opt.MapFrom(src => src.PersonaNombre))
                .ForMember(dest => dest.PersonaPaterno, opt => opt.MapFrom(src => src.PersonaPaterno))
                .ForMember(dest => dest.PersonaMaterno, opt => opt.MapFrom(src => src.PersonaMaterno))
                .ForMember(dest => dest.NombreCompletoPersona, opt => opt.MapFrom(src => src.NombreCompletoPersona))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.Curp, opt => opt.MapFrom(src => src.Curp))
                .ForMember(dest => dest.EmailPersona, opt => opt.MapFrom(src => src.EmailPersona))
                .ForMember(dest => dest.TelefonoParticular, opt => opt.MapFrom(src => src.TelefonoParticular))
                .ForMember(dest => dest.TelefonoMovil, opt => opt.MapFrom(src => src.TelefonoMovil));

            // Mapeo de UsuarioDto (Request) a Usuario (entidad)
            CreateMap<UsuarioDto, Usuario>()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidEmpresaSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidIdiomaPreferidoSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidMonedaPreferidaSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPersonaNomNavigation, opt => opt.Ignore())
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
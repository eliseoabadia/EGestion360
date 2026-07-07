using System;
using System.Collections.Generic;
using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class UsuarioMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Mapeo de Usuario (entidad) a UsuarioResponse
            config.NewConfig<Usuario, UsuarioResponse>()
                .Map(dest => dest.IdEmpresa, src => src.FkidEmpresaSis ?? 0)
                .Map(dest => dest.Nombre, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Nombre : null)
                .Map(dest => dest.ApellidoPaterno, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Paterno : null)
                .Map(dest => dest.ApellidoMaterno, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Materno : null)
                .Map(dest => dest.NombreCompleto, src => src.FkidPersonaNomNavigation != null
                        ? $"{src.FkidPersonaNomNavigation.Nombre} {src.FkidPersonaNomNavigation.Paterno} {src.FkidPersonaNomNavigation.Materno}".Trim()
                        : string.Empty)
                .Map(dest => dest.Iniciales, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Iniciales : null)
                .Map(dest => dest.InicialesNombre, src => src.FkidPersonaNomNavigation != null
                        ? (!string.IsNullOrWhiteSpace(src.FkidPersonaNomNavigation.Iniciales)
                            ? src.FkidPersonaNomNavigation.Iniciales
                            : BuildInitials(src.FkidPersonaNomNavigation.Nombre, src.FkidPersonaNomNavigation.Paterno))
                        : string.Empty)
                .Map(dest => dest.CodigoPostalUsuario, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Cp : null)
                .Map(dest => dest.TelefonoUsuario, src => src.FkidPersonaNomNavigation != null
                        ? (!string.IsNullOrWhiteSpace(src.FkidPersonaNomNavigation.TelefonoMovil)
                            ? src.FkidPersonaNomNavigation.TelefonoMovil
                            : src.FkidPersonaNomNavigation.TelefonoParticular)
                        : null)
                .Map(dest => dest.Direccion1, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Calle : null)
                .Map(dest => dest.Direccion2, src => BuildDireccionComplemento(src.FkidPersonaNomNavigation))
                .Map(dest => dest.Email, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.CorreoElectronico : null)
                .Map(dest => dest.NumeroSocial, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.RegImss : null)
                .Map(dest => dest.Gafete, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Gafete : null)
                .Map(dest => dest.Sexo, src => MapSexoToBool(src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Sexo : null))
                .Map(dest => dest.SexoDescripcion, src => MapSexoDescripcion(src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Sexo : null))
                .Map(dest => dest.FechaIngreso, src => MapToDateOnly(src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.FechaDeInicio : (DateTime?)null))
                .Map(dest => dest.FechaIngresoFormat, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.FechaDeInicio.ToString("dd/MM/yyyy") : null)
                .Map(dest => dest.AntigüedadAños, src => CalculateAntiguedad(src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.FechaDeInicio : (DateTime?)null))
                .Map(dest => dest.UsuarioActivo, src => src.Activo)
                .Map(dest => dest.PkidEmpresa, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.PkidEmpresa : 0)
                .Map(dest => dest.NombreEmpresa, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Nombre : null)
                .Map(dest => dest.RfcEmpresa, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Rfc : null)
                .Map(dest => dest.RazonSocialEmpresa, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.RazonSocial : null)
                .Map(dest => dest.GiroEmpresa, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Giro : null)
                .Map(dest => dest.IdMonedaBaseEmpresa, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.FkidMonedaBaseSis : 0)
                // MonedaBaseEmpresa y SimboloMonedaBase requieren carga adicional de catálogo.
                .Map(dest => dest.IdPersona, src => src.FkidPersonaNom)
                .Map(dest => dest.ClavePersona, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Clave : null)
                .Map(dest => dest.PersonaNombre, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Nombre : null)
                .Map(dest => dest.PersonaPaterno, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Paterno : null)
                .Map(dest => dest.PersonaMaterno, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Materno : null)
                .Map(dest => dest.NombreCompletoPersona, src => src.FkidPersonaNomNavigation != null
                        ? $"{src.FkidPersonaNomNavigation.Nombre} {src.FkidPersonaNomNavigation.Paterno} {src.FkidPersonaNomNavigation.Materno}".Trim()
                        : null)
                .Map(dest => dest.Rfc, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Rfc : null)
                .Map(dest => dest.Curp, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.Curp : null)
                .Map(dest => dest.EmailPersona, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.CorreoElectronico : null)
                .Map(dest => dest.TelefonoParticular, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.TelefonoParticular : null)
                .Map(dest => dest.TelefonoMovil, src => src.FkidPersonaNomNavigation != null ? src.FkidPersonaNomNavigation.TelefonoMovil : null)
                .IgnoreNullValues(true);

            // Mapeo desde la vista VwUsuarioEmpresa a UsuarioResponse (más completo)
            config.NewConfig<VwUsuarioEmpresa, UsuarioResponse>()
                .Map(dest => dest.PkIdUsuario, src => src.PkIdUsuario)
                .Map(dest => dest.AspNetUserId, src => src.AspNetUserId)
                .Map(dest => dest.IdEmpresa, src => src.IdEmpresa.HasValue && src.IdEmpresa.Value > 0
                        ? src.IdEmpresa.Value
                        : src.PkidEmpresa)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.ApellidoPaterno, src => src.ApellidoPaterno)
                .Map(dest => dest.ApellidoMaterno, src => src.ApellidoMaterno)
                .Map(dest => dest.NombreCompleto, src => src.NombreCompleto)
                .Map(dest => dest.Iniciales, src => src.Iniciales)
                .Map(dest => dest.InicialesNombre, src => src.InicialesNombre)
                .Map(dest => dest.PayrollId, src => src.PayrollId)
                .Map(dest => dest.CodigoPostalUsuario, src => src.CodigoPostal)
                .Map(dest => dest.TelefonoUsuario, src => src.Telefono)
                .Map(dest => dest.Direccion1, src => src.Direccion1)
                .Map(dest => dest.Direccion2, src => src.Direccion2)
                .Map(dest => dest.Email, src => src.Email)
                .Map(dest => dest.NumeroSocial, src => src.NumeroSocial)
                .Map(dest => dest.Gafete, src => src.Gafete)
                .Map(dest => dest.Sexo, src => MapSexoToBool(src.Sexo))
                .Map(dest => dest.SexoDescripcion, src => MapSexoDescripcion(src.Sexo, src.SexoDescripcion))
                .Map(dest => dest.FechaIngreso, src => MapToDateOnly(src.FechaIngreso))
                .Map(dest => dest.FechaIngresoFormat, src => src.FechaIngresoFormat)
                .Map(dest => dest.AntigüedadAños, src => src.AntiguedadAnios)
                .Map(dest => dest.IdIdiomaPreferido, src => src.IdIdiomaPreferido)
                .Map(dest => dest.IdiomaPreferido, src => src.IdiomaPreferido)
                .Map(dest => dest.IdMonedaPreferida, src => src.IdMonedaPreferida)
                .Map(dest => dest.MonedaPreferida, src => src.MonedaPreferida)
                .Map(dest => dest.SimboloMoneda, src => src.SimboloMoneda)
                .Map(dest => dest.EsAdministrador, src => src.EsAdministrador)
                .Map(dest => dest.UsuarioActivo, src => src.UsuarioActivo)
                .Map(dest => dest.PkidEmpresa, src => src.PkidEmpresa)
                .Map(dest => dest.NombreEmpresa, src => src.NombreEmpresa)
                .Map(dest => dest.RfcEmpresa, src => src.RfcEmpresa)
                .Map(dest => dest.RazonSocialEmpresa, src => src.RazonSocialEmpresa)
                .Map(dest => dest.GiroEmpresa, src => src.GiroEmpresa)
                .Map(dest => dest.IdMonedaBaseEmpresa, src => src.IdMonedaBaseEmpresa)
                .Map(dest => dest.MonedaBaseEmpresa, src => src.MonedaBaseEmpresa)
                .Map(dest => dest.SimboloMonedaBase, src => src.SimboloMonedaBase)
                .Map(dest => dest.EmpresaFechaCreacion, src => src.EmpresaFechaCreacion)
                .Map(dest => dest.EsJefeEnSucursal, src => src.EsJefeAlgunDepartamento)
                .Map(dest => dest.FechaCreacion, src => src.UsuarioFechaCreacion)
                .Map(dest => dest.UsuarioCreacion, src => src.UsuarioCreacion ?? 0)
                .Map(dest => dest.FechaModificacion, src => src.UsuarioFechaModificacion)
                .Map(dest => dest.UsuarioModificacion, src => src.UsuarioModificacion)
                .Map(dest => dest.IdPersona, src => src.IdPersona)
                .Map(dest => dest.ClavePersona, src => src.ClavePersona)
                .Map(dest => dest.PersonaNombre, src => src.PersonaNombre)
                .Map(dest => dest.PersonaPaterno, src => src.PersonaPaterno)
                .Map(dest => dest.PersonaMaterno, src => src.PersonaMaterno)
                .Map(dest => dest.NombreCompletoPersona, src => src.NombreCompletoPersona)
                .Map(dest => dest.Rfc, src => src.Rfc)
                .Map(dest => dest.Curp, src => src.Curp)
                .Map(dest => dest.EmailPersona, src => src.EmailPersona)
                .Map(dest => dest.TelefonoParticular, src => src.TelefonoParticular)
                .Map(dest => dest.TelefonoMovil, src => src.TelefonoMovil);

            // Mapeo del contrato que recibe el controlador al DTO real de persistencia.
            config.NewConfig<UsuarioResponse, UsuarioDto>()
                .Map(dest => dest.PkIdUsuario, src => src.PkIdUsuario)
                .Map(dest => dest.FkidEmpresaSis, src => src.IdEmpresa > 0 ? src.IdEmpresa : src.PkidEmpresa)
                .Map(dest => dest.FkidPersonaNom, src => src.IdPersona)
                .Map(dest => dest.AspNetUserId, src => src.AspNetUserId)
                .Map(dest => dest.PayrollId, src => src.PayrollId)
                .Map(dest => dest.FkidIdiomaPreferidoSis, src => src.IdIdiomaPreferido)
                .Map(dest => dest.FkidMonedaPreferidaSis, src => src.IdMonedaPreferida)
                .Map(dest => dest.EsAdministrador, src => src.EsAdministrador)
                .Map(dest => dest.Activo, src => src.UsuarioActivo)
                .IgnoreNullValues(true);

            // Mapeo de UsuarioDto (Request) a Usuario (entidad)
            config.NewConfig<UsuarioDto, Usuario>()
                .Ignore(dest => dest.FechaCreacion)
                .Ignore(dest => dest.UsuarioCreacion)
                .Ignore(dest => dest.FechaModificacion)
                .Ignore(dest => dest.UsuarioModificacion)
                .Ignore(dest => dest.FkidEmpresaSisNavigation)
                .Ignore(dest => dest.FkidIdiomaPreferidoSisNavigation)
                .Ignore(dest => dest.FkidMonedaPreferidaSisNavigation)
                .Ignore(dest => dest.FkidPersonaNomNavigation)
                .IgnoreNullValues(true);
        }

        private static DateOnly? MapToDateOnly(DateTime? value)
        {
            return value.HasValue ? DateOnly.FromDateTime(value.Value) : null;
        }

        private static int? CalculateAntiguedad(DateTime? fechaIngreso)
        {
            if (!fechaIngreso.HasValue)
            {
                return null;
            }

            var ingreso = DateOnly.FromDateTime(fechaIngreso.Value);
            var hoy = DateOnly.FromDateTime(DateTime.Today);

            var antiguedad = hoy.Year - ingreso.Year;
            if (ingreso > hoy.AddYears(-antiguedad))
            {
                antiguedad--;
            }

            return antiguedad < 0 ? 0 : antiguedad;
        }

        private static string BuildInitials(string nombre, string paterno)
        {
            var firstNameInitial = !string.IsNullOrWhiteSpace(nombre) ? nombre[0].ToString() : string.Empty;
            var lastNameInitial = !string.IsNullOrWhiteSpace(paterno) ? paterno[0].ToString() : string.Empty;
            return $"{firstNameInitial}{lastNameInitial}".ToUpperInvariant();
        }

        private static string BuildDireccionComplemento(Persona persona)
        {
            if (persona == null)
            {
                return null;
            }

            var parts = new List<string>();
            if (!string.IsNullOrWhiteSpace(persona.NumExterior))
            {
                parts.Add($"Ext. {persona.NumExterior}");
            }

            if (!string.IsNullOrWhiteSpace(persona.NumInterior))
            {
                parts.Add($"Int. {persona.NumInterior}");
            }

            if (!string.IsNullOrWhiteSpace(persona.Colonia))
            {
                parts.Add(persona.Colonia);
            }

            return parts.Count > 0 ? string.Join(", ", parts) : null;
        }

        private static bool MapSexoToBool(string sexo)
        {
            var normalized = NormalizeSexo(sexo);
            return normalized is "M" or "H" or "MASCULINO" or "HOMBRE" or "MALE" or "TRUE" or "1";
        }

        private static string MapSexoDescripcion(string sexo, string fallbackDescripcion = null)
        {
            if (!string.IsNullOrWhiteSpace(fallbackDescripcion))
            {
                return fallbackDescripcion;
            }

            var normalized = NormalizeSexo(sexo);
            return normalized switch
            {
                "M" or "H" or "MASCULINO" or "HOMBRE" or "MALE" or "TRUE" or "1" => "Masculino",
                "F" or "FEMENINO" or "MUJER" or "FEMALE" or "FALSE" or "0" => "Femenino",
                _ => string.Empty
            };
        }

        private static string NormalizeSexo(string sexo)
        {
            return string.IsNullOrWhiteSpace(sexo) ? string.Empty : sexo.Trim().ToUpperInvariant();
        }
    }
}

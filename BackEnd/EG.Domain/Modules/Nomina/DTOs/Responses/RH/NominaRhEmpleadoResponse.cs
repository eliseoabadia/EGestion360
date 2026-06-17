using System;

namespace EG.Domain.DTOs.Responses.Nomina
{
    public class NominaRhEmpleadoResponse
    {
        public int Id { get; set; }

        public int? EmpresaId { get; set; }

        public string Empresa { get; set; } = string.Empty;

        public string Empleado { get; set; } = string.Empty;

        public string Iniciales { get; set; } = string.Empty;

        public string Nombre { get; set; } = string.Empty;

        public string Paterno { get; set; } = string.Empty;

        public string Materno { get; set; } = string.Empty;

        public string NombreCompleto { get; set; } = string.Empty;

        public string Rfc { get; set; } = string.Empty;

        public string Curp { get; set; } = string.Empty;

        public string Sexo { get; set; } = string.Empty;

        public DateTime? FechaNacimiento { get; set; }

        public DateTime? FechaIngreso { get; set; }

        public DateTime? FechaFin { get; set; }

        public string TipoContratacion { get; set; } = string.Empty;

        public string Puesto { get; set; } = string.Empty;

        public string Departamento { get; set; } = string.Empty;

        public string Contrato { get; set; } = string.Empty;

        public decimal? SueldoMensual { get; set; }

        public decimal? SueldoBase { get; set; }

        public decimal? CompensacionGarantizada { get; set; }

        public string Banco { get; set; } = string.Empty;

        public string NumeroCuenta { get; set; } = string.Empty;

        public string Clabe { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;

        public string Telefono { get; set; } = string.Empty;

        public string Celular { get; set; } = string.Empty;

        public string Direccion { get; set; } = string.Empty;

        public string Calle { get; set; } = string.Empty;

        public string NumExterior { get; set; } = string.Empty;

        public string NumInterior { get; set; } = string.Empty;

        public string Colonia { get; set; } = string.Empty;

        public string CP { get; set; } = string.Empty;

        public string Municipio { get; set; } = string.Empty;

        public string Estado { get; set; } = string.Empty;

        public string EstadoCivil { get; set; } = string.Empty;

        public string RegImss { get; set; } = string.Empty;

        public string NoCartilla { get; set; } = string.Empty;

        public string NoLicencia { get; set; } = string.Empty;

        public string NoPasaporte { get; set; } = string.Empty;

        public string NoCredencialElector { get; set; } = string.Empty;

        public string Gafete { get; set; } = string.Empty;

        public bool TienePension { get; set; }

        public int TotalExpedientes { get; set; }

        public int TotalIncidencias { get; set; }

        public bool Activo { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int TotalCount { get; set; }

        public string ClaveNombre => $"{Empleado} - {NombreCompleto}".Trim(' ', '-');
    }

    public class NominaRhEmpleadoDetalleResponse
    {
        public string Seccion { get; set; } = string.Empty;

        public int Id { get; set; }

        public int PersonaId { get; set; }

        public int? EmpresaId { get; set; }

        public string Clave { get; set; } = string.Empty;

        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public string Tipo { get; set; } = string.Empty;

        public string Estatus { get; set; } = string.Empty;

        public DateTime? Fecha { get; set; }

        public DateTime? FechaInicio { get; set; }

        public DateTime? FechaFin { get; set; }

        public decimal? Importe { get; set; }

        public decimal? Porcentaje { get; set; }

        public string Documento { get; set; } = string.Empty;

        public string Referencia { get; set; } = string.Empty;

        public string Observaciones { get; set; } = string.Empty;

        public bool Activo { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int TotalCount { get; set; }
    }
}

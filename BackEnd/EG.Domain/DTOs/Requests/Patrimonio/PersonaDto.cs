namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class PersonaDto
    {
        public int PkidPersona { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Paterno { get; set; } = string.Empty;
        public string Materno { get; set; } = string.Empty;
        public string TelefonoParticular { get; set; } = string.Empty;
        public string TelefonoMovil { get; set; } = string.Empty;
        public DateTime? FechaDeInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Rfc { get; set; } = string.Empty;
        public string Curp { get; set; } = string.Empty;
        public DateTime? FechaNacimiento { get; set; }
        public string Sexo { get; set; } = string.Empty;
        public string EstadoCivil { get; set; } = string.Empty;
        public string Municipio { get; set; } = string.Empty;
        public string RegImss { get; set; } = string.Empty;
        public string NoCartilla { get; set; } = string.Empty;
        public string NoLicencia { get; set; } = string.Empty;
        public string NoPasaporte { get; set; } = string.Empty;
        public string NoCredencialElector { get; set; } = string.Empty;
        public string Calle { get; set; } = string.Empty;
        public string NumExterior { get; set; } = string.Empty;
        public string NumInterior { get; set; } = string.Empty;
        public string Colonia { get; set; } = string.Empty;
        public string Cp { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string TipoContratacion { get; set; } = string.Empty;
        public string Puesto { get; set; } = string.Empty;
        public double? SueldoBase { get; set; }
        public double? CompensacionGarantizada { get; set; }
        public string Banco { get; set; } = string.Empty;
        public string NumeroCuenta { get; set; } = string.Empty;
        public string Clabe { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
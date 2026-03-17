namespace EG.Web.Services
{
    public class VwUsuarioSucursalResponse
    {
        public int PkIdUsuario { get; set; }
        public string AspNetUserId { get; set; } = string.Empty;
        public int IdEmpresa { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string ApellidoPaterno { get; set; } = string.Empty;
        public string ApellidoMaterno { get; set; } = string.Empty;
        public string NombreCompleto { get; set; } = string.Empty;
        public string Iniciales { get; set; } = string.Empty;
        public string InicialesNombre { get; set; } = string.Empty;
        public string PayrollId { get; set; } = string.Empty;
        public string CodigoPostalUsuario { get; set; } = string.Empty;
        public string TelefonoUsuario { get; set; } = string.Empty;
        public string Direccion1 { get; set; } = string.Empty;
        public string Direccion2 { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string NumeroSocial { get; set; } = string.Empty;
        public string Gafete { get; set; } = string.Empty;
        public bool? Sexo { get; set; }
        public string SexoDescripcion { get; set; } = string.Empty;
        public DateOnly? FechaIngreso { get; set; }
        public string FechaIngresoFormat { get; set; } = string.Empty;
        public int? AntigüedadAños { get; set; }
        public int? IdIdiomaPreferido { get; set; }
        public string IdiomaPreferido { get; set; } = string.Empty;
        public int? IdMonedaPreferida { get; set; }
        public string MonedaPreferida { get; set; } = string.Empty;
        public string SimboloMoneda { get; set; } = string.Empty;
        public bool? EsAdministrador { get; set; }
        public bool? UsuarioActivo { get; set; }
        public int? PkidEmpresa { get; set; }
        public string NombreEmpresa { get; set; } = string.Empty;
        public string RfcEmpresa { get; set; } = string.Empty;
        public string RazonSocialEmpresa { get; set; } = string.Empty;
        public string GiroEmpresa { get; set; } = string.Empty;
        public int? IdMonedaBaseEmpresa { get; set; }
        public string MonedaBaseEmpresa { get; set; } = string.Empty;
        public string SimboloMonedaBase { get; set; } = string.Empty;
        public DateTime? EmpresaFechaCreacion { get; set; }
        public int? IdSucursal { get; set; }
        public string NombreSucursal { get; set; } = string.Empty;
        public string CodigoSucursal { get; set; } = string.Empty;
        public string DireccionSucursal { get; set; } = string.Empty;
        public bool? EsMatriz { get; set; }
        public bool? PuedeAcceder { get; set; }
        public bool? PuedeConfigurar { get; set; }
        public bool? PuedeOperar { get; set; }
        public bool? PuedeReportes { get; set; }
        public bool? EsGerente { get; set; }
        public bool? EsSupervisor { get; set; }
        public bool? AsignacionActiva { get; set; }
        public int? EsJefeEnSucursal { get; set; }
    }
}

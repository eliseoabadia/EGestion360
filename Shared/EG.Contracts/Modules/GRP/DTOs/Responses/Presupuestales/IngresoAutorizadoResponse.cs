namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class IngresoAutorizadoResponse
    {
        public int PkidIngresoAutorizado { get; set; }
        public int FkidProgramaPres { get; set; }
        public int? FkidAnioSis { get; set; }
        public string? ProgramaClave { get; set; }
        public string? ProgramaDescripcion { get; set; }
        public string? ProgramaClaveNombre { get; set; }
        public string? AreaFuncional { get; set; }
        public int FkidOrigenPres { get; set; }
        public int OrigenClave { get; set; }
        public string? OrigenDescripcion { get; set; }
        public string? OrigenClaveNombre { get; set; }
        public string? Origen { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public string? FuenteFinanciamientoClave { get; set; }
        public string? FuenteFinanciamientoDescripcion { get; set; }
        public string? FuenteFinanciamientoClaveNombre { get; set; }
        public int? FkidTipoGastoPres { get; set; }
        public int? TipoGastoClave { get; set; }
        public string? TipoGastoDescripcion { get; set; }
        public string? TipoGastoClaveNombre { get; set; }
        public int? FkidDigitoIdentificadorPres { get; set; }
        public string? DigitoIdentificadorClave { get; set; }
        public string? DigitoIdentificadorDescripcion { get; set; }
        public string? DigitoIdentificadorClaveNombre { get; set; }
        public int? FkidDestinoGastoPres { get; set; }
        public string? DestinoGastoClave { get; set; }
        public string? DestinoGastoDescripcion { get; set; }
        public string? DestinoGastoClaveNombre { get; set; }
        public string? PosicionPresupuestal { get; set; }
        public string? Descripcion { get; set; }
        public DateOnly Fecha { get; set; }
        public int? FkidPolizaConta { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Septiembre { get; set; }
        public decimal Octubre { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }
        public decimal? Total { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public int? UsuarioAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string? Message { get; set; }
        public string? DescripcionRequisicion { get; set; }
        public bool EstaAutorizado => FechaAutorizacion.HasValue;
    }

    public class IngresoAutorizadoPolizaResponse
    {
        public int PkidIngresoAutorizado { get; set; }
        public int PkidPoliza { get; set; }
        public string ClavePoliza { get; set; } = string.Empty;
        public string NombrePoliza { get; set; } = string.Empty;
        public DateTime FechaPoliza { get; set; }
        public bool EstaBalanceado { get; set; }
        public bool? Autorizado { get; set; }
        public bool? PermitirModificar { get; set; }
        public decimal TotalDebe { get; set; }
        public decimal TotalHaber { get; set; }
        public decimal Diferencia => TotalDebe - TotalHaber;
        public List<IngresoAutorizadoPolizaDetalleResponse> Detalles { get; set; } = [];
    }

    public class IngresoAutorizadoPolizaDetalleResponse
    {
        public int PkidPolizaDetalle { get; set; }
        public int FkidCuentaContableConta { get; set; }
        public string Cuenta { get; set; } = string.Empty;
        public string CuentaDescripcion { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal ImporteDebe { get; set; }
        public decimal ImporteHaber { get; set; }
        public int? FkidTipoDetallePolizaSis { get; set; }
    }
}

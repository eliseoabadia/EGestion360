namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class PolizaResponse
    {
        public int PkidPoliza { get; set; }
        public int FkidAnioSis { get; set; }
        public int Anio { get; set; }
        public int FkidMesSis { get; set; }
        public string? Mes { get; set; }
        public int FkidTipoPolizaSis { get; set; }
        public string? TipoPoliza { get; set; }
        public string ClavePoliza { get; set; } = string.Empty;
        public string NombrePoliza { get; set; } = string.Empty;
        public DateTime FechaPoliza { get; set; }
        public bool EstaBalanceado { get; set; }
        public int TotalDetalles { get; set; }
        public decimal TotalDebe { get; set; }
        public decimal TotalHaber { get; set; }
        public decimal? Diferencia { get; set; }
        public bool? PermitirModificar { get; set; }
        public int? FkidAccionAutorizarSis { get; set; }
        public bool? Autorizado { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public string EstadoFirma { get; set; } = "PENDIENTE";
        public DateTime? FechaEnvioFirma { get; set; }
        public DateTime? FechaRechazoFirma { get; set; }
        public bool PuedeEnviarFirma { get; set; } = true;
        public bool PuedeRechazarFirma { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public byte[]? RowVersion { get; set; }
    }
}

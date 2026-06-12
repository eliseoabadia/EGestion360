namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class PolizaDto
    {
        public int PkidPoliza { get; set; }
        public int FkidAnioSis { get; set; }
        public int FkidMesSis { get; set; }
        public int FkidTipoPolizaSis { get; set; }
        public string ClavePoliza { get; set; } = string.Empty;
        public string NombrePoliza { get; set; } = string.Empty;
        public DateTime FechaPoliza { get; set; }
        public bool EstaBalanceado { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public bool? PermitirModificar { get; set; }
        public int? FkidAccionAutorizarSis { get; set; }
        public bool? Autorizado { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
    }
}

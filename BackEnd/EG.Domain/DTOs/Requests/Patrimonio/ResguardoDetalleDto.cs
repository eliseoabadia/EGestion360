namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class ResguardoDetalleDto
    {
        public int PkidResguardoDetalle { get; set; }
        public int FkidResguardoAlma { get; set; }
        public int FkidBienAlma { get; set; }
        public int Consecutivo { get; set; }
        public DateTime FechaAsignacion { get; set; }
        public DateTime? FechaLiberacion { get; set; }
        public bool ImprimeEtiqueta { get; set; }
        public int? FkidEstadoBienAlma { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class ResguardoMovimientoResponse
    {
        public int PkidResguardoMovimiento { get; set; }
        public int? FkidResguardoDetalleAlma { get; set; }
        public int FkidBienAlma { get; set; }
        public string BienClave { get; set; } = string.Empty;
        public string BienDescripcion { get; set; } = string.Empty;
        public string BienSerie { get; set; } = string.Empty;
        public int? FkidResguardoOrigenAlma { get; set; }
        public string ResguardoOrigenFolio { get; set; } = string.Empty;
        public string ResguardoOrigenResponsable { get; set; } = string.Empty;
        public int? FkidResguardoDestinoAlma { get; set; }
        public string ResguardoDestinoFolio { get; set; } = string.Empty;
        public string ResguardoDestinoResponsable { get; set; } = string.Empty;
        public string TipoMovimiento { get; set; } = string.Empty;
        public DateTime FechaMovimiento { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
    }
}

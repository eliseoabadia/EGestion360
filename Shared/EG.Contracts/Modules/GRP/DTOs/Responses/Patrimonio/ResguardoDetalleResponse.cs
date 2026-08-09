namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class ResguardoDetalleResponse
    {
        public int PkidResguardoDetalle { get; set; }
        public int FkidResguardoAlma { get; set; }
        public string Folio { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
        public int? FkidAreaSis { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public int FkidPersonaNom { get; set; }
        public string PersonaNombre { get; set; } = string.Empty;
        public int FkidBienAlma { get; set; }
        public string BienClave { get; set; } = string.Empty;
        public string BienClaveAnterior { get; set; } = string.Empty;
        public string BienDescripcion { get; set; } = string.Empty;
        public string Modelo { get; set; } = string.Empty;
        public string Serie { get; set; } = string.Empty;
        public string Factura { get; set; } = string.Empty;
        public decimal? Costo { get; set; }
        public decimal? ValorActual { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienCodigoClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public int Consecutivo { get; set; }
        public DateTime FechaAsignacion { get; set; }
        public DateTime? FechaLiberacion { get; set; }
        public bool ImprimeEtiqueta { get; set; }
        public int? FkidEstadoBienAlma { get; set; }
        public string EstadoBienDescripcion { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

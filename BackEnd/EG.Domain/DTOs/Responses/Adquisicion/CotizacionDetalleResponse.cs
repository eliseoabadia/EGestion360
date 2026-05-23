namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class CotizacionDetalleResponse
    {
        public int PkidCotizacionDetalle { get; set; }
        public int FkidCotizacionOrco { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public DateTime FechaRequisicion { get; set; }
        public int FkidProveedorSis { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
        public int FkidRequisicionDetalleOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public int? FkidUnidadesAlma { get; set; }
        public string UnidadMedida { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaProveedorCotiza { get; set; }
        public DateTime? FechaProveedorCompromiso { get; set; }
        public string? Comentarios { get; set; }
        public bool Servicio { get; set; }
        public string? FlDocumento { get; set; }
        public string? Entrega { get; set; }
        public string? Vigencia { get; set; }
        public string? Condiciones { get; set; }
        public decimal? PrecioUnitario { get; set; }
        public decimal? Importe { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidContenedorCotOrco { get; set; }
        public int? FkidContenedorMultiCotOrco { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

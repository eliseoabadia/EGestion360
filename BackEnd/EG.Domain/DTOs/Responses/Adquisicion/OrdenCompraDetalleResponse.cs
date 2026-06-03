namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class OrdenCompraDetalleResponse
    {
        public int PkidOrdenCompraDetalle { get; set; }
        public int FkidOrdenCompraOrco { get; set; }
        public string NumeroOrdenCompra { get; set; } = string.Empty;
        public int? FkidRequisicionDetalleOrco { get; set; }
        public int? IdRequisicion { get; set; }
        public int? FkidCotizacionDetalleOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienCodigoClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public string Cabms { get; set; } = string.Empty;
        public string Identificador { get; set; } = string.Empty;
        public int FkidUnidadesAlma { get; set; }
        public string UnidadMedida { get; set; } = string.Empty;
        public decimal CantidadSolicitada { get; set; }
        public decimal CantidadRecibida { get; set; }
        public decimal? CantidadPendiente { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal? Importe { get; set; }
        public decimal Iva { get; set; }
        public decimal? TotalDetalle { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string BienClaveNombre { get; set; } = string.Empty;
    }
}

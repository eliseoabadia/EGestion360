namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstudioMercadoCotizacionRecepcionResponse
    {
        public int PkidCotizacionDetalle { get; set; }
        public int PkidSolicitudCotizacion { get; set; }
        public int FkidProveedorSis { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
        public int FkidEstudioMercadoDetalleOrco { get; set; }
        public int FkidPaaasdetalleOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public decimal? PrecioUnitario { get; set; }
        public decimal? Importe { get; set; }
        public int? TiempoEntregaDias { get; set; }
        public string? Condiciones { get; set; }
        public DateTime? FechaRespuesta { get; set; }
        public int EstatusSolicitud { get; set; }
    }
}

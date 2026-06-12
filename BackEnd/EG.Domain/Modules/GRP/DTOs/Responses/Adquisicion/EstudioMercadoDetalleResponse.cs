namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstudioMercadoDetalleResponse
    {
        public int PkidEstudioMercadoDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidEstudioMercadoOrco { get; set; }
        public string EstudioMercadoNombre { get; set; } = string.Empty;
        public int FkidPaaasdetalleOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public string TipoBienClave { get; set; } = string.Empty;
        public int? FkidProveedorSis { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public decimal? CostoUnitario { get; set; }
        public decimal? ImporteEstimado { get; set; }
        public List<EstudioMercadoDetalleProveedorResponse> ProveedoresCotizacion { get; set; } = new();
        public int SolicitudesCotizacion { get; set; }
        public int CotizacionesRecibidas { get; set; }
        public decimal? MenorPrecioUnitario { get; set; }
        public decimal? ImporteMenorCotizacion { get; set; }
        public DateTime? UltimaCotizacion { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class EstudioMercadoDetalleProveedorResponse
    {
        public int PkidProveedor { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
    }
}

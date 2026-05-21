namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstudioMercadoCotizacionSolicitudResponse
    {
        public int PkidSolicitudCotizacion { get; set; }
        public int FkidEstudioMercadoOrco { get; set; }
        public int FkidProveedorSis { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaCompromisoEntrega { get; set; }
        public string? Comentarios { get; set; }
        public int Estatus { get; set; }
        public int TotalBienes { get; set; }
        public int CotizacionesRecibidas { get; set; }
        public decimal TotalCotizado { get; set; }
    }
}

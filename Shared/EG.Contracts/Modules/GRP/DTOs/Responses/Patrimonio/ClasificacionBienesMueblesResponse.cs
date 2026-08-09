namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class ClasificacionBienesMueblesResponse
    {
        public int PkidOrdenCompra { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public string Requisicion { get; set; } = string.Empty;
        public string Proveedor { get; set; } = string.Empty;
        public string Justificacion { get; set; } = string.Empty;
        public DateTime FechaOrdenCompra { get; set; }
        public DateTime? FechaVigencia { get; set; }
        public decimal? Solicitado { get; set; }
        public decimal? Recibido { get; set; }
        public decimal? Faltante { get; set; }
        public string Estado { get; set; } = string.Empty;
        public string Numero { get; set; } = string.Empty;
        public int? FkidCotizacionOrco { get; set; }
        public int FkidEstatusOrdenCompraOrco { get; set; }
        public int Color { get; set; }
        public decimal? PrecioUnitario { get; set; }
        public decimal? Total { get; set; }
        public int TotalDetalles { get; set; }
        public int TotalBienes { get; set; }
        public decimal PorcentajeRecibido { get; set; }
    }
}

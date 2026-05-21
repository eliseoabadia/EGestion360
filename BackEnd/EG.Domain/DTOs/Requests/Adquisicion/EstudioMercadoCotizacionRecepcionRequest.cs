namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class EstudioMercadoCotizacionRecepcionRequest
    {
        public int FkidEstudioMercadoOrco { get; set; }
        public List<EstudioMercadoCotizacionRecepcionItemRequest> Items { get; set; } = new();
    }

    public class EstudioMercadoCotizacionRecepcionItemRequest
    {
        public int PkidCotizacionDetalle { get; set; }
        public decimal? PrecioUnitario { get; set; }
        public int? TiempoEntregaDias { get; set; }
        public string? Condiciones { get; set; }
    }
}

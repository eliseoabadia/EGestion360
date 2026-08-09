namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class CotizacionRecepcionRequest
    {
        public int FkidCotizacionOrco { get; set; }
        public List<CotizacionRecepcionItemRequest> Items { get; set; } = new();
    }

    public class CotizacionRecepcionItemRequest
    {
        public int PkidCotizacionDetalle { get; set; }
        public decimal? PrecioUnitario { get; set; }
    }
}

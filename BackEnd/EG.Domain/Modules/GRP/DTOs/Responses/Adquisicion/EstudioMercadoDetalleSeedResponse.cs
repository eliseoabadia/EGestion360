namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstudioMercadoDetalleSeedResponse
    {
        public int PaaasDetalleId { get; set; }
        public int EmpresaId { get; set; }
        public int TipoBienId { get; set; }
        public string TipoBienTexto { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public string Observaciones { get; set; } = string.Empty;
    }
}

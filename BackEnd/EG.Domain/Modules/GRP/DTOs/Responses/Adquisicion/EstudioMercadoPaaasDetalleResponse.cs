namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstudioMercadoPaaasDetalleResponse
    {
        public int PaaasDetalleId { get; set; }
        public int EmpresaId { get; set; }
        public int PaaasPartidaId { get; set; }
        public int? PaaasId { get; set; }
        public int TipoBienId { get; set; }
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public string BienClaveNombre { get; set; } = string.Empty;
        public string PartidaClave { get; set; } = string.Empty;
        public string PartidaDescripcion { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public string UnidadMedida { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public string LugarEntrega { get; set; } = string.Empty;
    }
}

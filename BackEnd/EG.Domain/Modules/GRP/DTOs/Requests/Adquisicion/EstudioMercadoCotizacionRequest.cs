namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class EstudioMercadoCotizacionRequest
    {
        public int FkidEstudioMercadoOrco { get; set; }
        public int FkidEmpresaSis { get; set; }
        public DateTime? FechaCompromisoEntrega { get; set; }
        public string? Comentarios { get; set; }
        public bool EnviarCorreo { get; set; }
        public List<EstudioMercadoCotizacionItemRequest> Items { get; set; } = new();
        public List<int> ProveedorIds { get; set; } = new();
    }

    public class EstudioMercadoCotizacionItemRequest
    {
        public int FkidPaaasdetalleOrco { get; set; }
        public string? Observaciones { get; set; }
    }
}

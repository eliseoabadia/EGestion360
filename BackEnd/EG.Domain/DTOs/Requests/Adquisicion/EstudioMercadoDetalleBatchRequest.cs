namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class EstudioMercadoDetalleBatchRequest
    {
        public int FkidEstudioMercadoOrco { get; set; }
        public int FkidEmpresaSis { get; set; }
        public List<EstudioMercadoDetalleBatchItemRequest> Items { get; set; } = new();
    }

    public class EstudioMercadoDetalleBatchItemRequest
    {
        public int FkidPaaasdetalleOrco { get; set; }
        public int? FkidProveedorSis { get; set; }
        public decimal? CostoUnitario { get; set; }
        public string? Observaciones { get; set; }
    }
}

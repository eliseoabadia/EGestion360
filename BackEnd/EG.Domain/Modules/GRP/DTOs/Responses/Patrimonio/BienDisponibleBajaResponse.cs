namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class BienDisponibleBajaResponse
    {
        public int PkidBien { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string ClaveAnt { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Modelo { get; set; } = string.Empty;
        public string Serie { get; set; } = string.Empty;
        public string Factura { get; set; } = string.Empty;
        public decimal? ValorActual { get; set; }
        public int? FkidAreaSis { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public int? FkidEstadoBienAlma { get; set; }
        public string EstadoBienDescripcion { get; set; } = string.Empty;
    }
}

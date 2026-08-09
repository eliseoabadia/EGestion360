namespace EG.Domain.DTOs.Requests.Almacen
{
    public class AlmacenDto
    {
        public int PkidAlmacen { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidAreaSis { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public int? FkidMotivoEsAlma { get; set; }
        public int? FkidDetalleOrdenCompraOrco { get; set; }
        public string Clave { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public decimal? CostoUnitario { get; set; }
        public decimal? Costo { get; set; }
        public string Factura { get; set; } = string.Empty;
        public string Remision { get; set; } = string.Empty;
        public string Lote { get; set; } = string.Empty;
        public DateTime FechaEntrada { get; set; }
        public DateTime? FechaCaducidad { get; set; }
        public bool AplicaAlmacen { get; set; }
        public bool InventarioCerrado { get; set; }
        public bool EsContabilizado { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

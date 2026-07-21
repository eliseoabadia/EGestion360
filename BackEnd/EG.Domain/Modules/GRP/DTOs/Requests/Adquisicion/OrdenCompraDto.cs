namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class OrdenCompraDto
    {
        public int PkidOrdenCompra { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public int FkidProveedorSis { get; set; }
        public int? FkidPolizaConta { get; set; }
        public int FkidEstatusOrdenCompraOrco { get; set; }
        public string NumeroOrdenCompra { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateTime FechaOrdenCompra { get; set; }
        public DateTime? FechaRequerida { get; set; }
        public DateTime? FechaEntrega { get; set; }
        public DateTime? FechaVigencia { get; set; }
        public DateTime? FechaCancelacion { get; set; }
        public string MotivoCancelacion { get; set; } = string.Empty;
        public decimal Subtotal { get; set; }
        public decimal Iva { get; set; }
        public decimal Total { get; set; }
        public int? MonedaId { get; set; }
        public decimal? TipoCambio { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool CompraDirecta { get; set; }
        public string FlDocumento { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public byte[]? RowVersion { get; set; }
    }
}

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class OrdenCompraResponse
    {
        public int PkidOrdenCompra { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int FkidRequisicionOrco { get; set; }
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public DateTime? FechaRequisicion { get; set; }
        public int FkidProveedorSis { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
        public int? FkidPolizaConta { get; set; }
        public string ClavePoliza { get; set; } = string.Empty;
        public int FkidEstatusOrdenCompraOrco { get; set; }
        public string EstatusDescripcion { get; set; } = string.Empty;
        public string EstatusColor { get; set; } = string.Empty;
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
        public string MonedaNombre { get; set; } = string.Empty;
        public string MonedaSimbolo { get; set; } = string.Empty;
        public decimal? TipoCambio { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool CompraDirecta { get; set; }
        public string FlDocumento { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string ClaveNombre { get; set; } = string.Empty;
        public int TotalDetalles { get; set; }
        public int TotalPartidas { get; set; }
        public bool EstaAutorizada => FkidEstatusOrdenCompraOrco > 1;
        public bool PuedeModificar => Activo && FkidEstatusOrdenCompraOrco == 1;
        public byte[]? RowVersion { get; set; }
    }
}

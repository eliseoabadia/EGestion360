namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class OrdenCompraDetalleDto
    {
        public int PkidOrdenCompraDetalle { get; set; }
        public int FkidOrdenCompraOrco { get; set; }
        public int? FkidRequisicionDetalleOrco { get; set; }
        public int? FkidCotizacionDetalleOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int FkidUnidadesAlma { get; set; }
        public decimal CantidadSolicitada { get; set; }
        public decimal CantidadRecibida { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Iva { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

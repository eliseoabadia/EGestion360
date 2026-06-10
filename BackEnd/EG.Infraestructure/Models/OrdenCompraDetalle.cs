// <manual> Complements EF Core Power Tools output when ORCO order purchase objects are not scaffolded. </manual>
#nullable disable
using System;

namespace EG.Infraestructure.Models;

public partial class OrdenCompraDetalle
{
    public int PkidOrdenCompraDetalle { get; set; }

    public int FkidOrdenCompraOrco { get; set; }

    public int? FkidRequisicionDetalleOrco { get; set; }

    public int? FkidCotizacionDetalleOrco { get; set; }

    public int FkidTipoBienAlma { get; set; }

    public int FkidUnidadesAlma { get; set; }

    public decimal CantidadSolicitada { get; set; }

    public decimal CantidadRecibida { get; set; }

    public decimal? CantidadPendiente { get; set; }

    public decimal PrecioUnitario { get; set; }

    public decimal? Importe { get; set; }

    public decimal Iva { get; set; }

    public decimal? TotalDetalle { get; set; }

    public string Observaciones { get; set; }

    public bool Activo { get; set; }

    public DateTime FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }
}

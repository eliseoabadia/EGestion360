// <manual> Complements EF Core Power Tools output when ORCO order purchase objects are not scaffolded. </manual>
#nullable disable
using System;

namespace EG.Infraestructure.Models;

public partial class OrdenCompra
{
    public int PkidOrdenCompra { get; set; }

    public int FkidEmpresaSis { get; set; }

    public int FkidRequisicionOrco { get; set; }

    public int FkidProveedorSis { get; set; }

    public int? FkidPolizaConta { get; set; }

    public int FkidEstatusOrdenCompraOrco { get; set; }

    public string NumeroOrdenCompra { get; set; }

    public string Descripcion { get; set; }

    public DateOnly FechaOrdenCompra { get; set; }

    public DateOnly? FechaRequerida { get; set; }

    public DateOnly? FechaEntrega { get; set; }

    public DateOnly? FechaVigencia { get; set; }

    public DateOnly? FechaCancelacion { get; set; }

    public string MotivoCancelacion { get; set; }

    public decimal Subtotal { get; set; }

    public decimal Iva { get; set; }

    public decimal Total { get; set; }

    public int? MonedaId { get; set; }

    public decimal? TipoCambio { get; set; }

    public string Observaciones { get; set; }

    public bool CompraDirecta { get; set; }

    public string FlDocumento { get; set; }

    public bool Activo { get; set; }

    public DateTime FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }
}

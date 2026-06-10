// <manual> Complements EF Core Power Tools output when ORCO order purchase objects are not scaffolded. </manual>
#nullable disable
using System;

namespace EG.Infraestructure.Models;

public partial class OrdenCompraPartidum
{
    public int PkidOrdenCompraPartida { get; set; }

    public int FkidOrdenCompraOrco { get; set; }

    public int FkidPartidaConta { get; set; }

    public int? FkidFuenteFinanciamientoPres { get; set; }

    public decimal Importe { get; set; }

    public string Observaciones { get; set; }

    public bool Activo { get; set; }

    public DateTime FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }
}

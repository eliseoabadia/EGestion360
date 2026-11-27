namespace EG.Infraestructure.Models;

// Read model for income-linked CLC invoices. The generated expense view omits the income/year relation.
public sealed class IngresoClcFacturaReadModel
{
    public int PkidClcfactura { get; set; }
    public int FkidEmpresaSis { get; set; }
    public string? EmpresaNombre { get; set; }
    public int FkidClcPres { get; set; }
    public string? NumClc { get; set; }
    public int FkidFacturaPres { get; set; }
    public string? NumFactura { get; set; }
    public int FkidFacturaDetallePres { get; set; }
    public int FkidPartidaConta { get; set; }
    public string? PartidaClave { get; set; }
    public string? PartidaDescripcion { get; set; }
    public decimal MontoAplicado { get; set; }
    public string? Observaciones { get; set; }
    public bool Activo { get; set; }
    public DateTime? FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
    public int? FkIdAnioSis { get; set; }
    public int? FkIdIngresoAutorizado { get; set; }
    public DateOnly? Fecha { get; set; }
    public decimal Total { get; set; }
}

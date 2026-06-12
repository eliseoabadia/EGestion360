namespace EG.Domain.DTOs.Responses.CuentasXPagar
{
    public class ContratoResponse
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidAutorizacionSuficienciaPres { get; set; }
        public int FkidSolicitudSuficienciaPres { get; set; }
        public int? FkidRequisicionOrco { get; set; }
        public string? RequisicionDescripcion { get; set; }
        public int FkidProveedorSis { get; set; }
        public string? ProveedorClave { get; set; }
        public string? ProveedorNombre { get; set; }
        public string? ProveedorRfc { get; set; }
        public int? FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public string NumeroContrato { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateOnly FechaContrato { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public DateOnly? FechaInicioVigencia { get; set; }
        public DateOnly? FechaFinVigencia { get; set; }
        public decimal MontoTotal { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class ContratoDetalleResponse
    {
        public int PkidContratoDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidContratoPres { get; set; }
        public string? NumeroContrato { get; set; }
        public int FkidProveedorSis { get; set; }
        public string? ProveedorNombre { get; set; }
        public int FkidAutorizacionSuficienciaDetallePres { get; set; }
        public int FkidPartidaConta { get; set; }
        public string? PartidaClave { get; set; }
        public string? PartidaDescripcion { get; set; }
        public string? PartidaClaveNombre { get; set; }
        public decimal? Enero { get; set; }
        public decimal? Febrero { get; set; }
        public decimal? Marzo { get; set; }
        public decimal? Abril { get; set; }
        public decimal? Mayo { get; set; }
        public decimal? Junio { get; set; }
        public decimal? Julio { get; set; }
        public decimal? Agosto { get; set; }
        public decimal? Septiembre { get; set; }
        public decimal? Octubre { get; set; }
        public decimal? Noviembre { get; set; }
        public decimal? Diciembre { get; set; }
        public decimal? Total { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class FacturaResponse
    {
        public int PkidFactura { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidContratoPres { get; set; }
        public string? NumeroContrato { get; set; }
        public int FkidProveedorSis { get; set; }
        public string? ProveedorNombre { get; set; }
        public int FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public string NumFactura { get; set; } = string.Empty;
        public string? SerieFactura { get; set; }
        public DateOnly FechaEmision { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public DateOnly? FechaRecepcion { get; set; }
        public decimal? Subtotal { get; set; }
        public decimal? Iva { get; set; }
        public decimal? Retencion { get; set; }
        public decimal Total { get; set; }
        public string? Uuid { get; set; }
        public string? FlDocto { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class FacturaDetalleResponse
    {
        public int PkidFacturaDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidFacturaPres { get; set; }
        public string? NumFactura { get; set; }
        public int FkidContratoDetallePres { get; set; }
        public int FkidContratoPres { get; set; }
        public string? NumeroContrato { get; set; }
        public int FkidPartidaConta { get; set; }
        public string? PartidaClave { get; set; }
        public string? PartidaDescripcion { get; set; }
        public string? PartidaClaveNombre { get; set; }
        public decimal MontoAplicado { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class CLCResponse
    {
        public int PkidClc { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidContratoPres { get; set; }
        public string? NumeroContrato { get; set; }
        public int FkidProveedorSis { get; set; }
        public string? ProveedorNombre { get; set; }
        public int FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public string NumClc { get; set; } = string.Empty;
        public DateOnly FechaSolicitud { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public DateOnly? FechaAutorizacion { get; set; }
        public decimal ImporteTotal { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class CLCDetalleResponse
    {
        public int PkidClcdetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidClcPres { get; set; }
        public string? NumClc { get; set; }
        public int FkidContratoDetallePres { get; set; }
        public int FkidContratoPres { get; set; }
        public string? NumeroContrato { get; set; }
        public int FkidPartidaConta { get; set; }
        public string? PartidaClave { get; set; }
        public string? PartidaDescripcion { get; set; }
        public string? PartidaClaveNombre { get; set; }
        public decimal? Enero { get; set; }
        public decimal? Febrero { get; set; }
        public decimal? Marzo { get; set; }
        public decimal? Abril { get; set; }
        public decimal? Mayo { get; set; }
        public decimal? Junio { get; set; }
        public decimal? Julio { get; set; }
        public decimal? Agosto { get; set; }
        public decimal? Septiembre { get; set; }
        public decimal? Octubre { get; set; }
        public decimal? Noviembre { get; set; }
        public decimal? Diciembre { get; set; }
        public decimal? Total { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class CLCFacturaResponse
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
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class ChequeResponse
    {
        public int PkidCheque { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidClcPres { get; set; }
        public string? NumClc { get; set; }
        public int FkidContratoPres { get; set; }
        public string? NumeroContrato { get; set; }
        public int FkidCuentaBancariaTes { get; set; }
        public int FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public DateOnly FechaEmision { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public string NumeroCheque { get; set; } = string.Empty;
        public string Concepto { get; set; } = string.Empty;
        public decimal ImporteTotal { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class ChequePartidaResponse
    {
        public int PkidChequePartida { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidChequePres { get; set; }
        public string? NumeroCheque { get; set; }
        public int FkidClcdetallePres { get; set; }
        public int FkidClcPres { get; set; }
        public string? NumClc { get; set; }
        public int FkidPartidaConta { get; set; }
        public string? PartidaClave { get; set; }
        public string? PartidaDescripcion { get; set; }
        public string? PartidaClaveNombre { get; set; }
        public decimal MontoPagado { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

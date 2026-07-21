namespace EG.Domain.DTOs.Requests.CuentasXPagar
{
    public class ContratoDto
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidAutorizacionSuficienciaPres { get; set; }
        public int FkidProveedorSis { get; set; }
        public int? FkidPolizaConta { get; set; }
        public string NumeroContrato { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateOnly FechaContrato { get; set; }
        public DateOnly? FechaInicioVigencia { get; set; }
        public DateOnly? FechaFinVigencia { get; set; }
        public decimal MontoTotal { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class ContratoDetalleDto
    {
        public int PkidContratoDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidContratoPres { get; set; }
        public int FkidAutorizacionSuficienciaDetallePres { get; set; }
        public int FkidPartidaConta { get; set; }
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
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class FacturaDto
    {
        public int PkidFactura { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidContratoPres { get; set; }
        public int FkidPolizaConta { get; set; }
        public string NumFactura { get; set; } = string.Empty;
        public string? SerieFactura { get; set; }
        public DateOnly FechaEmision { get; set; }
        public DateOnly? FechaRecepcion { get; set; }
        public decimal? Subtotal { get; set; }
        public decimal? Iva { get; set; }
        public decimal? Retencion { get; set; }
        public decimal Total { get; set; }
        public string? Uuid { get; set; }
        public string? FlDocto { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public byte[]? RowVersion { get; set; }
    }

    public class FacturaDetalleDto
    {
        public int PkidFacturaDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidFacturaPres { get; set; }
        public int FkidContratoDetallePres { get; set; }
        public int FkidPartidaConta { get; set; }
        public decimal MontoAplicado { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class CLCDto
    {
        public int PkidClc { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidContratoPres { get; set; }
        public int FkidPolizaConta { get; set; }
        public string NumClc { get; set; } = string.Empty;
        public DateOnly FechaSolicitud { get; set; }
        public DateOnly? FechaAutorizacion { get; set; }
        public decimal ImporteTotal { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class CLCDetalleDto
    {
        public int PkidClcdetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidClcPres { get; set; }
        public int FkidContratoDetallePres { get; set; }
        public int FkidPartidaConta { get; set; }
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
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class CLCFacturaDto
    {
        public int PkidClcfactura { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidClcPres { get; set; }
        public int FkidFacturaPres { get; set; }
        public int FkidFacturaDetallePres { get; set; }
        public decimal MontoAplicado { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class ChequeDto
    {
        public int PkidCheque { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidClcPres { get; set; }
        public int FkidCuentaBancariaTes { get; set; }
        public int FkidPolizaConta { get; set; }
        public DateOnly FechaEmision { get; set; }
        public string NumeroCheque { get; set; } = string.Empty;
        public string Concepto { get; set; } = string.Empty;
        public decimal ImporteTotal { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public byte[]? RowVersion { get; set; }
    }

    public class ChequePartidaDto
    {
        public int PkidChequePartida { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidChequePres { get; set; }
        public int FkidClcdetallePres { get; set; }
        public int FkidPartidaConta { get; set; }
        public decimal MontoPagado { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class DepositoDto
    {
        public int PkidDeposito { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidIngresoAutorizadoPres { get; set; }
        public int FkidTipoDoctoPagoConta { get; set; }
        public decimal Importe { get; set; }
        public string? NumeroReferencia { get; set; }
        public string? ConceptoCheque { get; set; }
        public DateOnly FechaEmision { get; set; }
        public string? NombreAportante { get; set; }
        public int FkidCuentaCargoConta { get; set; }
        public int FkidCuentaAbonoConta { get; set; }
        public int? FkidClcfacturaPres { get; set; }
        public int FkidPolizaConta { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Septiembre { get; set; }
        public decimal Octubre { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }
        public decimal? Total { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

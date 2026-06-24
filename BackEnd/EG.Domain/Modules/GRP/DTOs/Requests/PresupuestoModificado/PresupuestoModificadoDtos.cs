namespace EG.Domain.DTOs.Requests.PresupuestoModificado
{
    public class EgreAdecuacionDto
    {
        public int PkidEgreAdecuacion { get; set; }
        public string? Clave { get; set; }
        public int FkidTipoAdecuacionPres { get; set; }
        public int FkidEstatusAdecuacionPres { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; }
        public int? FkidPolizaConta { get; set; }
        public int FkidAnioSis { get; set; }
        public bool? Autorizado { get; set; }
        public int? FkidAccionAdecuacionMasterPres { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class EgreAdecuacionDetalleDto
    {
        public int PkidEgreAdecuacionDetalle { get; set; }
        public int? FkidEgresoAutorizadoPres { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; }
        public int FkidEgreAdecuacionPres { get; set; }
        public int FkidTipoMovimientoPres { get; set; }
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
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class TipoAdecuacionDto
    {
        public int PkidTipoAdecuacion { get; set; }
        public string? Descripcion { get; set; }
        public bool Activo { get; set; }
    }

    public class EstatusAdecuacionDto
    {
        public int PkidEstatusAdecuacion { get; set; }
        public string? Descripcion { get; set; }
        public string? Color { get; set; }
        public bool Activo { get; set; }
    }

    public class TipoMovimientoDto
    {
        public int PkidTipoMovimiento { get; set; }
        public string? Descripcion { get; set; }
        public bool Activo { get; set; }
    }

    public class EgresoDisponibleDto
    {
        public int PkidEgresoAutorizado { get; set; }
    }

    public class IngreAdecuacionDto
    {
        public int PkidIngreAdecuacion { get; set; }
        public string? Clave { get; set; }
        public int FkidTipoAdecuacionPres { get; set; }
        public int FkidEstatusAdecuacionPres { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; }
        public int? FkidPolizaConta { get; set; }
        public int FkidAnioSis { get; set; }
        public bool Autorizado { get; set; }
        public int? FkidAccionAdecuacionMasterPres { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class IngreAdecuacionDetalleDto
    {
        public int PkidIngreAdecuacionDetalle { get; set; }
        public int FkidIngresoAutorizadoPres { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; }
        public int FkidIngreAdecuacionPres { get; set; }
        public int FkidTipoMovimientoPres { get; set; }
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
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class IngresoDisponibleDto
    {
        public int PkidIngresoAutorizado { get; set; }
    }

    public class IngreXEjerDto
    {
        public int PkIdIngresoAutorizado { get; set; }
    }

    public class IngresoCLCFacturaDto
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
}

namespace EG.Domain.DTOs.Responses.PresupuestoModificado
{
    public class EgreAdecuacionResponse
    {
        public int PkidEgreAdecuacion { get; set; }
        public string? Clave { get; set; }
        public int FkidTipoAdecuacionPres { get; set; }
        public string? TipoAdecuacionDescripcion { get; set; }
        public int FkidEstatusAdecuacionPres { get; set; } = 1;
        public string? EstatusAdecuacionDescripcion { get; set; }
        public string? EstatusAdecuacionColor { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public int? FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public int FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public bool? Autorizado { get; set; }
        public int? FkidAccionAdecuacionMasterPres { get; set; } = 1;
        public string? AccionAdecuacion { get; set; }
        public string? AccionComentario { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string? ClaveNombre { get; set; }
        public string? Message { get; set; }
    }

    public class EgreAdecuacionDetalleResponse
    {
        public int PkidEgreAdecuacionDetalle { get; set; }
        public int FkidEgreAdecuacionPres { get; set; }
        public string? EgreAdecuacionClave { get; set; }
        public bool? Autorizado { get; set; }
        public int? FkidEgresoAutorizadoPres { get; set; }
        public string? EgresoAutorizadoDescripcion { get; set; }
        public int FkidTipoMovimientoPres { get; set; }
        public string? TipoMovimientoDescripcion { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; } = DateOnly.FromDateTime(DateTime.Today);
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
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string? Message { get; set; }
    }

    public class TipoAdecuacionResponse
    {
        public int PkidTipoAdecuacion { get; set; }
        public string? Descripcion { get; set; }
        public bool Activo { get; set; } = true;
    }

    public class EstatusAdecuacionResponse
    {
        public int PkidEstatusAdecuacion { get; set; }
        public string? Descripcion { get; set; }
        public string? Color { get; set; }
        public bool Activo { get; set; } = true;
    }

    public class TipoMovimientoResponse
    {
        public int PkidTipoMovimiento { get; set; }
        public string? Descripcion { get; set; }
        public bool Activo { get; set; } = true;
    }

    public class EgresoDisponibleResponse
    {
        public int PkidEgresoAutorizado { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public int FkidProgramaPres { get; set; }
        public string? ProgramaClaveNombre { get; set; }
        public int FkidPartidaConta { get; set; }
        public string? PartidaClaveNombre { get; set; }
        public int FkidAreaSis { get; set; }
        public string? AreaNombre { get; set; }
        public string? Descripcion { get; set; }
        public DateOnly Fecha { get; set; }
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
        public string? DescripcionRequisicion { get; set; }
    }

    public class IngreAdecuacionResponse
    {
        public int PkidIngreAdecuacion { get; set; }
        public string? Clave { get; set; }
        public int FkidTipoAdecuacionPres { get; set; }
        public string? TipoAdecuacionDescripcion { get; set; }
        public int FkidEstatusAdecuacionPres { get; set; } = 1;
        public string? EstatusAdecuacionDescripcion { get; set; }
        public string? EstatusAdecuacionColor { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public int? FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public int FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public bool Autorizado { get; set; }
        public int? FkidAccionAdecuacionMasterPres { get; set; } = 1;
        public string? AccionAdecuacion { get; set; }
        public string? AccionComentario { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public decimal TotalAumento { get; set; }
        public decimal TotalReduccion { get; set; }
        public decimal? Diferencia { get; set; }
        public bool? HasChild { get; set; }
        public string? Color { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string? ClaveNombre { get; set; }
        public string? Message { get; set; }
    }

    public class IngreAdecuacionDetalleResponse
    {
        public int PkidIngreAdecuacionDetalle { get; set; }
        public int FkidIngreAdecuacionPres { get; set; }
        public string? IngreAdecuacionClave { get; set; }
        public int FkidAnioSis { get; set; }
        public bool Autorizado { get; set; }
        public int FkidIngresoAutorizadoPres { get; set; }
        public string? IngresoAutorizadoDescripcion { get; set; }
        public int FkidProgramaPres { get; set; }
        public string? ProgramaClave { get; set; }
        public string? ProgramaDescripcion { get; set; }
        public int FkidOrigenPres { get; set; }
        public int OrigenClave { get; set; }
        public string? OrigenDescripcion { get; set; }
        public string? PosicionPresupuestal { get; set; }
        public int FkidTipoMovimientoPres { get; set; }
        public string? TipoMovimientoDescripcion { get; set; }
        public string? Justificacion { get; set; }
        public DateOnly Fecha { get; set; } = DateOnly.FromDateTime(DateTime.Today);
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
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string? Message { get; set; }
    }

    public class IngresoDisponibleResponse
    {
        public int PkidIngresoAutorizado { get; set; }
        public int FkidProgramaPres { get; set; }
        public int? FkidAnioSis { get; set; }
        public string? ProgramaClaveNombre { get; set; }
        public int FkidOrigenPres { get; set; }
        public string? OrigenClaveNombre { get; set; }
        public string? PosicionPresupuestal { get; set; }
        public string? Descripcion { get; set; }
        public DateOnly Fecha { get; set; }
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
        public DateTime? FechaAutorizacion { get; set; }
        public bool Activo { get; set; }
        public string? DescripcionRequisicion { get; set; }
    }

    public class IngreXEjerResponse
    {
        public int PkIdIngresoAutorizado { get; set; }
        public string? AreaFuncional { get; set; }
        public string? Origen { get; set; }
        public int? FkIdAnioSis { get; set; }
        public int FkIdProgramaPres { get; set; }
        public int FkIdOrigenPres { get; set; }
        public string? Descripcion { get; set; }
        public decimal? Ene { get; set; }
        public decimal? Feb { get; set; }
        public decimal? Mar { get; set; }
        public decimal? Abr { get; set; }
        public decimal? May { get; set; }
        public decimal? Jun { get; set; }
        public decimal? Jul { get; set; }
        public decimal? Ago { get; set; }
        public decimal? Sep { get; set; }
        public decimal? Oct { get; set; }
        public decimal? Nov { get; set; }
        public decimal? Dic { get; set; }
        public decimal? Total { get; set; }
        public string? Message { get; set; }
    }

    public class IngresoCLCFacturaResponse
    {
        public int PkidClcfactura { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidClcPres { get; set; }
        public string? NumClc { get; set; }
        public int FkidFacturaPres { get; set; }
        public string? NumFactura { get; set; }
        public int? FkIdAnioSis { get; set; }
        public int? FkIdIngresoAutorizado { get; set; }
        public DateOnly? Fecha { get; set; }
        public int? FkIdBancoSis { get; set; }
        public int? FkIdCuentaAbono { get; set; }
        public int? FkIdCuentaCargo { get; set; }
        public int? FkIdPolizaConta { get; set; }
        public int? FkIdTipoClcfacturaPres { get; set; }
        public int? FkIdTipoDoctoClcSis { get; set; }
        public int? FkIdTipoPoliza { get; set; }
        public bool? Fldocto { get; set; }
        public decimal? Importe { get; set; }
        public decimal? Iva { get; set; }
        public string? Concepto { get; set; }
        public string? Nombre { get; set; }
        public string? Rfc { get; set; }
        public string? NumReferenciaDocto { get; set; }
        public decimal? Ene { get; set; }
        public decimal? Feb { get; set; }
        public decimal? Mar { get; set; }
        public decimal? Abr { get; set; }
        public decimal? May { get; set; }
        public decimal? Jun { get; set; }
        public decimal? Jul { get; set; }
        public decimal? Ago { get; set; }
        public decimal? Sep { get; set; }
        public decimal? Oct { get; set; }
        public decimal? Nov { get; set; }
        public decimal? Dic { get; set; }
        public decimal? Total { get; set; }
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
        public string? Message { get; set; }
    }
}

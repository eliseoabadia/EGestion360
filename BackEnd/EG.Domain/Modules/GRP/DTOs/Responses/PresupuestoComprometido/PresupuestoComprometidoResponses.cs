namespace EG.Domain.DTOs.Responses.PresupuestoComprometido
{
    public class AutorizacionSuficienciaResponse
    {
        public int PkidAutorizacionSuficiencia { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidSolicitudSuficienciaPres { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public int? FkidAnioSis { get; set; }
        public string? RequisicionDescripcion { get; set; }
        public DateOnly FechaSolicitud { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public DateOnly FechaAutorizacion { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public string? Justificacion { get; set; }
        public string? GastoNoProgramable { get; set; }
        public int? IdGastoNoProgramable { get; set; }
        public int? IdCompromisoNomina { get; set; }
        public int AutorizadoPorNom { get; set; }
        public string? AutorizadoPorNombre { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class AutorizacionSuficienciaDetalleResponse
    {
        public int PkidAutorizacionSuficienciaDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidAutorizacionSuficienciaPres { get; set; }
        public int FkidSolicitudSuficienciaPres { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public string? RequisicionDescripcion { get; set; }
        public DateOnly FechaAutorizacion { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public int AutorizacionEstatus { get; set; }
        public int FkidSolicitudSuficienciaDetallePres { get; set; }
        public int? FkidRequisicionDetalleOrco { get; set; }
        public int? FkidTipoBienAlma { get; set; }
        public string? TipoBienClave { get; set; }
        public string? TipoBienDescripcion { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public string? UnidadMedida { get; set; }
        public decimal? Cantidad { get; set; }
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
}

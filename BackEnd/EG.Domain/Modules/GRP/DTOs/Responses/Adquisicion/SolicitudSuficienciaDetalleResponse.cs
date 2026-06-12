namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class SolicitudSuficienciaDetalleResponse
    {
        public int PkidSolicitudSuficienciaDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int FkidSolicitudSuficienciaPres { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public DateOnly FechaSolicitud { get; set; }
        public int SolicitudEstatus { get; set; }
        public int FkidRequisicionDetalleOrco { get; set; }
        public int? FkidTipoBienAlma { get; set; }
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public int? FkidUnidadesAlma { get; set; }
        public string UnidadMedida { get; set; } = string.Empty;
        public decimal? Cantidad { get; set; }
        public int FkidPartidaConta { get; set; }
        public string PartidaClave { get; set; } = string.Empty;
        public string PartidaDescripcion { get; set; } = string.Empty;
        public string PartidaClaveNombre { get; set; } = string.Empty;
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
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

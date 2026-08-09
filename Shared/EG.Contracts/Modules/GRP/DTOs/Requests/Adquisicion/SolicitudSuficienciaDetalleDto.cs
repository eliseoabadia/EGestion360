namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class SolicitudSuficienciaDetalleDto
    {
        public int PkidSolicitudSuficienciaDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidSolicitudSuficienciaPres { get; set; }
        public int FkidRequisicionDetalleOrco { get; set; }
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
        public decimal? Total { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

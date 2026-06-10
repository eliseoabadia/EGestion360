namespace EG.Domain.DTOs.Requests.Almacen
{
    public class DetalleSolicitudSalidaDto
    {
        public int PkidDetalleSolicitudSalida { get; set; }
        public int FkidSolicitudSalidaAlma { get; set; }
        public int? FkidAlmacenAlma { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public decimal CantidadSolicitada { get; set; }
        public decimal? CantidadAutorizada { get; set; }
        public decimal? CantidadEntregada { get; set; }
        public decimal CantidadPendiente { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

namespace EG.Domain.DTOs.Responses.Almacen
{
    public class DetalleSolicitudSalidaResponse
    {
        public int PkidDetalleSolicitudSalida { get; set; }
        public int FkidSolicitudSalidaAlma { get; set; }
        public string SolicitudFolio { get; set; } = string.Empty;
        public int? FkidAlmacenAlma { get; set; }
        public string AlmacenClave { get; set; } = string.Empty;
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public int? FkidUnidadesAlma { get; set; }
        public string UnidadDescripcion { get; set; } = string.Empty;
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
        public bool EstaSurtido => CantidadPendiente <= 0;
    }
}

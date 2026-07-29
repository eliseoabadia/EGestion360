namespace EG.Domain.DTOs.Requests.Almacen
{
    public class SolicitudSalidaDto
    {
        public int PkidSolicitudSalida { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidAreaSolicitaSis { get; set; }
        public int? FkidAreaEntregaSis { get; set; }
        public int FkidEstatusSolicitudSalidaAlma { get; set; }
        public string Folio { get; set; } = string.Empty;
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaRequerida { get; set; }
        public string Solicitante { get; set; } = string.Empty;
        public string Justificacion { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public bool Autorizado { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public int? UsuarioAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public int? FkidPolizaConta { get; set; }
    }
}

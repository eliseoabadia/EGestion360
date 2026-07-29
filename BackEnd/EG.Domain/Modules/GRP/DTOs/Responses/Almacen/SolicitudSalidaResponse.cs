namespace EG.Domain.DTOs.Responses.Almacen
{
    public class SolicitudSalidaResponse
    {
        public int PkidSolicitudSalida { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int? FkidAreaSolicitaSis { get; set; }
        public string AreaSolicitaNombre { get; set; } = string.Empty;
        public int? FkidAreaEntregaSis { get; set; }
        public string AreaEntregaNombre { get; set; } = string.Empty;
        public int FkidEstatusSolicitudSalidaAlma { get; set; }
        public string EstatusDescripcion { get; set; } = string.Empty;
        public string EstatusColor { get; set; } = string.Empty;
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
        public bool EsFinal { get; set; }
        public int TotalDetalles { get; set; }
        public decimal TotalSolicitado { get; set; }
        public decimal TotalAutorizado { get; set; }
        public decimal TotalEntregado { get; set; }
        public decimal TotalPendiente { get; set; }
        public bool PuedeModificar => Activo && !Autorizado && !EsFinal;
    }
}

namespace EG.Domain.DTOs.Responses.General
{
    public class NotificacionResumenResponse
    {
        public int Total { get; set; }
        public int Pendientes { get; set; }
        public int Leidas { get; set; }
        public int Atendidas { get; set; }
        public int RequierenAccion { get; set; }
    }

    public class NotificacionUsuarioResponse
    {
        public long PkidNotificacionDestino { get; set; }
        public long PkidNotificacion { get; set; }
        public int? FkidUsuarioOrigen { get; set; }
        public int FkidUsuarioDestino { get; set; }
        public string? Tipo { get; set; }
        public string? Modulo { get; set; }
        public string? SubModulo { get; set; }
        public string? Evento { get; set; }
        public string? Entidad { get; set; }
        public long? FkidEntidad { get; set; }
        public string? Titulo { get; set; }
        public string? Mensaje { get; set; }
        public string? Url { get; set; }
        public string? JsonData { get; set; }
        public string? UsuarioOrigenNombre { get; set; }
        public string? UsuarioDestinoNombre { get; set; }
        public string? Destinatarios { get; set; }
        public string? Estado { get; set; }
        public int FkidNotificacionEstado { get; set; }
        public DateTime? FechaLeido { get; set; }
        public DateTime? FechaAtendido { get; set; }
        public DateTime FechaNotificacion { get; set; }
        public bool FueCreadaPorMi { get; set; }
        public bool EsRespuesta { get; set; }
        public int NivelConversacion { get; set; }
        public bool EstaPendiente => FkidNotificacionEstado == 1;
        public bool EstaAtendida => FkidNotificacionEstado == 3;
    }

    public class NotificacionResponderRequest
    {
        public string Mensaje { get; set; } = string.Empty;
    }
}

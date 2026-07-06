namespace EG.Domain.DTOs.Responses.General;

public class UsuarioAreaResponse
{
    public int? PkidPersonaArea { get; set; }
    public int PkidPersona { get; set; }
    public string PersonaClave { get; set; } = string.Empty;
    public string PersonaNombre { get; set; } = string.Empty;
    public string PersonaPaterno { get; set; } = string.Empty;
    public string PersonaMaterno { get; set; } = string.Empty;
    public bool IsAdscrito { get; set; }
    public bool EsSolicitante { get; set; }
    public bool EsAutorizador { get; set; }
    public int PkidArea { get; set; }
    public string AreaClave { get; set; } = string.Empty;
    public string AreaNombre { get; set; } = string.Empty;
    public bool Activo { get; set; }
    public string UsuarioAreaDescripcion { get; set; } = string.Empty;
}

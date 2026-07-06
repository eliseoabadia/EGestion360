namespace EG.Domain.DTOs.Requests.General;

public class UsuarioAreaDto
{
    public int PkidArea { get; set; }
}

public class UsuarioAreaAsignacionRequest
{
    public int PersonaId { get; set; }
    public int AreaId { get; set; }
    public bool IsAdscrito { get; set; } = true;
    public bool EsSolicitante { get; set; } = true;
    public bool EsAutorizador { get; set; }
}

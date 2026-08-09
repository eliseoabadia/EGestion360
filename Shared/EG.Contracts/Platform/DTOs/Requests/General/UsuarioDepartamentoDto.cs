namespace EG.Domain.DTOs.Requests.General;

public class UsuarioDepartamentoAsignacionRequest
{
    public int UsuarioId { get; set; }
    public int DepartamentoId { get; set; }
    public bool EsJefe { get; set; }
}

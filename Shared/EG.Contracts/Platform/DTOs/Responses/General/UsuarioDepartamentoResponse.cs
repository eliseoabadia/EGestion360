namespace EG.Domain.DTOs.Responses.General;

public class UsuarioDepartamentoResponse
{
    public int UsuarioId { get; set; }
    public int DepartamentoId { get; set; }
    public int EmpresaId { get; set; }
    public string UsuarioNombre { get; set; } = string.Empty;
    public string DepartamentoNombre { get; set; } = string.Empty;
    public string EmpresaNombre { get; set; } = string.Empty;
    public bool EsJefe { get; set; }
    public bool Activo { get; set; }
    public DateTime? FechaAsignacion { get; set; }
}

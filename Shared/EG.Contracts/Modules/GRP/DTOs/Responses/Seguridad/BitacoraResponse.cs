namespace EG.Domain.DTOs.Responses.Seguridad;

public sealed class BitacoraResponse
{
    public int PkidSystemLog { get; set; }
    public DateTime? Date { get; set; }
    public string? EmployeeNo { get; set; }
    public string? ProgName { get; set; }
    public string? Category { get; set; }
    public string? Level { get; set; }
    public string? Message { get; set; }
    public string? MethodName { get; set; }
    public string? Ipclient { get; set; }
    public string? HostName { get; set; }
    public int? ExecutionTime { get; set; }
    public string? TipoCatalogo { get; set; }
    public string? Valor { get; set; }
    public string? Etiqueta { get; set; }
    public int Cantidad { get; set; }
}

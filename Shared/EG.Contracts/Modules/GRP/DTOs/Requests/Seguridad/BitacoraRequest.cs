namespace EG.Domain.DTOs.Requests.Seguridad;

public sealed class BitacoraRequest
{
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
    public string? Filtro { get; set; }
    public string? SearchString { get; set; }
    public string? SortLabel { get; set; }
    public string? SortDirection { get; set; }
    public DateTime Desde { get; set; }
    public DateTime Hasta { get; set; }
    public string? Usuario { get; set; }
    public string? Modulo { get; set; }
    public string? Nivel { get; set; }
    public bool SinUsuario { get; set; }
    public string? Referencia { get; set; }
    public string? Categoria { get; set; }
}

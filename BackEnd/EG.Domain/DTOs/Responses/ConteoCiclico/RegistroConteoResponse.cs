namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public partial class RegistroConteoResponse
{
    public int Id { get; set; }

    public int ArticuloConteoId { get; set; }

    public int PeriodoId { get; set; }

    public int SucursalId { get; set; }

    public string CodigoPeriodo { get; set; }

    public string PeriodoNombre { get; set; }

    public string SucursalNombre { get; set; }

    public int TipoBienId { get; set; }

    public string CodigoArticulo { get; set; }

    public string DescripcionArticulo { get; set; }

    public decimal ExistenciaSistema { get; set; }

    public int NumeroConteo { get; set; }

    public decimal CantidadContada { get; set; }

    public DateTime FechaConteo { get; set; }

    public string Observaciones { get; set; }

    public bool EsReconteo { get; set; }

    public string FotoPath { get; set; }

    public decimal? Latitud { get; set; }

    public decimal? Longitud { get; set; }

    public int UsuarioId { get; set; }

    public string UsuarioNombre { get; set; }

    public string UsuarioEmail { get; set; }

    public string UsuarioIniciales { get; set; }

    public decimal? PromedioConteos { get; set; }

    public decimal? DiferenciaVsSistema { get; set; }

    public decimal? PorcentajeVsSistema { get; set; }

    public string ConteoDescripcion { get; set; }

    public string ColorConteo { get; set; }

    public string IconoConteo { get; set; }

    public int EsUltimoConteo { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

}
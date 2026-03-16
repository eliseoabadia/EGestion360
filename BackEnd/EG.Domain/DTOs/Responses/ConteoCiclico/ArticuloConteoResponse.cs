namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public partial class ArticuloConteoResponse
{
    public int Id { get; set; }

    public int PeriodoId { get; set; }

    public string CodigoPeriodo { get; set; }

    public string PeriodoNombre { get; set; }

    public int TipoBienId { get; set; }

    public string CodigoArticulo { get; set; }

    public string DescripcionArticulo { get; set; }

    public int SucursalId { get; set; }

    public string SucursalNombre { get; set; }

    public int EstatusId { get; set; }

    public string EstatusNombre { get; set; }

    public string EstatusDescripcion { get; set; }

    public string CodigoBarras { get; set; }

    public string Ubicacion { get; set; }

    public decimal ExistenciaSistema { get; set; }

    public decimal? ExistenciaFinal { get; set; }

    public decimal? Diferencia { get; set; }

    public decimal? PorcentajeDiferencia { get; set; }

    public int? FechaUltimoConteoAnterior { get; set; }

    public int ConteosRealizados { get; set; }

    public int ConteosPendientes { get; set; }

    public int MaximoConteosPorArticulo { get; set; }

    public int? ConteosRestantes { get; set; }

    public int EstaConcluido { get; set; }

    public string EstaConcluidoTexto { get; set; }

    public int RequiereTercerConteo { get; set; }

    public DateTime? FechaInicioConteo { get; set; }

    public DateTime? FechaConclusion { get; set; }

    public int? UsuarioConcluyoId { get; set; }

    public string UsuarioConcluyoNombre { get; set; }

    public int? DiscrepanciaId { get; set; }

    public decimal? DiscrepanciaValor1 { get; set; }

    public decimal? DiscrepanciaValor2 { get; set; }

    public decimal? DiscrepanciaValor3 { get; set; }

    public decimal? DiscrepanciaValorAceptado { get; set; }

    public string DiscrepanciaMetodo { get; set; }

    public int TieneDiscrepanciaPendiente { get; set; }

    public string HistorialConteosTexto { get; set; }

    public decimal? UltimoConteo { get; set; }

    public decimal? PrimerConteo { get; set; }

    public decimal? SegundoConteo { get; set; }

    public decimal? TercerConteo { get; set; }

    public string ConteosJson { get; set; }

    public string ColorEstatus { get; set; }

    public string IconoEstatus { get; set; }

    public string BadgeTexto { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public string UsuarioCreacionNombre { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public string UsuarioModificacionNombre { get; set; }


}
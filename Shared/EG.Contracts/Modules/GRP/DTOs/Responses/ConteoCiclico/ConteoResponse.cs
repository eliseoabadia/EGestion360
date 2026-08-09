namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public class ConteoResponse
{
    public int PkidConteo { get; set; }

    public decimal CantidadInventario { get; set; }

    public string Descripcion { get; set; }

    public DateTime FechaInicio { get; set; }

    public DateTime? FechaFin { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public int? IdPeriodoConteo { get; set; }

    public string CodigoPeriodo { get; set; }

    public string NombrePeriodo { get; set; }

    public DateOnly? PeriodoFechaInicio { get; set; }

    public DateOnly? PeriodoFechaFin { get; set; }

    public int? IdTipoConteo { get; set; }

    public string TipoConteo { get; set; }

    public string DescripcionTipoConteo { get; set; }

    public int? IdEstatusPeriodo { get; set; }

    public string EstatusPeriodo { get; set; }

    public string DescripcionEstatusPeriodo { get; set; }

    public int? IdTipoBien { get; set; }

    public string CodigoClaveTipoBien { get; set; }

    public string DescripcionTipoBien { get; set; }

    public int? IdGrupoBien { get; set; }

    public string GrupoBien { get; set; }

    public int? IdFamilia { get; set; }

    public string Familia { get; set; }

    public int? IdUnidad { get; set; }

    public string UnidadMedida { get; set; }

    public int? IdUsuarioCreacion { get; set; }

    public string NombreUsuarioCreacion { get; set; }

    public int? IdUsuarioModificacion { get; set; }

    public string NombreUsuarioModificacion { get; set; }

    public int TotalLecturas { get; set; }

    public decimal TotalCantidadContada { get; set; }

    public int PersonasParticipantes { get; set; }

    public string EstadoConteo { get; set; }
}

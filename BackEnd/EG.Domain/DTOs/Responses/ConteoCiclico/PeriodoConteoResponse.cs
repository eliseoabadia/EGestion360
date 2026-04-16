namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public class PeriodoConteoResponse
{
    public int PkidPeriodoConteo { get; set; }

    public string CodigoPeriodo { get; set; }

    public string Nombre { get; set; }

    public string Descripcion { get; set; }

    public DateOnly FechaInicio { get; set; }

    public DateOnly? FechaFin { get; set; }

    public DateTime? FechaCierre { get; set; }

    public int MaximoConteosPorArticulo { get; set; }

    public bool RequiereAprobacionSupervisor { get; set; }

    public int? TotalArticulos { get; set; }

    public int? ArticulosConcluidos { get; set; }

    public int? ArticulosConDiferencia { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public int? IdSucursal { get; set; }

    public string? Sucursal { get; set; }

    public int? IdTipoConteo { get; set; }

    public string? TipoConteo { get; set; }

    public string? DescripcionTipoConteo { get; set; }

    public int? IdEstatusPeriodo { get; set; }

    public string? EstatusPeriodo { get; set; }

    public string? DescripcionEstatusPeriodo { get; set; }

    public int? IdResponsable { get; set; }

    public string? Responsable { get; set; }

    public int? IdSupervisor { get; set; }

    public string? Supervisor { get; set; }
}

namespace EG.Web.Models.ConteoCiclico;

public class NumeroConteoResponse
{
    public int PkidPeriodoConteo { get; set; }

    public string CodigoPeriodo { get; set; } = string.Empty;

    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

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

    public string Sucursal { get; set; } = string.Empty;

    public int? IdTipoConteo { get; set; }

    public string TipoConteo { get; set; } = string.Empty;

    public string DescripcionTipoConteo { get; set; } = string.Empty;

    public int? IdEstatusPeriodo { get; set; }

    public string EstatusPeriodo { get; set; } = string.Empty;

    public string DescripcionEstatusPeriodo { get; set; } = string.Empty;

    public int? IdResponsable { get; set; }

    public string Responsable { get; set; } = string.Empty;

    public int? IdSupervisor { get; set; }

    public string Supervisor { get; set; } = string.Empty;
}

namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public partial class PeriodoConteoResponse
{
    public int Id { get; set; }

    public int SucursalId { get; set; }

    public string SucursalNombre { get; set; }

    public int TipoConteoId { get; set; }

    public string TipoConteoNombre { get; set; }

    public int EstatusId { get; set; }

    public string EstatusNombre { get; set; }

    public string CodigoPeriodo { get; set; }

    public string Nombre { get; set; }

    public string Descripcion { get; set; }

    public DateOnly FechaInicio { get; set; }

    public DateOnly? FechaFin { get; set; }

    public DateTime? FechaCierre { get; set; }

    public int MaximoConteosPorArticulo { get; set; }

    public bool RequiereAprobacionSupervisor { get; set; }

    public int? ResponsableId { get; set; }

    public string ResponsableNombre { get; set; }

    public int? SupervisorId { get; set; }

    public string SupervisorNombre { get; set; }

    public int? TotalArticulos { get; set; }

    public int? ArticulosConcluidos { get; set; }

    public int? ArticulosConDiferencia { get; set; }

    public int? ArticulosPendientes { get; set; }

    public decimal? PorcentajeAvance { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public string UsuarioCreacionNombre { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public string UsuarioModificacionNombre { get; set; }
}
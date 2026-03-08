namespace EG.Web.Models.ConteoCiclico;

public partial class VwResumenPeriodoResponse
{
    public int PkidPeriodoConteo { get; set; }

    public string CodigoPeriodo { get; set; }

    public string Periodo { get; set; }

    public string Sucursal { get; set; }

    public string TipoConteo { get; set; }

    public string Estatus { get; set; }

    public DateOnly FechaInicio { get; set; }

    public DateOnly? FechaFin { get; set; }

    public DateTime? FechaCierre { get; set; }

    public int? TotalArticulos { get; set; }

    public int? ArticulosConcluidos { get; set; }

    public int? ArticulosConDiferencia { get; set; }

    public int? ArticulosPendientes { get; set; }

    public int? ContadoresParticiparon { get; set; }

    public int? TotalConteosRegistrados { get; set; }
}
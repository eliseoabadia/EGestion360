namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public class ConteoPlanificacionResponse
{
    public int PkidPlanConteoCiclico { get; set; }
    public int IdTipoBien { get; set; }
    public string CodigoTipoBien { get; set; } = string.Empty;
    public string TipoBien { get; set; } = string.Empty;
    public int? IdArea { get; set; }
    public string Ubicacion { get; set; } = "Sin ubicacion asignada";
    public string ClasificacionAbc { get; set; } = "C";
    public int FrecuenciaDias { get; set; }
    public DateOnly? UltimaFechaConteo { get; set; }
    public DateOnly ProximaFechaConteo { get; set; }
    public decimal ExistenciaActual { get; set; }
    public decimal? ExistenciaMinima { get; set; }
    public decimal ValorInventario { get; set; }
    public bool GenerarPorUmbral { get; set; }
    public bool RequiereConteoPorUmbral { get; set; }
    public bool EstaVencido { get; set; }
    public bool Activo { get; set; }
}

public class ConteoPlanificacionUpdateRequest
{
    public int? IdArea { get; set; }
    public int FrecuenciaDias { get; set; }
    public DateOnly ProximaFechaConteo { get; set; }
    public bool GenerarPorUmbral { get; set; } = true;
}

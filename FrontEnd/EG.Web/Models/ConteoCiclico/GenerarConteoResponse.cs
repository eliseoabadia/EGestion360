namespace EG.Web.Models.ConteoCiclico
{
    public class GenerarConteoRequest
    {
        public int PeriodoId { get; set; }
        public int SucursalId { get; set; }
        public List<int>? ArticulosSeleccionados { get; set; }
    }

    public class RegistrarConteoRequest
    {
        public int ArticuloConteoId { get; set; }
        public decimal CantidadContada { get; set; }
        public string? Observaciones { get; set; }
        public string? FotoPath { get; set; }
        public decimal? Latitud { get; set; }
        public decimal? Longitud { get; set; }
        public bool EsReconteo { get; set; }
    }

    public class CerrarConteoRequest
    {
        public int ArticuloConteoId { get; set; }
        public decimal? ExistenciaFinal { get; set; }
    }

    public class ConteoResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = null!;
        public object? Data { get; set; }
    }

    public class DashboardResponse
    {
        public int TotalPeriodosActivos { get; set; }
        public int TotalArticulosEnConteo { get; set; }
        public int TotalArticulosConcluidos { get; set; }
        public int TotalArticulosConDiferencia { get; set; }
        public decimal PorcentajeAvanceGeneral { get; set; }
        public List<PeriodoResumen> PeriodosResumen { get; set; } = new();
        public List<ArticuloConteoResponse> UltimosArticulosConcluidos { get; set; } = new();
        public List<RegistroConteoResponse> UltimosRegistros { get; set; } = new();
    }

    public class PeriodoResumen
    {
        public int PeriodoId { get; set; }
        public string PeriodoNombre { get; set; } = null!;
        public string SucursalNombre { get; set; } = null!;
        public int TotalArticulos { get; set; }
        public int Concluidos { get; set; }
        public int Pendientes { get; set; }
        public int ConDiferencia { get; set; }
        public decimal PorcentajeAvance { get; set; }
        public string EstatusNombre { get; set; } = null!;
    }
}

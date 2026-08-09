namespace EG.Domain.DTOs.Responses.PBR
{
    public class PbrDashboardResponse
    {
        public int Anio { get; set; }
        public DateTime Generado { get; set; }
        public PbrDashboardResumenResponse Resumen { get; set; } = new();
        public List<PbrSemaforoIndicadorResponse> Semaforo { get; set; } = new();
        public PbrSemaforoConteoResponse SemaforoConteo { get; set; } = new();
        public List<PbrRankingProgramaResponse> RankingProgramas { get; set; } = new();
        public List<PbrCoberturaMirResponse> CoberturaMir { get; set; } = new();
        public List<PbrTopPresupuestoResponse> TopPresupuestos { get; set; } = new();
    }

    public class PbrDashboardResumenResponse
    {
        public int TotalProgramas { get; set; }
        public int TotalIndicadores { get; set; }
        public int TotalEvaluaciones { get; set; }
        public int AsmActivos { get; set; }
        public int IndicadoresCumpliendo { get; set; }
        public decimal CumplimientoPromedio { get; set; }
        public decimal PresupuestoAnual { get; set; }
        public decimal PresupuestoModificado { get; set; }
        public int ProgramasConMirCompleta { get; set; }
        public decimal CoberturaMirPorcentaje { get; set; }
    }

    public class PbrSemaforoConteoResponse
    {
        public int Verde { get; set; }
        public int Amarillo { get; set; }
        public int Rojo { get; set; }
        public int SinDatos { get; set; }
    }

    public class PbrSemaforoIndicadorResponse
    {
        public int PkidIndicador { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Programa { get; set; } = string.Empty;
        public string Nivel { get; set; } = string.Empty;
        public decimal? Programado { get; set; }
        public decimal? Alcanzado { get; set; }
        public decimal? Porcentaje { get; set; }
        public string Estado { get; set; } = "sin_datos";
    }

    public class PbrRankingProgramaResponse
    {
        public int PkidPrograma { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Dependencia { get; set; } = string.Empty;
        public int TotalIndicadores { get; set; }
        public int IndicadoresConAvance { get; set; }
        public int IndicadoresCumpliendo { get; set; }
        public decimal Cumplimiento { get; set; }
        public decimal Presupuesto { get; set; }
    }

    public class PbrCoberturaMirResponse
    {
        public int PkidPrograma { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public bool TieneFin { get; set; }
        public bool TieneProposito { get; set; }
        public bool TieneComponente { get; set; }
        public bool TieneActividad { get; set; }
        public bool Completa { get; set; }
        public int TotalIndicadores { get; set; }
    }

    public class PbrTopPresupuestoResponse
    {
        public int PkidPresupuestoPrograma { get; set; }
        public int? PkidPrograma { get; set; }
        public string ProgramaClave { get; set; } = string.Empty;
        public string Programa { get; set; } = string.Empty;
        public decimal PresupuestoAnual { get; set; }
        public decimal PresupuestoModificado { get; set; }
    }
}

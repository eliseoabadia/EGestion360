using System;

namespace EG.Domain.DTOs.Requests.Nomina
{
    public class NominaProcesoRequest
    {
        public int? EmpresaId { get; set; }
        public int? PeriodoId { get; set; }
        public int? PersonaId { get; set; }
        public int? Anio { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public DateTime? FechaProceso { get; set; }
    }
}

using System;

namespace EG.Domain.DTOs.Responses.Nomina
{
    public class NominaProcesoResponse
    {
        public string Proceso { get; set; } = string.Empty;
        public string Codigo { get; set; } = string.Empty;
        public bool Ejecutado { get; set; }
        public DateTime FechaIntento { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? CorridaId { get; set; }
        public int? EmpresaId { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int? PeriodoId { get; set; }
        public int? Anio { get; set; }
        public int TotalPersonas { get; set; }
        public int TotalMovimientos { get; set; }
        public decimal TotalPercepcion { get; set; }
        public decimal TotalDeduccion { get; set; }
        public decimal TotalAportacion { get; set; }
        public decimal TotalNeto { get; set; }
    }
}

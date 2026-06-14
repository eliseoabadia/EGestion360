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
    }
}

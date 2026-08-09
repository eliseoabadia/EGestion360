using System;

namespace EG.Domain.DTOs.Responses.Nomina
{
    public class NominaOperacionResponse
    {
        public string Operacion { get; set; } = string.Empty;

        public int Id { get; set; }

        public string Clave { get; set; } = string.Empty;

        public string Persona { get; set; } = string.Empty;

        public string Empleado { get; set; } = string.Empty;

        public string Empresa { get; set; } = string.Empty;

        public string Periodo { get; set; } = string.Empty;

        public string Tipo { get; set; } = string.Empty;

        public string Estatus { get; set; } = string.Empty;

        public DateTime? Fecha { get; set; }

        public DateTime? FechaInicio { get; set; }

        public DateTime? FechaFin { get; set; }

        public decimal? Importe { get; set; }

        public decimal? Percepcion { get; set; }

        public decimal? Deduccion { get; set; }

        public decimal? Neto { get; set; }

        public string Documento { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public string Comentario { get; set; } = string.Empty;

        public string Observaciones { get; set; } = string.Empty;

        public bool Activo { get; set; }

        public int TotalCount { get; set; }

        public string ClaveNombre => string.IsNullOrWhiteSpace(Persona)
            ? $"{Id} - {Descripcion}".Trim(' ', '-')
            : $"{Empleado} - {Persona}".Trim(' ', '-');
    }
}

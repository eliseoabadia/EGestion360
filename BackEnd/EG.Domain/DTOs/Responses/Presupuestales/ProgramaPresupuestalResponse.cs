using System;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class ProgramaPresupuestalResponse
    {
        public int PkidPp { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

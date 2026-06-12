using System;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class ProyectoResponse
    {
        public int PkidProyecto { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

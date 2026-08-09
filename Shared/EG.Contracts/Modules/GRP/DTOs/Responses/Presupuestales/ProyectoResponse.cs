using System;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class ProyectoResponse
    {
        public int PkidPy { get; set; }
        public int PkidProyecto
        {
            get => PkidPy;
            set => PkidPy = value;
        }

        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string ClaveNombre => $"{Clave} - {Descripcion}".Trim(' ', '-');
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

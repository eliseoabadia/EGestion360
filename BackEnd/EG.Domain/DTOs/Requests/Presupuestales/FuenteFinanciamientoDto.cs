using System;

namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class FuenteFinanciamientoDto
    {
        public int PkidFuenteFinanciamiento { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string Ff { get; set; } = string.Empty;
        public string Fg { get; set; } = string.Empty;
        public string Fe { get; set; } = string.Empty;
        public string Ad { get; set; } = string.Empty;
        public string Ori { get; set; } = string.Empty;
        public int? FkidAnioSis { get; set; }
    }
}

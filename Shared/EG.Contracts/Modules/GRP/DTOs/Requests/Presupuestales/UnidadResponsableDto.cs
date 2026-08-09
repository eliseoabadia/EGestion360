using System;
using System.Collections.Generic;

namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class UnidadResponsableDto
    {
        public int PkidUnidadResponsable { get; set; }
        public int? FkidAreaSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public List<UnidadResponsableDto> Children { get; set; } = new List<UnidadResponsableDto>();
    }
}

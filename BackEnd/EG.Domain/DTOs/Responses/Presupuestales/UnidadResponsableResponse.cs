using System;
using System.Collections.Generic;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class UnidadResponsableResponse
    {
        public int PkidUnidadResponsable { get; set; }
        public int? FkidAreaSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string AreaPadreNombre { get; set; } = string.Empty;
        public string AreaPadreClave { get; set; } = string.Empty;
        public List<UnidadResponsableResponse> Children { get; set; } = new List<UnidadResponsableResponse>();
    }
}

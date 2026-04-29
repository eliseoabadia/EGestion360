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
        public List<UnidadResponsableResponse> Children { get; set; } = new List<UnidadResponsableResponse>();
    }
}

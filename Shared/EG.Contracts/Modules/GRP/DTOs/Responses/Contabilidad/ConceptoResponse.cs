using System;

namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class ConceptoResponse
    {
        public int PkidConcepto { get; set; }
        public int FkidCapituloSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string CapituloDescripcion { get; set; } = string.Empty;
        public string CapituloClave { get; set; } = string.Empty;
    }
}

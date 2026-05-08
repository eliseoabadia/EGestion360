using System;

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class FraccionResponse
    {
        public int PkidFraccion { get; set; }
        public int FkidArticuloOrco { get; set; }
        public string NombreArticulo { get; set; } = string.Empty;
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string ArticuloDescripcion { get; set; } = string.Empty;
        public string ArticuloClave { get; set; } = string.Empty;
        public string ArticuloClaveNombre { get; set; } = string.Empty;
    }
}
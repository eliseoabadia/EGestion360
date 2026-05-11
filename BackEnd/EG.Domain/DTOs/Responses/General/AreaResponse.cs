using System;

namespace EG.Domain.DTOs.Responses.General
{
    public class AreaResponse
    {
        public int PkidArea { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
    }
}

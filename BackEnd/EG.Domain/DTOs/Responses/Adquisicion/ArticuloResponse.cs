using System;

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class ArticuloResponse
    {
        public int PkidArticulo { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}
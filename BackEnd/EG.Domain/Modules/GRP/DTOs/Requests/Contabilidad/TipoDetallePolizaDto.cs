using System;

namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class TipoDetallePolizaDto
    {
        public int PkidTipoDetallePoliza { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

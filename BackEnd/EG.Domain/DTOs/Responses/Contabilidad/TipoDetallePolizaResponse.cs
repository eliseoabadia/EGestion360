using System;

namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class TipoDetallePolizaResponse
    {
        public int PkidTipoDetallePoliza { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

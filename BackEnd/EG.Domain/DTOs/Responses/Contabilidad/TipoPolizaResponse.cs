using System;

namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class TipoPolizaResponse
    {
        public int PkidTipoPoliza { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

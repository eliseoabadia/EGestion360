using System;

namespace EG.Web.Models.Adquisicion
{
    public class TipoContratoResponse
    {
        public int PkidTipoContrato { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}
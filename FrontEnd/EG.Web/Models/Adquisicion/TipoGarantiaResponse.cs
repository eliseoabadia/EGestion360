using System;

namespace EG.Web.Models.Adquisicion
{
    public class TipoGarantiaResponse
    {
        public int PkidTipoGarantia { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}
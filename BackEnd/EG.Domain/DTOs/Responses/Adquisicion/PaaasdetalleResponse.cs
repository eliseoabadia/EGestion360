using System;

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class PaaasdetalleResponse
    {
        public int PkidPaaasdetalle { get; set; }
        public int FkidPaaaspartidaOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public string Unidad { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public string LugarEntrega { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }
}

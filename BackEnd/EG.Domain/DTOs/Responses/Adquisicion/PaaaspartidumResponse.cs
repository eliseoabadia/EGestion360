using System;

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class PaaaspartidumResponse
    {
        public int PkidPaaaspartida { get; set; }
        public int FkidPaaas { get; set; }
        public int FkidPaaasOrco { get; set; }
        public int FkidPartidaConta { get; set; }
        public string ClavePartida { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public decimal Monto { get; set; }
        public int Cantidad { get; set; }
        public string Unidad { get; set; } = string.Empty;
        public DateTime? FechaEntrega { get; set; }
        public bool Activo { get; set; }
    }
}

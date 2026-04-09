namespace EG.Web.Models.ConteoCiclico
{
    public class ConteoDetalleResponse
    {
        public int PkidConteo { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public decimal CantidadInventarioInicial { get; set; }
        public string ConteoDescripcion { get; set; } = string.Empty;
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public bool ConteoActivo { get; set; }
        public int PkidDetalleConteo { get; set; }
        public int FkidConteoAlma { get; set; }
        public int FkidNumeroConteoAlma { get; set; }
        public int FkidPersonaNom { get; set; }
        public string PersonaNombre { get; set; } = string.Empty;
        public string PersonaPaterno { get; set; } = string.Empty;
        public string PersonaMaterno { get; set; } = string.Empty;
        public decimal CantidadContada { get; set; }
        public DateTime FechaConteo { get; set; }
        public bool DetalleActivo { get; set; }
    }
}

namespace EG.Web.Models.ConteoCiclico
{
    public class ConteoDetalleEscaneoResponse
    {
        public int PkidDetalleEscaneo { get; set; }
        public int FkidConteoAlma { get; set; }
        public int FkidPersonaNom { get; set; }
        public string CodigoBarras { get; set; } = string.Empty;
        public int FkidTipoBienAlma { get; set; }
        public int? FkidBienAlma { get; set; }
        public DateTime FechaEscaneo { get; set; }
        public bool Activo { get; set; }
        public string ConteoDescripcion { get; set; } = string.Empty;
        public decimal ConteoCantidadInventario { get; set; }
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public string TipoBienCodigoClave { get; set; } = string.Empty;
        public string PersonaNombre { get; set; } = string.Empty;
        public string PersonaPaterno { get; set; } = string.Empty;
        public string PersonaMaterno { get; set; } = string.Empty;
        public string BienClave { get; set; } = string.Empty;
        public string BienSerie { get; set; } = string.Empty;
        public string BienModelo { get; set; } = string.Empty;
        public string BienDescripcion { get; set; } = string.Empty;
    }
}

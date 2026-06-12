namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public class ConteoDetalleEscaneoResponse
{
    public int PkidDetalleEscaneo { get; set; }

    public int FkidConteoAlma { get; set; }

    public int FkidPersonaNom { get; set; }

    public string CodigoBarras { get; set; }

    public int FkidTipoBienAlma { get; set; }

    public int? FkidBienAlma { get; set; }

    public DateTime FechaEscaneo { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public string ConteoDescripcion { get; set; }

    public DateTime ConteoFechaInicio { get; set; }

    public DateTime? ConteoFechaFin { get; set; }

    public decimal ConteoCantidadInventario { get; set; }

    public string TipoBienDescripcion { get; set; }

    public string TipoBienCodigoClave { get; set; }

    public string PersonaNombre { get; set; }

    public string PersonaPaterno { get; set; }

    public string PersonaMaterno { get; set; }

    public string PersonaClave { get; set; }

    public string BienClave { get; set; }

    public string BienSerie { get; set; }

    public string BienModelo { get; set; }

    public string BienDescripcion { get; set; }
}

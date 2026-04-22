namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public class ConteoDetalleResponse
{
    public int PkidDetalleConteo { get; set; }

    public int FkidConteoAlma { get; set; }

    public int FkidNumeroConteoAlma { get; set; }

    public int FkidPersonaNom { get; set; }

    public string? PersonaNombre { get; set; }

    public decimal Cantidad { get; set; }

    public DateTime Fecha { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }
}

public class BienResponse
{
    public int PkidBien { get; set; }

    public int FkidTipoBienAlma { get; set; }

    public string Clave { get; set; }

    public string? ClaveAnt { get; set; }

    public string Descripcion { get; set; }

    public string? Modelo { get; set; }

    public string? Serie { get; set; }

    public decimal? Costo { get; set; }

    public DateTime? FechaAdq { get; set; }

    public string? Factura { get; set; }

    public string? Ubicacion { get; set; }

    public string? Estatus { get; set; }

    public bool Activo { get; set; }

    public string? GrupoBienDescripcion { get; set; }

    public int? GrupoBienClave { get; set; }

    public string? TipoBienCodigoClave { get; set; }

    public string? TipoBienDescripcion { get; set; }

    public string? MarcaDescripcion { get; set; }

    public string? EstadoBienDescripcionGeneral { get; set; }
}

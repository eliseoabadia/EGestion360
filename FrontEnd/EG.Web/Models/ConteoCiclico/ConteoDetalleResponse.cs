namespace EG.Web.Models.ConteoCiclico;

public class BienBusquedaResponse
{
    public int PkidBien { get; set; }

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

    public bool Seleccionado { get; set; }
}

public class AgregarBienConteoRequest
{
    public int FkidConteoAlma { get; set; }

    public int FkidNumeroConteoAlma { get; set; }

    public int FkidBien { get; set; }

    public int FkidPersonaNom { get; set; }

    public decimal Cantidad { get; set; }
}

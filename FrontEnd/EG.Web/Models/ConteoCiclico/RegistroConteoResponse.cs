namespace EG.Web.Models.ConteoCiclico;

public partial class RegistroConteoResponse
{
    public int PkidRegistroConteo { get; set; }

    public int FkidArticuloConteoAlma { get; set; }

    public int FkidPeriodoConteoAlma { get; set; }

    public int FkidSucursalSis { get; set; }

    public int NumeroConteo { get; set; }

    public decimal CantidadContada { get; set; }

    public DateTime FechaConteo { get; set; }

    public int FkidUsuarioSis { get; set; }

    public string Observaciones { get; set; }

    public bool EsReconteo { get; set; }

    public string FotoPath { get; set; }

    public decimal? Latitud { get; set; }

    public decimal? Longitud { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

}
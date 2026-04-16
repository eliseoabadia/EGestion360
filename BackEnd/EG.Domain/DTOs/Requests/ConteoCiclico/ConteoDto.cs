namespace EG.Domain.DTOs.Requests.ConteoCiclico;

public class ConteoDto
{
    public int PkidConteo { get; set; }

    public int FkidTipoBienAlma { get; set; }

    public decimal CantidadInventario { get; set; }

    public string Descripcion { get; set; }

    public DateTime FechaInicio { get; set; }

    public DateTime? FechaFin { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public int? FkidPeriodoConteoAlma { get; set; }
}

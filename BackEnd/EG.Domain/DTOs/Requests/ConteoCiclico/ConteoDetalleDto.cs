namespace EG.Domain.DTOs.Requests.ConteoCiclico;

public class ConteoDetalleDto
{
    public int PkidDetalleConteo { get; set; }

    public int FkidConteoAlma { get; set; }

    public int FkidNumeroConteoAlma { get; set; }

    public int FkidPersonaNom { get; set; }

    public decimal Cantidad { get; set; }

    public DateTime Fecha { get; set; }

    public bool Activo { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }
}

public class AgregarBienConteoDto
{
    public int FkidConteoAlma { get; set; }

    public int FkidNumeroConteoAlma { get; set; }

    public int FkidBien { get; set; }

    public int FkidPersonaNom { get; set; }

    public decimal Cantidad { get; set; }
}

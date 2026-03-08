namespace EG.Domain.DTOs.Requests.ConteoCiclico;

public partial class EstatusArticuloConteoDto
{
    public int PkidEstatusArticulo { get; set; }

    public string Nombre { get; set; }

    public string Descripcion { get; set; }

    public int Orden { get; set; }

    public bool Activo { get; set; }

}
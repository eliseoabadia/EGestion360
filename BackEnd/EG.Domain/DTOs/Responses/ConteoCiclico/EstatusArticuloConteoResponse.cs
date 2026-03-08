namespace EG.Domain.DTOs.Responses.ConteoCiclico;

public partial class EstatusArticuloConteoResponse
{
    public int PkidEstatusArticulo { get; set; }

    public string Nombre { get; set; }

    public string Descripcion { get; set; }

    public int Orden { get; set; }

    public bool Activo { get; set; }

}
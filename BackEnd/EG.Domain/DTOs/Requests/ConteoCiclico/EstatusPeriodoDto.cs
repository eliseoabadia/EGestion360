namespace EG.Domain.DTOs.Requests.ConteoCiclico;

public partial class EstatusPeriodoDto
{
    public int PkidEstatusPeriodo { get; set; }

    public string Nombre { get; set; }

    public string Descripcion { get; set; }

    public bool Activo { get; set; }
}
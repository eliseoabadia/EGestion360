using EG.Domain.Entities;

namespace EG.Domain.DTOs.Requests.General;
public class EmpresaDto
{
    public int PkidEmpresa { get; set; }

    public string Nombre { get; set; }

    public string Rfc { get; set; }

    public bool Activo { get; set; }

}
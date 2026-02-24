using EG.Domain.Entities;

namespace EG.Domain.DTOs.Requests.General;
public class EmpresaDto
{
    public int PkidEmpresa { get; set; }

    public string Nombre { get; set; }

    public string Rfc { get; set; }

    public string RazonSocial { get; set; }

    public string Giro { get; set; }

    public int FkidMonedaBaseSis { get; set; }

    public int? FkidIdiomaPreferidoSis { get; set; }

    public byte[] Logo { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

}
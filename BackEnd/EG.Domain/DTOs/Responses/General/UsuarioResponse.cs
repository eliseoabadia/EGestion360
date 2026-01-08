using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EG.Dommain.DTOs.Responses;


public partial class UsuarioResponse
{
    [Required]
    public int PkIdUsuario { get; set; }

    public int FkidEmpresaSis { get; set; }

    public string Nombre { get; set; }

    public string ApellidoPaterno { get; set; }

    public string ApellidoMaterno { get; set; }

    public string Iniciales { get; set; }

    public string PayrollId { get; set; }

    public string CodigoPostal { get; set; }

    public string Telefono { get; set; }

    public string Direccion1 { get; set; }

    public string Direccion2 { get; set; }

    public string Email { get; set; }

    public string NumeroSocial { get; set; }

    public string Gafete { get; set; }

    public bool Sexo { get; set; }

    public bool Activo { get; set; }

    // Auxiliar opcional
    public string NombreCompleto => $"{Nombre} {ApellidoPaterno} {ApellidoMaterno}";

}
public class FotografiaUsuarioResponse
{
    [Required]
    public int FkidUsuarioSis { get; set; }

    public byte[] Fotografia { get; set; }

    [MaxLength(50)]
    public string ContentType { get; set; }

    [MaxLength(64)]
    public string FileName { get; set; }

    [MaxLength(8)]
    public string FileExtension { get; set; }

    public bool Activo { get; set; } = true;

}

public class PagedResult<T>
{
    public IList<T> Items { get; set; } = new List<T>();
    public int TotalCount { get; set; }
}
namespace EG.Dommain.DTOs.Responses;

public class UsuarioDto
{
    public int PkIdUsuario { get; set; }

    public int FkidEmpresaSis { get; set; }

    public string AspNetUserId { get; set; }

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

    public DateOnly? FechaIngreso { get; set; }

    public int? FkidIdiomaPreferidoSis { get; set; }

    public int? FkidMonedaPreferidaSis { get; set; }

    public bool EsAdministrador { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }
}




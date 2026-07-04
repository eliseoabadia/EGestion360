namespace EG.Domain.DTOs.Requests.General;

public class EmpresaDto
{
    public int PkidEmpresa { get; set; }

    public string Nombre { get; set; }

    public string EmpresaNombre
    {
        get => Nombre;
        set => Nombre = value;
    }

    public string NombreCorto { get; set; }

    public string Rfc { get; set; }

    public string RazonSocial { get; set; }

    public string Giro { get; set; }

    public int FkidMonedaBaseSis { get; set; }

    public int? FkidIdiomaPreferidoSis { get; set; }

    public string Logo { get; set; }

    public byte[] LogoEmpresa { get; set; }

    public bool Activo { get; set; }

    public bool EmpresaActivo
    {
        get => Activo;
        set => Activo = value;
    }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public string RegImss { get; set; }

    public string RegInfonavit { get; set; }

    public string CedEmpadronam { get; set; }

    public string NoFonacot { get; set; }

    public string UsAdmin { get; set; }

    public string EmailAdmin { get; set; }

    public int? FkidPeriodoPagoSis { get; set; }

    public decimal? PrimaRiesgoImss { get; set; }

    public bool UsaSueldoTabular { get; set; }

    public int? FkidTipoPagoNom { get; set; }

    public int PkidEstado { get; set; }

    public DateOnly? FechaApertura { get; set; }

    public bool EsOficinaPrincipal { get; set; }

}

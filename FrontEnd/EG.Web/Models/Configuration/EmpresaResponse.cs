namespace EG.Web.Models.Configuration;

public class EmpresaResponse
{
    public int PkidEmpresa { get; set; }

    public string EmpresaNombre { get; set; }

    public string Rfc { get; set; }

    public string RazonSocial { get; set; }

    public string Giro { get; set; }

    public int FkidMonedaBaseSis { get; set; }

    public int? FkidIdiomaPreferidoSis { get; set; }

    public byte[] Logo { get; set; }

    public bool EmpresaActivo { get; set; }

    public DateTime? EmpresaFechaCreacion { get; set; }

    public int EmpresaUsuarioCreacion { get; set; }

    public DateTime? EmpresaFechaModificacion { get; set; }

    public int? EmpresaUsuarioModificacion { get; set; }

    public int PkidEstado { get; set; }

    public int FkidPaisSis { get; set; }

    public string EstadoNombre { get; set; }

    public string CodigoEstado { get; set; }

    public bool EstadoActivo { get; set; }

    public DateOnly? FechaApertura { get; set; }

    public bool EsOficinaPrincipal { get; set; }

    public bool RelacionActiva { get; set; }
}

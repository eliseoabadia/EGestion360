
namespace EG.Web.Models;

public class UsuarioDeprecar_UsuarioResponse
{
    public int PkIdUsuario { get; set; }
    public string UsuarioNombre { get; set; }
    public string Email { get; set; }
    public string Iniciales { get; set; }
    public string Gafete { get; set; }
    public string PayrollId { get; set; }
    public int IdEmpresa { get; set; }
    public string EmpresaNombre { get; set; }
    public string EmpresaRfc { get; set; }
    public int PkidSucursal { get; set; }
    public string SucursalNombre { get; set; }
    public string CodigoSucursal { get; set; }
    public string SucursalAlias { get; set; }
    public string TipoSucursal { get; set; }
    public string Ciudad { get; set; }
    public string Estado { get; set; }
    public bool EsMatriz { get; set; }
    public bool SucursalActiva { get; set; }
    public int? IdDepartamento { get; set; }
    public string DepartamentoNombre { get; set; }
    public bool EsGerente { get; set; }
    public bool EsSupervisor { get; set; }
    public bool PuedeAcceder { get; set; }
    public bool PuedeConfigurar { get; set; }
    public bool PuedeOperar { get; set; }
    public bool PuedeReportes { get; set; }
    public DateTime? FechaAsignacion { get; set; }
    public DateTime? FechaFinAsignacion { get; set; }
    public bool RelacionActiva { get; set; }
}



public class UsuarioDeprecar_UsuarioDto
{
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
    public DateTime? FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}

namespace EG.Domain.Entities;

public partial class VwUsuarioSucursalSimplificadum
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
namespace EG.Domain.DTOs.Requests.General;

public partial class UsuarioSucursalDto
{
    public int FkidUsuarioSis { get; set; }

    public int FkidSucursalSis { get; set; }

    public bool PuedeAcceder { get; set; }

    public bool PuedeConfigurar { get; set; }

    public bool PuedeOperar { get; set; }

    public bool PuedeReportes { get; set; }

    public bool EsGerente { get; set; }

    public bool EsSupervisor { get; set; }

    public DateTime? FechaAsignacion { get; set; }

    public DateTime? FechaFinAsignacion { get; set; }

    public bool Activo { get; set; }
}

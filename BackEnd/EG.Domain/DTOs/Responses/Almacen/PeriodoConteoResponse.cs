namespace EG.Domain.DTOs.Responses.Almacen
{
    public class PeriodoConteoResponse
    {
        public int PkidPeriodoConteo { get; set; }
        public int FkidSucursalSis { get; set; }
        public int FkidTipoConteoAlma { get; set; }
        public int FkidEstatusAlma { get; set; }
        public string CodigoPeriodo { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateOnly FechaInicio { get; set; }
        public DateOnly? FechaFin { get; set; }
        public DateTime? FechaCierre { get; set; }
        public int MaximoConteosPorArticulo { get; set; }
        public bool RequiereAprobacionSupervisor { get; set; }
        public int? FkidResponsableSis { get; set; }
        public int? FkidSupervisorSis { get; set; }
        public int? TotalArticulos { get; set; }
        public int? ArticulosConcluidos { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

namespace EG.Domain.DTOs.Responses.ConteoCiclico
{
    public class PeriodoConteoDto
    {
        public int PkidPeriodoConteo { get; set; }

        public int FkidSucursalSis { get; set; }

        public int FkidTipoConteoAlma { get; set; }

        public int FkidEstatusAlma { get; set; }

        public string CodigoPeriodo { get; set; }

        public string Nombre { get; set; }

        public string Descripcion { get; set; }

        public DateOnly FechaInicio { get; set; }

        public DateOnly? FechaFin { get; set; }

        public DateTime? FechaCierre { get; set; }

        public int MaximoConteosPorArticulo { get; set; }

        public bool RequiereAprobacionSupervisor { get; set; }

        public int? FkidResponsableSis { get; set; }

        public int? FkidSupervisorSis { get; set; }

        public int? TotalArticulos { get; set; }

        public int? ArticulosConcluidos { get; set; }

        public int? ArticulosConDiferencia { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}

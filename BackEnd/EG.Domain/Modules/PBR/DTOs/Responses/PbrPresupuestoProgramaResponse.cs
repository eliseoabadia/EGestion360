namespace EG.Domain.DTOs.Responses.PBR
{
    public class PbrPresupuestoProgramaResponse
    {
        public int PkidPresupuestoPrograma { get; set; }
        public int FkidProgramaPresupuestarioPbr { get; set; }
        public int Anio { get; set; }
        public decimal PresupuestoAnual { get; set; }
        public decimal? PresupuestoModificado { get; set; }
        public int? FkidEntidadPbr { get; set; }
        public int? FkidUnidadResponsablePres { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public int? FkidActividadInstitucionalSis { get; set; }
        public int? FkidProyectoInversionPres { get; set; }
        public int? FkidRegionPbr { get; set; }
        public string? ComponenteActivado { get; set; }
        public string? Futuro { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public int? FkidProgramaPres { get; set; }
        public string? ProgramaClave { get; set; }
        public string? ProgramaDescripcion { get; set; }
        public string? EntidadNombre { get; set; }
        public string? UnidadResponsableDescripcion { get; set; }
        public string? FuenteFinanciamientoDescripcion { get; set; }
        public string? ProyectoInversionDescripcion { get; set; }
        public string? RegionNombre { get; set; }
    }
}

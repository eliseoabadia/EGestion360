namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class ProgramaDto
    {
        public int PkidPrograma { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string? Objetivo { get; set; }
        public int FkidUrPres { get; set; }
        public int FkidGfPres { get; set; }
        public int FkidFnPres { get; set; }
        public int FkidSfPres { get; set; }
        public int FkidActividadInstitucionalSis { get; set; }
        public int? FkidEjePres { get; set; }
        public int? FkidSubEjePres { get; set; }
        public int? FkidSubSubEjePres { get; set; }
        public int? FkidFinalidadPres { get; set; }
        public int? FkidVertienteGastoPres { get; set; }
        public int? FkidResultadoPres { get; set; }
        public int? FkidSubresultadoPres { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidSectorPres { get; set; }
        public int? FkidSubSectorPres { get; set; }
        public int? FkidTipoRecursoPres { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public int? FkidPpPres { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

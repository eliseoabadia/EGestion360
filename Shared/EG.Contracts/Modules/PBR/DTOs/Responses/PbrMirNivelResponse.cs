namespace EG.Domain.DTOs.Responses.PBR
{
    public class PbrMirNivelResponse
    {
        public int PkidMirNivel { get; set; }
        public int FkidProgramaPresupuestarioPbr { get; set; }
        public string Nivel { get; set; } = string.Empty;
        public string Objetivo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public int Orden { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? FkidProgramaPres { get; set; }
        public string? ProgramaDescripcion { get; set; }
    }
}

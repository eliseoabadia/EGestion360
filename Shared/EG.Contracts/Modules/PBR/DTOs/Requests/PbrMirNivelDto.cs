namespace EG.Domain.DTOs.Requests.PBR
{
    public class PbrMirNivelDto
    {
        public int PkidMirNivel { get; set; }
        public int FkidProgramaPresupuestarioPbr { get; set; }
        public string Nivel { get; set; } = string.Empty;
        public string Objetivo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public int Orden { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}

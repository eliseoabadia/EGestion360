namespace EG.Domain.DTOs.Responses.PBR
{
    public class PbrIndicadorResponse
    {
        public int PkidIndicador { get; set; }
        public int FkidMirNivelPbr { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Definicion { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public string Dimension { get; set; } = string.Empty;
        public string Formula { get; set; } = string.Empty;
        public string Algoritmo { get; set; } = string.Empty;
        public string Frecuencia { get; set; } = string.Empty;
        public string Unidad { get; set; } = string.Empty;
        public string? LineaBase { get; set; }
        public string? Meta { get; set; }
        public string? MedioVerificacion { get; set; }
        public string? Supuesto { get; set; }
        public string Sentido { get; set; } = "Ascendente";
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string? Nivel { get; set; }
        public string? MirObjetivo { get; set; }
        public int? FkidProgramaPres { get; set; }
        public string? ProgramaDescripcion { get; set; }
    }
}

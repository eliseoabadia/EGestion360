namespace EG.Domain.DTOs.Requests.PBR
{
    public class PbrIndicadorDto
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
    }
}

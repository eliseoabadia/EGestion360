namespace EG.Domain.DTOs.Requests.PBR
{
    public class PbrAnteproyectoDto
    {
        public int PkidAnteproyecto { get; set; }
        public int FkidProgramaPresupuestarioPbr { get; set; }
        public int Anio { get; set; }
        public decimal MontoSolicitado { get; set; }
        public decimal? MontoAutorizado { get; set; }
        public string Estatus { get; set; } = "BORRADOR";
        public string Justificacion { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public int FkidUsuarioPbr { get; set; }
        public int? FkidPresupuestoProgramaPbr { get; set; }
        public int? FkidMirVersionPbr { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}

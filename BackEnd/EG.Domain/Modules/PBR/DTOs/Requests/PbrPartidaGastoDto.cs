namespace EG.Domain.DTOs.Requests.PBR
{
    public class PbrPartidaGastoDto
    {
        public int PkidPartidaGasto { get; set; }
        public int FkidPresupuestoProgramaPbr { get; set; }
        public int? FkidCapituloSis { get; set; }
        public int? FkidConceptoSis { get; set; }
        public int? FkidPartidaSis { get; set; }
        public string CapituloClave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal MontoAnual { get; set; }
        public decimal? MontoModificado { get; set; }
        public int? FkidTipoGastoPres { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class PaaaDto
    {
        public int PkidPaaas { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidAnioSis { get; set; }
        public int FkidAreaSis { get; set; }
        public int FkidPersonaNom { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string? Observaciones { get; set; }
        public DateTime Fecha { get; set; }
        public int? FkidProyectoOrco { get; set; }
        public int? FkidProgramaPres { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

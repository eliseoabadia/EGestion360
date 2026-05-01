namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class GrupoBienResponse
    {
        public int PkidGrupoBien { get; set; }
        public int FkidFamiliaAlma { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public int? Clave { get; set; }
        public string ClaveAn { get; set; } = string.Empty;
        public string CabmAct { get; set; } = string.Empty;
        public string ClaveCucop { get; set; } = string.Empty;
        public string Medida { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

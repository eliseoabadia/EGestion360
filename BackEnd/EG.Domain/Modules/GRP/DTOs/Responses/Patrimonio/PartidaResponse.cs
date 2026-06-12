namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class PartidaResponse
    {
        public int PkidPartida { get; set; }
        public int? FkidConceptoSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string ConceptoDescripcion { get; set; } = string.Empty;
    }
}

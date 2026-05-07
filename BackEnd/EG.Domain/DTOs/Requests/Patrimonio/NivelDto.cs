namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class NivelDto
    {
        public int PkidNivel { get; set; }
        public int Nivel1 { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

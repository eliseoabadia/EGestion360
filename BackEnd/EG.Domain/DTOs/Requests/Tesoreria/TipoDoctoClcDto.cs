namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoDoctoClcDto
    {
        public int PkidTipoDoctoClc { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string TipoRecurso { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

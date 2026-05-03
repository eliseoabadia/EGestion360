namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class GfDto
    {
        public int PkidGf { get; set; }
        public int Clave { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

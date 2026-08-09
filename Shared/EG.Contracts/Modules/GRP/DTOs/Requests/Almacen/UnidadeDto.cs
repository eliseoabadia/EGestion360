namespace EG.Domain.DTOs.Requests.Almacen
{
    public class UnidadeDto
    {
        public int PkidUnidades { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

namespace EG.Web.Models
{
    public class Libro
    {
        public int Id { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Titulo { get; set; } = string.Empty;
        public string Autor { get; set; } = string.Empty;
        public DateTime? FechaPublicacion { get; set; }
        public DateTime FechaRegistro { get; set; } = DateTime.Now;
        public int Cantidad { get; set; }
        public int CategoriaId { get; set; }
        public Categoria? Categoria { get; set; }
    }
}
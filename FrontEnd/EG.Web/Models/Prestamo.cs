namespace EG.Web.Models
{
    public class Prestamo
    {
        public int Id { get; set; }
        public int LibroId { get; set; }
        public Libro? Libro { get; set; }
        public int EstudianteId { get; set; }
        public Estudiante? Estudiante { get; set; }
        public DateTime FechaPrestamo { get; set; } = DateTime.Now;
        public DateTime FechaDevolucion { get; set; } = DateTime.Now.AddDays(15);
        public string Estado { get; set; } = "Disponible";
    }
}
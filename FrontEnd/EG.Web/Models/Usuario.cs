namespace EG.Web.Models
{
    public class Usuario
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Perfil { get; set; } = "Usuario";
        public DateTime FechaRegistro { get; set; } = DateTime.Now;
    }
}
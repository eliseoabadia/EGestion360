namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class GfDto
    {
        public int PkidGf { get; set; }

        public int Clave { get; set; }

        public string Descripcion { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}

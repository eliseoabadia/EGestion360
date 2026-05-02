namespace EG.Web.Models
{
    public abstract class BaseResponse
    {
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public bool Activo { get; set; }
    }
}
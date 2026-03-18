
namespace EG.Domain.DTOs.Responses.Almacen
{
    public class FamiliaResponse
    {
        public int? PkidFamilia { get; set; }

        public string? Descripcion { get; set; }

        public string? Clave { get; set; }

        public bool? Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}

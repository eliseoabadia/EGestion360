using System;

namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class FuncionDto
    {
        public int PkidFn { get; set; }
        public int FkidGfPres { get; set; }
        public int Clave { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

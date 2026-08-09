namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class UrResponse
    {
        public int PkidUr { get; set; }
        public int FkidGrupoPresupuestoPres { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string ClaveNombre => string.IsNullOrWhiteSpace(Clave)
            ? Descripcion
            : $"{Clave} - {Descripcion}";
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

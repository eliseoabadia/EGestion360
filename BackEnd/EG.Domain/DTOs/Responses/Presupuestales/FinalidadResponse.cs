namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class FinalidadResponse
    {
        public int PkidFinalidad { get; set; }
        public int? FkidClaveProgramaPres { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

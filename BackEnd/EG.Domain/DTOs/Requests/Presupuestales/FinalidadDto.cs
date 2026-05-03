namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class FinalidadDto
    {
        public int PkidFinalidad { get; set; }
        public int? FkidClaveProgramaPres { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

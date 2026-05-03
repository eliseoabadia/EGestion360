namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoInversionDto
    {
        public int PkidTipoInversion { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Codigo { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

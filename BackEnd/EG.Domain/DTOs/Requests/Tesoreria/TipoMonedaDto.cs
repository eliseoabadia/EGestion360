namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoMonedaDto
    {
        public int PkidTipoMoneda { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Codigo { get; set; } = string.Empty;
        public string Simbolo { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

namespace EG.Domain.DTOs.Responses.Tesoreria
{
    public class TipoPagoSFResponse
    {
        public int PkidTipoPagoSf { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

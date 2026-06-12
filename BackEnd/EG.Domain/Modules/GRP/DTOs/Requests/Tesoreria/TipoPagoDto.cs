namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoPagoDto
    {
        public int PkidTipoPago { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

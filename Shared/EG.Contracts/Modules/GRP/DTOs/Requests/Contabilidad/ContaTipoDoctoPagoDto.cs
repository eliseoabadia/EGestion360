namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class ContaTipoDoctoPagoDto
    {
        public int PkidTipoDoctoPago { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Codigo { get; set; }
        public string? Descripcion { get; set; }
        public bool Activo { get; set; }
        public string UsuarioCreacion { get; set; } = string.Empty;
        public DateTime FechaCreacion { get; set; }
        public string? UsuarioModificacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}

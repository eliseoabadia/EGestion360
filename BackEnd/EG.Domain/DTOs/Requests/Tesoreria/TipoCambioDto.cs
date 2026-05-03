namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoCambioDto
    {
        public int PkidTipoCambio { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Codigo { get; set; } = string.Empty;
        public decimal Valor { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

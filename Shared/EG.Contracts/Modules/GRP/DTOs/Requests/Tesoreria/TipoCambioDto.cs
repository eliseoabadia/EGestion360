namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoCambioDto
    {
        public int PkidTipoCambio { get; set; }
        public int FkidTipoMonedaTes { get; set; }
        public decimal Cantidad { get; set; }
        public DateTime Fecha { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

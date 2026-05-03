namespace EG.Domain.DTOs.Responses.Tesoreria
{
    public class TipoCambioResponse
    {
        public int PkidTipoCambio { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Codigo { get; set; } = string.Empty;
        public decimal Valor { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

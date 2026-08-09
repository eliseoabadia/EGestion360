namespace EG.Domain.DTOs.Responses.Tesoreria
{
    public class TipoCambioResponse
    {
        public int PkidTipoCambio { get; set; }
        public int FkidTipoMonedaTes { get; set; }
        public decimal Cantidad { get; set; }
        public DateTime Fecha { get; set; }
        public bool Activo { get; set; }
        public string MonedaDescripcion { get; set; } = string.Empty;
        public string MonedaCodigo { get; set; } = string.Empty;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

namespace EG.Web.Models.Patrimonio
{
    public class TipoBienResponse
    {
        public int PkidTipoBien { get; set; }
        public string CodigoClave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        
        // Aliases for compatibility
        public string CodigoArticulo => CodigoClave;
        public string DescripcionArticulo => Descripcion;
    }
}

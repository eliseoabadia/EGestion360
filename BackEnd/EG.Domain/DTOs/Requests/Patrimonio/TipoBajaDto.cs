namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class TipoBajaDto
    {
        public int PkidTipoBaja { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int? FkidEstadoBienDestinoAlma { get; set; }
        public bool RequiereAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

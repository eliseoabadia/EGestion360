namespace EG.Domain.DTOs.Responses.Tesoreria
{
    public class TipoMonedaResponse
    {
        public int PkidTipoMoneda { get; set; }
        public int FkidPaisSis { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string CodigoIso4217 { get; set; } = string.Empty;
        public string Simbolo { get; set; } = string.Empty;
        public int Decimales { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string PaisNombre { get; set; } = string.Empty;
    }
}

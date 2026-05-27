namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class TipoMonedaDto
    {
        public int PkidTipoMoneda { get; set; }
        public int FkidPaisSis { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string CodigoIso4217 { get; set; } = string.Empty;
        public string Simbolo { get; set; } = string.Empty;
        public int Decimales { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

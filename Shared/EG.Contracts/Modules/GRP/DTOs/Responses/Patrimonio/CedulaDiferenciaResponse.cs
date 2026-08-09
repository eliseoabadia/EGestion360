namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class CedulaDiferenciaResponse
    {
        public string Tipo { get; set; } = string.Empty;
        public int FkidAreaSis { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public int FkidBienAlma { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public string TipoPatrimonio { get; set; } = string.Empty;
        public string Resguardante { get; set; } = string.Empty;
    }
}

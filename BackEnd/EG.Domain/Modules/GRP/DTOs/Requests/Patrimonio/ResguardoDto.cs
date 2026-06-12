namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class ResguardoDto
    {
        public int PkidResguardo { get; set; }
        public string Folio { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
        public int? FkidAreaSis { get; set; }
        public int FkidPersonaNom { get; set; }
        public DateTime FechaResguardo { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

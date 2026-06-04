namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class ResguardoResponse
    {
        public int PkidResguardo { get; set; }
        public string Folio { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int? FkidAreaSis { get; set; }
        public string AreaClave { get; set; } = string.Empty;
        public string AreaNombre { get; set; } = string.Empty;
        public int FkidPersonaNom { get; set; }
        public string PersonaClave { get; set; } = string.Empty;
        public string PersonaNombre { get; set; } = string.Empty;
        public DateTime FechaResguardo { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public int? TotalBienes { get; set; }
        public decimal? ValorActualResguardado { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class InventarioDto
    {
        public int PkidInventario { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidCalendarioInventarioAlma { get; set; }
        public int? FkidAreaSis { get; set; }
        public int FkidEstatusInventarioAlma { get; set; }
        public string Folio { get; set; } = string.Empty;
        public DateTime FechaInventario { get; set; }
        public string Responsable { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public int TotalBienes { get; set; }
        public int TotalLocalizados { get; set; }
        public int TotalDiferencias { get; set; }
        public bool Autorizado { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public int? UsuarioAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

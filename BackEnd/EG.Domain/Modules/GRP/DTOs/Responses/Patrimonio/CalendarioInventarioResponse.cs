namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class CalendarioInventarioResponse
    {
        public int PkidCalendarioInventario { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int? FkidAreaSis { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public int Anio { get; set; }
        public string Folio { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public int InventariosActivos { get; set; }
    }
}

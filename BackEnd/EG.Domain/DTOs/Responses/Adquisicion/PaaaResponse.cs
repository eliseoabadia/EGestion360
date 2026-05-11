namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class PaaaResponse
    {
        public int PkidPaaas { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidAnioSis { get; set; }
        public int FkidAreaSis { get; set; }
        public int FkidPersonaNom { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string? Observaciones { get; set; }
        public DateTime Fecha { get; set; }
        public int? FkidProyectoOrco { get; set; }
        public int? FkidProgramaPres { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public int? AnioClave { get; set; }
        public int? AnioDescripcion { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public string AreaClave { get; set; } = string.Empty;
        public string ResponsableNombre { get; set; } = string.Empty;
        public string ResponsablePaterno { get; set; } = string.Empty;
        public string ResponsableMaterno { get; set; } = string.Empty;
        public string ResponsableCompleto { get; set; } = string.Empty;
        public string? ProyectoDescripcion { get; set; }
        public string? ProgramaClave { get; set; }
        public string? ProgramaDescripcion { get; set; }
public string? FuenteFinanciamientoDescripcion { get; set; }
    public string? FuenteFinanciamientoClave { get; set; }
    public string ClaveNombre { get; set; } = string.Empty;
    
    // Navegación a partidas
    public List<PaaaspartidumResponse> Partidas { get; set; } = new();
    }
}

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstudioMercadoResponse
    {
        public int PkidEstudioMercado { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaCierre { get; set; }
        public int FkidResponsableNom { get; set; }
        public string ResponsableNombre { get; set; } = string.Empty;
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

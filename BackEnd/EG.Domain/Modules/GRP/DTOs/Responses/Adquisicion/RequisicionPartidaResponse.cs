namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class RequisicionPartidaResponse
    {
        public int PkidRequisicionPartida { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public int FkidPartidaConta { get; set; }
        public decimal? Monto { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public DateTime? FechaRequisicion { get; set; }
        public decimal? RequisicionImporte { get; set; }
        public string PartidaClave { get; set; } = string.Empty;
        public string PartidaDescripcion { get; set; } = string.Empty;
        public string ClaveNombre { get; set; } = string.Empty;
    }
}

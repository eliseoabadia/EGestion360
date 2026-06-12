namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class RequisicionPartidaDto
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
    }
}

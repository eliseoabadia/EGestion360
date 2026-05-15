namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class DetalleRequisicionDto
    {
        public int PkidDetalleRequisicion { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public decimal Cantidad { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

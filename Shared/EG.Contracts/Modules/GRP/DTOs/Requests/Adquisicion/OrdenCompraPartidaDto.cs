namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class OrdenCompraPartidaDto
    {
        public int PkidOrdenCompraPartida { get; set; }
        public int FkidOrdenCompraOrco { get; set; }
        public int FkidPartidaConta { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public decimal Importe { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

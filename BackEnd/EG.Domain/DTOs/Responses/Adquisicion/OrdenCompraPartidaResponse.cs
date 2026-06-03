namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class OrdenCompraPartidaResponse
    {
        public int PkidOrdenCompraPartida { get; set; }
        public int FkidOrdenCompraOrco { get; set; }
        public string NumeroOrdenCompra { get; set; } = string.Empty;
        public int FkidPartidaConta { get; set; }
        public string PartidaClave { get; set; } = string.Empty;
        public string PartidaDescripcion { get; set; } = string.Empty;
        public string PartidaClaveNombre { get; set; } = string.Empty;
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public string FuenteFinanciamientoClave { get; set; } = string.Empty;
        public string FuenteFinanciamientoDescripcion { get; set; } = string.Empty;
        public decimal Importe { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

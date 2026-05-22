namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class CotizacionDetalleDto
    {
        public int PkidCotizacionDetalle { get; set; }
        public int FkidCotizacionOrco { get; set; }
        public int FkidDetalleRequisicionOrco { get; set; }
        public decimal? PrecioUnitario { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

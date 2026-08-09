namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class EstudioMercadoDetalleDto
    {
        public int PkidEstudioMercadoDetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidEstudioMercadoOrco { get; set; }
        public int FkidPaaasdetalleOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidProveedorSis { get; set; }
        public decimal Cantidad { get; set; }
        public decimal? CostoUnitario { get; set; }
        public string? Observaciones { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

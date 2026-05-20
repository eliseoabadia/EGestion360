namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class PolizaDetalleDto
    {
        public int PkidPolizaDetalle { get; set; }
        public int FkidCuentaContableConta { get; set; }
        public int FkidPolizaConta { get; set; }
        public string? Descripcion { get; set; }
        public decimal? ImporteDebe { get; set; }
        public decimal? ImporteHaber { get; set; }
        public int? FkidReferencia { get; set; }
        public int? FkidTipoDetallePolizaSis { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

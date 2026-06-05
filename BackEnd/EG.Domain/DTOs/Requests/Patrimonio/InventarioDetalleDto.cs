namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class InventarioDetalleDto
    {
        public int PkidInventarioDetalle { get; set; }
        public int FkidInventarioAlma { get; set; }
        public int FkidBienAlma { get; set; }
        public string ClaveBien { get; set; } = string.Empty;
        public string DescripcionBien { get; set; } = string.Empty;
        public string Serie { get; set; } = string.Empty;
        public string UbicacionSistema { get; set; } = string.Empty;
        public string UbicacionFisica { get; set; } = string.Empty;
        public bool Localizado { get; set; }
        public bool TieneDiferencia { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

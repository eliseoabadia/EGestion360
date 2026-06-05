namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class InventarioDetalleResponse
    {
        public int PkidInventarioDetalle { get; set; }
        public int FkidInventarioAlma { get; set; }
        public string InventarioFolio { get; set; } = string.Empty;
        public int FkidBienAlma { get; set; }
        public string BienClave { get; set; } = string.Empty;
        public string BienDescripcion { get; set; } = string.Empty;
        public string Modelo { get; set; } = string.Empty;
        public string Serie { get; set; } = string.Empty;
        public decimal? ValorActual { get; set; }
        public string ClaveBien { get; set; } = string.Empty;
        public string DescripcionBien { get; set; } = string.Empty;
        public string SerieCapturada { get; set; } = string.Empty;
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

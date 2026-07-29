namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class BienDto
    {
        public int PkidBien { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidGrupoBienAlma { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidAreaSis { get; set; }
        public int? FkidProveedorSis { get; set; }
        public int? FkidEstadoBienAlma { get; set; }
        public int? FkidTipoPatrimonioAlma { get; set; }
        public int? FkidMarcaAlma { get; set; }
        public int? FkidMaterialAlma { get; set; }
        public int? FkidTipoAdqAlma { get; set; }
        public int? FkidPartidaConta { get; set; }
        public int? FkidDetalleOrdenCompraOrco { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string ClaveAnt { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Modelo { get; set; } = string.Empty;
        public string Serie { get; set; } = string.Empty;
        public string Requisicion { get; set; } = string.Empty;
        public string Factura { get; set; } = string.Empty;
        public decimal? Costo { get; set; }
        public DateTime? FechaAdq { get; set; }
        public string Referencia { get; set; } = string.Empty;
        public string Notas { get; set; } = string.Empty;
        public string Ubicacion { get; set; } = string.Empty;
        public string Aadquisicion { get; set; } = string.Empty;
        public int? Frente { get; set; }
        public int? Fondo { get; set; }
        public int? Altura { get; set; }
        public int? Diametro { get; set; }
        public int VerificacionesDias { get; set; }
        public int MantenimientoDias { get; set; }
        public bool Mantenimiento { get; set; }
        public bool Calibracion { get; set; }
        public string Rango { get; set; } = string.Empty;
        public string Resolucion { get; set; } = string.Empty;
        public DateTime? FechaUltInv { get; set; }
        public DateTime? FechaReqscn { get; set; }
        public string Estatus { get; set; } = string.Empty;
        public string Caracteristicas { get; set; } = string.Empty;
        public int? Resguardo { get; set; }
        public int? ResguardoAnterior { get; set; }
        public int? RelId { get; set; }
        public decimal? ValorRescate { get; set; }
        public decimal? ValorActual { get; set; }
        public int? Antiguedad { get; set; }
        public int? Progresivo { get; set; }
        public int? Consecutivo { get; set; }
        public string ClaveHist { get; set; } = string.Empty;
        public bool? EstaResguardado { get; set; }
        public DateTime? FechaResguardado { get; set; }
        public bool? Localizado { get; set; }
        public bool? EsContabilizado { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

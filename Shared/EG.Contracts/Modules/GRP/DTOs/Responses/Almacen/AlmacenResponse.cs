namespace EG.Domain.DTOs.Responses.Almacen
{
    public class AlmacenResponse
    {
        public int PkidAlmacen { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int? FkidAreaSis { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public int? FkidUnidadesAlma { get; set; }
        public string UnidadDescripcion { get; set; } = string.Empty;
        public int? FkidMotivoEsAlma { get; set; }
        public string MotivoDescripcion { get; set; } = string.Empty;
        public int? FkidDetalleOrdenCompraOrco { get; set; }
        public string Clave { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public decimal? CostoUnitario { get; set; }
        public decimal? Costo { get; set; }
        public string Factura { get; set; } = string.Empty;
        public string Remision { get; set; } = string.Empty;
        public string Lote { get; set; } = string.Empty;
        public DateTime FechaEntrada { get; set; }
        public DateTime? FechaCaducidad { get; set; }
        public bool AplicaAlmacen { get; set; }
        public bool InventarioCerrado { get; set; }
        public bool EsContabilizado { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string Cucop { get; set; } = string.Empty;
        public string Cabms { get; set; } = string.Empty;
        public string PartidaClave { get; set; } = string.Empty;
        public decimal? ExistenciaMinima { get; set; }
        public decimal? ExistenciaMaxima { get; set; }
        public string EstadoExistencia { get; set; } = string.Empty;
        public string ClaveNombre => string.IsNullOrWhiteSpace(TipoBienDescripcion)
            ? Clave
            : $"{Clave} - {TipoBienDescripcion}";
        public bool EstaBloqueado => InventarioCerrado || EsContabilizado;
    }
}

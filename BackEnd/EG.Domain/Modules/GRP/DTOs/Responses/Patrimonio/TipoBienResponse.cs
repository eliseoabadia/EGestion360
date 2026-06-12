namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class TipoBienResponse
    {
        public int PkidTipoBien { get; set; }
        public int? FkidGrupoBienAlma { get; set; }
        public int? FkidNivelAlma { get; set; }
        public int? FkidPartidaConta { get; set; }
        public int? FkidCuentaContableConta { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public int? FkidLocalizacionAlma { get; set; }
        public int? FkidUnidadesEquivalente { get; set; }
        public string CodigoClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public decimal? DepreciacionAnual { get; set; }
        public int? Consecutivo { get; set; }
        public string Cabms { get; set; } = string.Empty;
        public string Identificador { get; set; } = string.Empty;
        public decimal? ExistenciaMinima { get; set; }
        public decimal? ExistenciaMaxima { get; set; }
        public int? TiempoVida { get; set; }
        public int? PkIdTratadoInt { get; set; }
        public decimal? Cuota { get; set; }
        public bool? ProveeduriaNac { get; set; }
        public bool? CatalogoBasico { get; set; }
        public string CucopPlus { get; set; } = string.Empty;
        public int? CantidadEquivalente { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string GrupoBienDescripcion { get; set; } = string.Empty;
        public int? GrupoBienClave { get; set; }
        public string ClaveAn { get; set; } = string.Empty;
        public string CabmAct { get; set; } = string.Empty;
        public string ClaveCucop { get; set; } = string.Empty;
        public string GrupoBienMedida { get; set; } = string.Empty;
        public string FamiliaDescripcion { get; set; } = string.Empty;
        public string FamiliaClave { get; set; } = string.Empty;
        public int? Nivel { get; set; }
        public string NivelDescripcion { get; set; } = string.Empty;
        public string PartidaClave { get; set; } = string.Empty;
        public string PartidaDescripcion { get; set; } = string.Empty;
        public string CtaCoi { get; set; } = string.Empty;
        public string CuentaDescripcion { get; set; } = string.Empty;
        public string TipoCuenta { get; set; } = string.Empty;
        public string UnidadMedida { get; set; } = string.Empty;
        public string UnidadEquivalenteMedida { get; set; } = string.Empty;
    }
}

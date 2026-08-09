namespace EG.Domain.DTOs.Requests.Contratos
{
    public class OrcoContratoDto
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidOrdenCompraOrco { get; set; }
        public int FkidTipoContratoOrco { get; set; }
        public int FkidTipoDocumentoOrco { get; set; }
        public int? FkidAreaSis { get; set; }
        public int? FkidTipoGarantiaOrco { get; set; }
        public int? FkidProcedimientoContratacionOrco { get; set; }
        public int? FkidFundamentoJuridicoOrco { get; set; }
        public string? FundamentoJuridico { get; set; }
        public string Numero { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateTime FechaContrato { get; set; }
        public DateTime? FechaRecepcion { get; set; }
        public DateTime? FechaFirmaContrato { get; set; }
        public DateTime? FechaVigenciaInicio { get; set; }
        public DateTime? FechaVigenciaFin { get; set; }
        public int? FkidModalidadOrco { get; set; }
        public decimal MontoMaximo { get; set; }
        public decimal MontoMinimo { get; set; }
        public string? Penalizacion { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? FlArchivo { get; set; }
        public string? Justificacion { get; set; }
        public int? FkidArticuloOrco { get; set; }
        public int? FkidFraccionOrco { get; set; }
        public string? SesionSubcomite { get; set; }
        public bool IsSesionExtraordinaria { get; set; }
        public DateTime? FechaSesionSubcomite { get; set; }
        public int FkidEstatusContratoOrco { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class EstadoContratoDto
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidAutorizacionSuficienciaPres { get; set; }
        public int FkidProveedorSis { get; set; }
        public int? FkidPolizaConta { get; set; }
        public string NumeroContrato { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateOnly FechaContrato { get; set; }
        public DateOnly? FechaInicioVigencia { get; set; }
        public DateOnly? FechaFinVigencia { get; set; }
        public decimal MontoTotal { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

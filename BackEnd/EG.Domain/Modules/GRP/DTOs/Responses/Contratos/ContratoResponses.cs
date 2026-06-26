namespace EG.Domain.DTOs.Responses.Contratos
{
    public class OrcoContratoResponse
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int? FkidOrdenCompraOrco { get; set; }
        public string? NumeroOrdenCompra { get; set; }
        public string? OrdenCompraDescripcion { get; set; }
        public int? FkidRequisicionOrco { get; set; }
        public string? RequisicionDescripcion { get; set; }
        public int? FkidProveedorSis { get; set; }
        public string? ProveedorNombre { get; set; }
        public string? ProveedorRfc { get; set; }
        public int FkidTipoContratoOrco { get; set; }
        public string? TipoContratoDescripcion { get; set; }
        public int FkidTipoDocumentoOrco { get; set; }
        public string? TipoDocumentoDescripcion { get; set; }
        public int? FkidAreaSis { get; set; }
        public string? AreaNombre { get; set; }
        public int? FkidTipoGarantiaOrco { get; set; }
        public string? TipoGarantiaDescripcion { get; set; }
        public int? FkidProcedimientoContratacionOrco { get; set; }
        public string? ProcedimientoContratacionDescripcion { get; set; }
        public int? FkidFundamentoJuridicoOrco { get; set; }
        public string? FundamentoJuridicoDescripcion { get; set; }
        public string? FundamentoJuridico { get; set; }
        public string Numero { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateTime FechaContrato { get; set; } = DateTime.Today;
        public DateTime? FechaRecepcion { get; set; }
        public DateTime? FechaFirmaContrato { get; set; }
        public DateTime? FechaVigenciaInicio { get; set; }
        public DateTime? FechaVigenciaFin { get; set; }
        public int? FkidModalidadOrco { get; set; }
        public string? ModalidadDescripcion { get; set; }
        public decimal MontoMaximo { get; set; }
        public decimal MontoMinimo { get; set; }
        public decimal? Penalizacion { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? FlArchivo { get; set; }
        public string? Justificacion { get; set; }
        public int? FkidArticuloOrco { get; set; }
        public string? ArticuloDescripcion { get; set; }
        public int? FkidFraccionOrco { get; set; }
        public string? FraccionDescripcion { get; set; }
        public string? SesionSubcomite { get; set; }
        public bool IsSesionExtraordinaria { get; set; }
        public DateTime? FechaSesionSubcomite { get; set; }
        public int FkidEstatusContratoOrco { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public bool EstaAutorizado => FkidEstatusContratoOrco > 1;
        public bool PuedeModificar => Activo && FkidEstatusContratoOrco == 1;
    }

    public class SaldosContratoResponse
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidAutorizacionSuficienciaPres { get; set; }
        public int? FkidRequisicionOrco { get; set; }
        public int? FkidPolizaConta { get; set; }
        public int FkidProveedorSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidEgresoAutorizadoPres { get; set; }
        public int? FkidProgramaPres { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public string NumeroContrato { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateOnly FechaContrato { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public DateOnly? FechaInicioVigencia { get; set; }
        public DateOnly? FechaFinVigencia { get; set; }
        public decimal MontoTotal { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; }
        public decimal Ene { get; set; }
        public decimal Feb { get; set; }
        public decimal Mar { get; set; }
        public decimal Abr { get; set; }
        public decimal May { get; set; }
        public decimal Jun { get; set; }
        public decimal Jul { get; set; }
        public decimal Ago { get; set; }
        public decimal Sep { get; set; }
        public decimal Oct { get; set; }
        public decimal Nov { get; set; }
        public decimal Dic { get; set; }
        public decimal TotalContratado { get; set; }
        public decimal TotalDevengado { get; set; }
        public decimal Total { get; set; }
        public string Message { get; set; } = string.Empty;
    }

    public class EstadoContratoResponse
    {
        public int PkidContrato { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public int FkidAutorizacionSuficienciaPres { get; set; }
        public int FkidSolicitudSuficienciaPres { get; set; }
        public int? FkidRequisicionOrco { get; set; }
        public string? RequisicionDescripcion { get; set; }
        public int FkidProveedorSis { get; set; }
        public string? ProveedorClave { get; set; }
        public string? ProveedorNombre { get; set; }
        public string? ProveedorRfc { get; set; }
        public int? FkidPolizaConta { get; set; }
        public string? ClavePoliza { get; set; }
        public string NumeroContrato { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateOnly FechaContrato { get; set; } = DateOnly.FromDateTime(DateTime.Today);
        public DateOnly? FechaInicioVigencia { get; set; }
        public DateOnly? FechaFinVigencia { get; set; }
        public decimal MontoTotal { get; set; }
        public string? PlazoEjecucion { get; set; }
        public string? Observaciones { get; set; }
        public int Estatus { get; set; } = 1;
        public string? EstatusDescripcion { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public bool EstaAutorizado => Estatus > 1;
        public bool PuedeModificar => Activo && Estatus == 1;
    }
}

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
        public int PkidEgresoAutorizado { get; set; }
        public int? FkidEgresoProyectadoPres { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? AnioClave { get; set; }
        public int FkidProgramaPres { get; set; }
        public string? ProgramaClave { get; set; }
        public string? ProgramaDescripcion { get; set; }
        public string? ProgramaClaveNombre { get; set; }
        public int FkidPartidaConta { get; set; }
        public string? PartidaClave { get; set; }
        public string? PartidaDescripcion { get; set; }
        public string? PartidaClaveNombre { get; set; }
        public int FkidAreaSis { get; set; }
        public string? AreaClave { get; set; }
        public string? AreaNombre { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public string? FuenteFinanciamientoClave { get; set; }
        public string? FuenteFinanciamientoDescripcion { get; set; }
        public string? FuenteFinanciamientoClaveNombre { get; set; }
        public int? FkidTipoGastoPres { get; set; }
        public int? TipoGastoClave { get; set; }
        public string? TipoGastoDescripcion { get; set; }
        public string? TipoGastoClaveNombre { get; set; }
        public int? FkidDigitoIdentificadorPres { get; set; }
        public string? DigitoIdentificadorClave { get; set; }
        public string? DigitoIdentificadorDescripcion { get; set; }
        public string? DigitoIdentificadorClaveNombre { get; set; }
        public int? FkidDestinoGastoPres { get; set; }
        public string? DestinoGastoClave { get; set; }
        public string? DestinoGastoDescripcion { get; set; }
        public string? DestinoGastoClaveNombre { get; set; }
        public int? FkidPyPres { get; set; }
        public string? PyClave { get; set; }
        public string? PyDescripcion { get; set; }
        public string? PyClaveNombre { get; set; }
        public string? Descripcion { get; set; }
        public DateOnly Fecha { get; set; }
        public decimal? Enero { get; set; }
        public decimal? Febrero { get; set; }
        public decimal? Marzo { get; set; }
        public decimal? Abril { get; set; }
        public decimal? Mayo { get; set; }
        public decimal? Junio { get; set; }
        public decimal? Julio { get; set; }
        public decimal? Agosto { get; set; }
        public decimal? Septiembre { get; set; }
        public decimal? Octubre { get; set; }
        public decimal? Noviembre { get; set; }
        public decimal? Diciembre { get; set; }
        public decimal? Total { get; set; }
        public string? Message { get; set; }
        public string? DescripcionRequisicion { get; set; }
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

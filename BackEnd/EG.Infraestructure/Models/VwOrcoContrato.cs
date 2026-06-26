// <manual> Manual mapping for ORCO.VwContratos. </manual>
#nullable disable
namespace EG.Infraestructure.Models;

public partial class VwOrcoContrato
{
    public int PkidContrato { get; set; }
    public int FkidEmpresaSis { get; set; }
    public string EmpresaNombre { get; set; }
    public int? FkidOrdenCompraOrco { get; set; }
    public string NumeroOrdenCompra { get; set; }
    public string OrdenCompraDescripcion { get; set; }
    public int? FkidRequisicionOrco { get; set; }
    public string RequisicionDescripcion { get; set; }
    public int? FkidProveedorSis { get; set; }
    public string ProveedorNombre { get; set; }
    public string ProveedorRfc { get; set; }
    public int FkidTipoContratoOrco { get; set; }
    public string TipoContratoDescripcion { get; set; }
    public int FkidTipoDocumentoOrco { get; set; }
    public string TipoDocumentoDescripcion { get; set; }
    public int? FkidAreaSis { get; set; }
    public string AreaNombre { get; set; }
    public int? FkidTipoGarantiaOrco { get; set; }
    public string TipoGarantiaDescripcion { get; set; }
    public int? FkidProcedimientoContratacionOrco { get; set; }
    public string ProcedimientoContratacionDescripcion { get; set; }
    public int? FkidFundamentoJuridicoOrco { get; set; }
    public string FundamentoJuridicoDescripcion { get; set; }
    public string FundamentoJuridico { get; set; }
    public string Numero { get; set; }
    public string Descripcion { get; set; }
    public DateTime FechaContrato { get; set; }
    public DateTime? FechaRecepcion { get; set; }
    public DateTime? FechaFirmaContrato { get; set; }
    public DateTime? FechaVigenciaInicio { get; set; }
    public DateTime? FechaVigenciaFin { get; set; }
    public int? FkidModalidadOrco { get; set; }
    public string ModalidadDescripcion { get; set; }
    public decimal MontoMaximo { get; set; }
    public decimal MontoMinimo { get; set; }
    public decimal? Penalizacion { get; set; }
    public string PlazoEjecucion { get; set; }
    public string FlArchivo { get; set; }
    public string Justificacion { get; set; }
    public int? FkidArticuloOrco { get; set; }
    public string ArticuloDescripcion { get; set; }
    public int? FkidFraccionOrco { get; set; }
    public string FraccionDescripcion { get; set; }
    public string SesionSubcomite { get; set; }
    public bool IsSesionExtraordinaria { get; set; }
    public DateTime? FechaSesionSubcomite { get; set; }
    public int FkidEstatusContratoOrco { get; set; }
    public string EstatusDescripcion { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}

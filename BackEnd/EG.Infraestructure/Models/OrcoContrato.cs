// <manual> Manual mapping for the migrated ORCO.Contratos process. </manual>
#nullable disable
namespace EG.Infraestructure.Models;

public partial class OrcoContrato
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
    public string FundamentoJuridico { get; set; }
    public string Numero { get; set; }
    public string Descripcion { get; set; }
    public DateTime FechaContrato { get; set; }
    public DateTime? FechaRecepcion { get; set; }
    public DateTime? FechaFirmaContrato { get; set; }
    public DateTime? FechaVigenciaInicio { get; set; }
    public DateTime? FechaVigenciaFin { get; set; }
    public int? FkidModalidadOrco { get; set; }
    public decimal MontoMaximo { get; set; }
    public decimal MontoMinimo { get; set; }
    public decimal? Penalizacion { get; set; }
    public string PlazoEjecucion { get; set; }
    public string FlArchivo { get; set; }
    public string Justificacion { get; set; }
    public int? FkidArticuloOrco { get; set; }
    public int? FkidFraccionOrco { get; set; }
    public string SesionSubcomite { get; set; }
    public bool IsSesionExtraordinaria { get; set; }
    public DateTime? FechaSesionSubcomite { get; set; }
    public int FkidEstatusContratoOrco { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public int UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}

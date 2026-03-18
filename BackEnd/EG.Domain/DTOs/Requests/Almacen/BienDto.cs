
namespace EG.Domain.DTOs.Requests.Almacen;

public partial class BienDto
{
    public int PkidBien { get; set; }

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

    public string Clave { get; set; }

    public string ClaveAnt { get; set; }

    public string Descripcion { get; set; }

    public string Modelo { get; set; }

    public string Serie { get; set; }

    public string Requisicion { get; set; }

    public string Factura { get; set; }

    public decimal? Costo { get; set; }

    public DateTime? FechaAdq { get; set; }

    public string Referencia { get; set; }

    public string Notas { get; set; }

    public string Ubicacion { get; set; }

    public string Aadquisicion { get; set; }

    public int? Frente { get; set; }

    public int? Fondo { get; set; }

    public int? Altura { get; set; }

    public int? Diametro { get; set; }

    public int VerificacionesDias { get; set; }

    public int MantenimientoDias { get; set; }

    public bool Mantenimiento { get; set; }

    public bool Calibracion { get; set; }

    public string Rango { get; set; }

    public string Resolucion { get; set; }

    public DateTime? FechaUltInv { get; set; }

    public DateTime? FechaReqscn { get; set; }

    public string Estatus { get; set; }

    public string Caracteristicas { get; set; }

    public int? Resguardo { get; set; }

    public int? ResguardoAnterior { get; set; }

    public int? RelId { get; set; }

    public decimal? ValorRescate { get; set; }

    public decimal? ValorActual { get; set; }

    public int? Antiguedad { get; set; }

    public int? Progresivo { get; set; }

    public int? Consecutivo { get; set; }

    public string ClaveHist { get; set; }

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
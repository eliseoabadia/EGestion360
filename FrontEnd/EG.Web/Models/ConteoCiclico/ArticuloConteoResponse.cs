namespace EG.Web.Models.ConteoCiclico;

public partial class ArticuloConteoResponse
{
    public int? PkidArticuloConteo { get; set; }

    public int? FkidPeriodoConteoAlma { get; set; }

    public int? FkidTipoBienAlma { get; set; }

    public int? FkidSucursalSis { get; set; }

    public int? FkidEstatusAlma { get; set; }

    public string CodigoBarras { get; set; }

    public string DescripcionArticulo { get; set; }

    public string UnidadMedida { get; set; }

    public string Ubicacion { get; set; }

    public decimal ExistenciaSistema { get; set; }

    public DateTime? FechaUltimoConteoAnterior { get; set; }

    public decimal? ExistenciaFinal { get; set; }

    public decimal? Diferencia { get; set; }

    public decimal? PorcentajeDiferencia { get; set; }

    public int ConteosRealizados { get; set; }

    public int ConteosPendientes { get; set; }

    public DateTime? FechaInicioConteo { get; set; }

    public DateTime? FechaConclusion { get; set; }

    public int? FkidUsuarioConcluyoSis { get; set; }

    public bool Activo { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int UsuarioCreacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    
}
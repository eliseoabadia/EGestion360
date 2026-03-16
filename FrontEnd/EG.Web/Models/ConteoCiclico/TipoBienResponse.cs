
namespace EG.Web.Models.ConteoCiclico
{
    public class TipoBienResponse
    {
        public int PkidTipoBien { get; set; }

        public string CodigoArticulo { get; set; }

        public string DescripcionArticulo { get; set; }

        public bool Activo { get; set; }

        public string UnidadMedida { get; set; }

        public string UnidadEquivalente { get; set; }

        public int? CantidadEquivalente { get; set; }

        public string Familia { get; set; }

        public string GrupoBien { get; set; }

        public string Nivel { get; set; }

        public string PartidaClave { get; set; }

        public string PartidaDescripcion { get; set; }

        public string CuentaCompleta { get; set; }

        public string CuentaDescripcion { get; set; }

        public string TipoCuenta { get; set; }

        public decimal? ExistenciaMinima { get; set; }

        public decimal? ExistenciaMaxima { get; set; }

        public string Cabms { get; set; }

        public string CucopPlus { get; set; }

        public decimal? DepreciacionAnual { get; set; }

        public int? TiempoVida { get; set; }

        public bool? ProveeduriaNac { get; set; }

        public bool? CatalogoBasico { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }
    }
}

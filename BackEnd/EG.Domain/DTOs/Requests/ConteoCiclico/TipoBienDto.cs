
namespace EG.Domain.DTOs.Requests.ConteoCiclico
{
    public class TipoBienDto
    {
        public int PkidTipoBien { get; set; }

        public int? FkidGrupoBienAlma { get; set; }

        public int? FkidNivelAlma { get; set; }

        public int? FkidPartidaConta { get; set; }

        public int? FkidCuentaContableConta { get; set; }

        public int? FkidUnidadesAlma { get; set; }

        public int? FkidLocalizacionAlma { get; set; }

        public string CodigoClave { get; set; }

        public string Descripcion { get; set; }

        public decimal? DepreciacionAnual { get; set; }

        public int? Consecutivo { get; set; }

        public string Cabms { get; set; }

        public string Identificador { get; set; }

        public decimal? ExistenciaMinima { get; set; }

        public decimal? ExistenciaMaxima { get; set; }

        public int? TiempoVida { get; set; }

        public int? PkIdTratadoInt { get; set; }

        public decimal? Cuota { get; set; }

        public bool? ProveeduriaNac { get; set; }

        public bool? CatalogoBasico { get; set; }

        public string CucopPlus { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public int? FkidUnidadesEquivalente { get; set; }

        public int? CantidadEquivalente { get; set; }
    }
}

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class DetalleRequisicionResponse
    {
        public int PkidDetalleRequisicion { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public decimal Cantidad { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public DateTime? FechaRequisicion { get; set; }
        public bool? RequisicionServicio { get; set; }
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public string TipoBienCodigoClave { get; set; } = string.Empty;
        public string Cabms { get; set; } = string.Empty;
        public string Identificador { get; set; } = string.Empty;
        public decimal? ExistenciaMinima { get; set; }
        public decimal? ExistenciaMaxima { get; set; }
        public string UnidadMedida { get; set; } = string.Empty;
        public string BienClaveNombre { get; set; } = string.Empty;
    }
}

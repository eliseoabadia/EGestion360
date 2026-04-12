namespace EG.Web.Models.Configuration
{
    public class DepartamentoResponse
    {
        public int PkidDepartamento { get; set; }

        public int PkidEmpresa { get; set; }

        public string EmpresaNombre { get; set; } = string.Empty;

        public string Rfc { get; set; } = string.Empty;

        public string DepartamentoNombre { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public int? NivelJerarquico { get; set; }

        public bool DepartamentoActivo { get; set; }

        public bool EmpresaActivo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public string UsuarioCreacionNombre { get; set; } = string.Empty;
    }
}

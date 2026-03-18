using System.ComponentModel.DataAnnotations;

namespace EG.Web.Models.Configuration
{
    public class DepartamentoResponse
    {
        public int PkidEmpresa { get; set; }

        public string EmpresaNombre { get; set; }

        public string Rfc { get; set; }

        public int PkidDepartamento { get; set; }

        public string DepartamentoNombre { get; set; }

        public bool DepartamentoActivo { get; set; }

        public bool EmpresaActivo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}
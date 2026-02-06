using System.ComponentModel.DataAnnotations;

namespace EG.Web.Models.Configuration
{
    public class DepartamentoResponse
    {
        public int? PkidDepartamento { get; set; }

        public int FkidEmpresaSis { get; set; }

        public string Nombre { get; set; }

        public bool Activo { get; set; }
    }

}
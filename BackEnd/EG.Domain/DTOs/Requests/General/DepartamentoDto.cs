using System.ComponentModel.DataAnnotations;

namespace EG.Domain.DTOs.Requests.General
{
    public class DepartamentoDto
    {
        public int? PkidDepartamento { get; set; }

        public int FkidEmpresaSis { get; set; }

        public string Nombre { get; set; }

        public bool Activo { get; set; }
    }

}
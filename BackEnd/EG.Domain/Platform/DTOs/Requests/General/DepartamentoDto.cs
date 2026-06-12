using System.ComponentModel.DataAnnotations;

namespace EG.Domain.DTOs.Requests.General
{
    public class DepartamentoDto
    {
        public int PkidDepartamento { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int? FkidSucursalSis { get; set; }

        public string Nombre { get; set; }

        public string Descripcion { get; set; }

        public int? NivelJerarquico { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }

}
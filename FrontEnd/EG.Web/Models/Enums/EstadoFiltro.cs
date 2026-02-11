using System.ComponentModel.DataAnnotations;

namespace EG.Web.Models.Enums
{
    public enum EstadoFiltro
    {
        [Display(Name = "Todos")]
        Todos,

        [Display(Name = "Activo")]
        Activo,

        [Display(Name = "Inactivo")]
        Inactivo
    }
}

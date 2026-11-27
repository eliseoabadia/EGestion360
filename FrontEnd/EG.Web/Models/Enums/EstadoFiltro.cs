using System.ComponentModel.DataAnnotations;

namespace EG.Web.Models.Enums
{
    public enum EstadoFiltro
    {
        [Display(Name = "Todos")]
        Todos,

        [Display(Name = EG.Common.ApplicationText.Status.Active)]
        Activo,

        [Display(Name = EG.Common.ApplicationText.Status.Inactive)]
        Inactivo
    }
}

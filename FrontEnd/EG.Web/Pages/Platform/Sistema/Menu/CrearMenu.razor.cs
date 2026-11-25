using Microsoft.AspNetCore.Components;

namespace EG.Web.Pages.Platform.Sistema.Menu;

public partial class CrearMenu
{
    [Parameter] public int? MenuIdPadre { get; set; }
    [Parameter] public string? NombreMenuPadre { get; set; }
}

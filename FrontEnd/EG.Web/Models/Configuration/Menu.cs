using System.ComponentModel.DataAnnotations;
using static MudBlazor.CategoryTypes;

namespace EG.Web.Models.Configuration
{
    public class MenuItem
    {
        public int PkidMenu { get; set; }

        public string Nombre { get; set; }

        public int Tipo { get; set; }

        public int? FkidMenuSis { get; set; }

        public string LegacyName { get; set; }

        public string Ruta { get; set; }

        public string ImageUrl { get; set; }

        public string Lenguaje { get; set; }

        public int? Orden { get; set; }

        public bool Activo { get; set; }

        public List<MenuItem> Children { get; set; } = new List<MenuItem>();
    }

    public class MenuResponse
    {
        public List<MenuItem> Items { get; set; }
    }
}

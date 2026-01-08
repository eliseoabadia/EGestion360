using System.ComponentModel.DataAnnotations;
using static MudBlazor.CategoryTypes;

namespace EG.Web.Models.Configuration
{
    public class MenuItem
    {
        public long? PKIdMenu { get; set; }
        [StringLength(150)]
        public string Nombre { get; set; }
        public byte? Tipo { get; set; }
        public long? FKIdMenu_SIS { get; set; }
        [StringLength(80)]
        public string LegacyName { get; set; }
        [StringLength(200)]
        public string Ruta { get; set; }
        [StringLength(120)]
        public string ImageUrl { get; set; }
        public bool? Activo { get; set; }
        public string Lenguaje { get; set; }
        [StringLength(128)]
        public string UserId { get; set; }
        public short? Orden { get; set; }

        public List<MenuItem> Children { get; set; } = new List<MenuItem>();
    }

    public class MenuResponse
    {
        public List<MenuItem> Items { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Web.Models.Configuration
{
    public class MenuItemsResponse
    {
        public int PkidMenu { get; set; }

        public string Nombre { get; set; }

        public int Tipo { get; set; }

        public string TipoDescripcion { get; set; }

        public int? FkidMenuSis { get; set; }

        public string NombreMenuPadre { get; set; }

        public byte? TipoMenuPadre { get; set; }

        public string TipoMenuPadreDescripcion { get; set; }

        public string LegacyName { get; set; }

        public string Ruta { get; set; }

        public string ImageUrl { get; set; }

        public string Lenguaje { get; set; }

        public int? Orden { get; set; }

        public bool Activo { get; set; }

        public string Estado { get; set; }

        public int? CreatedByOperatorId { get; set; }

        public DateTime CreatedDateTime { get; set; }

        public int? ModifiedByOperatorId { get; set; }

        public DateTime? ModifiedDateTime { get; set; }

        public int NivelJerarquico { get; set; }

        public string RutaCompleta { get; set; }

        public int TieneSubmenus { get; set; }

        public string ValidacionEstructura { get; set; }

        //public List<MenuItemsResponse> Children { get; set; } = new List<MenuItemsResponse>();
    }
}

using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Web.Models.Configuration
{
    public class MenuItemsResponse
    {
        public long PkidMenu { get; set; }

        public string Nombre { get; set; }

        public byte Tipo { get; set; }

        public long? FkidMenuSis { get; set; }

        public string LegacyName { get; set; }

        public string Ruta { get; set; }

        public string ImageUrl { get; set; }

        public string Lenguaje { get; set; }

        public short? Orden { get; set; }

        public bool Activo { get; set; }
    }
}

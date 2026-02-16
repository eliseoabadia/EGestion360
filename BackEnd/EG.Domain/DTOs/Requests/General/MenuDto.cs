using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Domain.DTOs.Requests.General
{
    public class MenuDto
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
    }
}

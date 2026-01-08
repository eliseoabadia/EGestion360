using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EG.Dommain.DTOs.Responses
{
    public class spNodeMenuResponseDto
    {
        public long? PKIdMenu { get; set; }
        public string Nombre { get; set; }
        public byte? Tipo { get; set; }
        public long? FKIdMenu_SIS { get; set; }
        public string LegacyName { get; set; }
        public string Ruta { get; set; }
        public string ImageUrl { get; set; }
        public bool? Activo { get; set; }
        public string Lenguaje { get; set; }
        public string UserId { get; set; }
        public short? Orden { get; set; }
    }
}

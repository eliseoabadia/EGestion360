using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EG.Dommain.DTOs.Responses
{
    public class spNodeMenuResponse
    {
        public long? PKIdMenu { get; set; }
        [StringLength(150)]
        public string Nombre { get; set; }
        public byte? Tipo { get; set; }
        public long? FkidMenuSis { get; set; }
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
    }
}

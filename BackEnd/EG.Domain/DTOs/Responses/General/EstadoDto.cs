using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Domain.DTOs.Responses.General
{
    public class EstadoDto
    {
        public int PkidEstado { get; set; }

        public int FkidPaisSis { get; set; }

        public string Nombre { get; set; }
    }
}

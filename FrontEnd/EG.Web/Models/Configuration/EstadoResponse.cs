using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Web.Models.Configuration
{
    public class EstadoResponse
    {
        public int PkidEstado { get; set; }

        public int FkidPaisSis { get; set; }

        public string Nombre { get; set; }
    }
}

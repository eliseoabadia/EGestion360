using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EG.Dommain.DTOs.Responses
{
    public class PerfilUsuarioResponse
    {
        public int FkidUsuarioSis { get; set; }

        public byte[] Fotografia { get; set; }

        public string ContentType { get; set; }

        public string FileName { get; set; }

        public string FileExtension { get; set; }

        public bool Activo { get; set; }
    }
}

using System;

namespace EG.Web.Models.Adquisicion
{
    public class TipoDocumentoResponse
    {
        public int PkidTipoDocumento { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}
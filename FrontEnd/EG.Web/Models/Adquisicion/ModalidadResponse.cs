using System;

namespace EG.Web.Models.Adquisicion
{
    public class ModalidadResponse
    {
        public int PkidModalidad { get; set; }

        public string Descripcion { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}
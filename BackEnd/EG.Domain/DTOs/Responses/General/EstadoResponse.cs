using System;

namespace EG.Domain.DTOs.Responses.General
{
    public class EstadoResponse
    {
        public int PkidEstado { get; set; }

        public int FkidPaisSis { get; set; }

        public string Nombre { get; set; }

        public string CodigoEstado { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}

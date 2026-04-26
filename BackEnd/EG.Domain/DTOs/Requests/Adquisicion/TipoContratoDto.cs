using System;

namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class TipoContratoDto
    {
        public int PkidTipoContrato { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
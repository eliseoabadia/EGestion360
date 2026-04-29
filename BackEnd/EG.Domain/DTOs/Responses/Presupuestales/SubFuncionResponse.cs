using System;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class SubFuncionResponse
    {
        public int PkidSf { get; set; }
        public int FkidFnPres { get; set; }
        public int Clave { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

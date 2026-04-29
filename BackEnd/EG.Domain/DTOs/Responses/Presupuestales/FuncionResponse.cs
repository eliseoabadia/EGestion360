using System;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class FuncionResponse
    {
        public int PkidFn { get; set; }
        public int FkidGfPres { get; set; }
        public int Clave { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

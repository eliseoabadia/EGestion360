using System;

namespace EG.Domain.DTOs.Responses.Presupuestales
{
    public class SubFuncionResponse
    {
        public int PkidSf { get; set; }
        public int SubFuncionClave { get; set; }
        public string SubFuncionDescripcion { get; set; } = string.Empty;
        public int FkidFnPres { get; set; }
        public bool Activo { get; set; }
        public int? FuncionClave { get; set; }
        public string FuncionDescripcion { get; set; } = string.Empty;
        public string SubFuncionClaveNombre { get; set; } = string.Empty;
        public string FuncionClaveNombre { get; set; } = string.Empty;
    }
}

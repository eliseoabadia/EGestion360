
namespace EG.Domain.DTOs.Responses.General
{
    public class EmpresaResponse
    {
        public int PkidEstado { get; set; }

        public string EstadoNombre { get; set; }

        public int PkidEmpresa { get; set; }

        public string EmpresaNombre { get; set; }

        public string Rfc { get; set; }

        public bool EmpresaActivo { get; set; }
    }
}

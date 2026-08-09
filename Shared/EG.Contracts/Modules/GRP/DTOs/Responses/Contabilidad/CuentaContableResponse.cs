using System;

namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class CuentaContableResponse
    {
        public int PkidCuentaContable { get; set; }
        public string Cuenta { get; set; } = string.Empty;
        public string ClaveOrd { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

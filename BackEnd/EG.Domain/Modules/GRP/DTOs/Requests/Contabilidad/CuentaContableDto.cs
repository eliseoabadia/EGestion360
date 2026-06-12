using System;

namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class CuentaContableDto
    {
        public int PkidCuentaContable { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidTipoCuentaConta { get; set; }
        public string Cuenta { get; set; } = string.Empty;
        public string SubCuenta { get; set; } = string.Empty;
        public string SubSubCuenta { get; set; } = string.Empty;
        public string SubSubSubCuenta { get; set; } = string.Empty;
        public string ClaveOrd { get; set; } = string.Empty;
        public decimal Saldo { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

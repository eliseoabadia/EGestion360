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
        public string SubSubSubSubCuenta { get; set; } = string.Empty;
        public string ClaveOrd { get; set; } = string.Empty;
        public decimal Saldo { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string S5 { get; set; } = string.Empty;
        public string S6 { get; set; } = string.Empty;
        public string S7 { get; set; } = string.Empty;
        public string S8 { get; set; } = string.Empty;
        public string S9 { get; set; } = string.Empty;
        public string S10 { get; set; } = string.Empty;
        public string Padre { get; set; } = string.Empty;
        public string Hijo { get; set; } = string.Empty;
        public int? NivelCuenta { get; set; }
        public string CtaCoi { get; set; } = string.Empty;
        public string DescCoi { get; set; } = string.Empty;
        public string TipoCuenta { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

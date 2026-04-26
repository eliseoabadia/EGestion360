using System;

namespace EG.Web.Models.Adquisicion
{
    public class ProveedorResponse
    {
        public int PkidProveedor { get; set; }
        public int? FkIdTipoProveedorSis { get; set; }
        public string TipoProveedorNombre { get; set; } = string.Empty;
        public int? FkidEstatusProveedorSis { get; set; }
        public string EstatusProveedorNombre { get; set; } = string.Empty;
        public int? FkidCuentaContableSis { get; set; }
        public string CuentaContableNombre { get; set; } = string.Empty;
        public int FkidMunicipioSis { get; set; }
        public string MunicipioNombre { get; set; } = string.Empty;
        public int FkidEstadoSis { get; set; }
        public string EstadoNombre { get; set; } = string.Empty;
        public int FkidPaisSis { get; set; }
        public string PaisNombre { get; set; } = string.Empty;
        public int? FkidResponsableSis { get; set; }
        public string ResponsableNombre { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Rfc { get; set; } = string.Empty;
        public string Colonia { get; set; } = string.Empty;
        public string Cp { get; set; } = string.Empty;
        public string Ciudad { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Clave { get; set; } = string.Empty;
        public string Calle { get; set; } = string.Empty;
        public string Numero { get; set; } = string.Empty;
        public DateTime? FechaAlta { get; set; }
        public string TelefonoInstitucional { get; set; } = string.Empty;
        public string Notas { get; set; } = string.Empty;
        public string PaginaWeb { get; set; } = string.Empty;
        public string NumeroInt { get; set; } = string.Empty;
        public string Curp { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}
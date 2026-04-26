using System;

namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class ProveedorDto
    {
        public int PkidProveedor { get; set; }
        public int? FkIdTipoProveedorSis { get; set; }
        public int? FkidEstatusProveedorSis { get; set; }
        public int? FkidCuentaContableSis { get; set; }
        public int FkidMunicipioSis { get; set; }
        public int FkidEstadoSis { get; set; }
        public int FkidPaisSis { get; set; }
        public int? FkidResponsableSis { get; set; }
        public int? FkidAesectorSis { get; set; }
        public int? FkidAedivisionSis { get; set; }
        public int? FkidAegrupoSis { get; set; }
        public int? FkidAeclaseSis { get; set; }
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
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
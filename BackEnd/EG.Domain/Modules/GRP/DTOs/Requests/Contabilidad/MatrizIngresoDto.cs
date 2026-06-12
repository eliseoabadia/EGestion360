using System;

namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class MatrizIngresoDto
    {
        public int PkidMatrizIngreso { get; set; }
        public int? FkIdPrograma { get; set; }
        public int? FkIdOrigen { get; set; }
        public int? FkIdCuentaContableAutorizado { get; set; }
        public int? FkIdCuentaContablePorEjercer { get; set; }
        public int? FkIdCuentaContableModificado { get; set; }
        public int? FkIdCuentaContableDevengado { get; set; }
        public int? FkIdCuentaContableRecaudado { get; set; }
        public int? FkIdCuentaContableDeposito { get; set; }
        public int? FkIdAnioSis { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

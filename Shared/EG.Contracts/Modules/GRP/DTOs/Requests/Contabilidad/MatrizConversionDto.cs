using System;

namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class MatrizConversionDto
    {
        public int PkidMatrizConversion { get; set; }
        public int FkidAnioSis { get; set; }
        public int FkidProgramaPres { get; set; }
        public int FkidPartidaSis { get; set; }
        public int FkidTipoGastoPres { get; set; }
        public int FkidCuentaContableAprobado { get; set; }
        public int FkidCuentaContablePorEjercer { get; set; }
        public int FkidCuentaContableModificado { get; set; }
        public int FkidCuentaContableComprometido { get; set; }
        public int FkidCuentaContableDevengado { get; set; }
        public int FkidCuentaContableEjercido { get; set; }
        public int FkidCuentaContablePagado { get; set; }
        public int FkidCuentaContableGasto { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

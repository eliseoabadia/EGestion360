using System;

namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class MatrizIngresoResponse
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

        // Campos descriptivos de salida. El contrato también se usa al crear y
        // editar, por lo que no deben provocar validación de modelo por null.
        public string ProgramaClave { get; set; } = string.Empty;
        public string ProgramaDescripcion { get; set; } = string.Empty;
        public string OrigenDescripcion { get; set; } = string.Empty;
        public string CuentaAutorizadoNombre { get; set; } = string.Empty;
        public string CuentaPorEjecutarNombre { get; set; } = string.Empty;
        public string CuentaModificadoNombre { get; set; } = string.Empty;
        public string CuentaDevengadoNombre { get; set; } = string.Empty;
        public string CuentaRecaudadoNombre { get; set; } = string.Empty;
        public string CuentaDepositoNombre { get; set; } = string.Empty;
    }
}

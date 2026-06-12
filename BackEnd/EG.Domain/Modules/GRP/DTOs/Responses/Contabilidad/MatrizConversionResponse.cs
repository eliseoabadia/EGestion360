using System;

namespace EG.Domain.DTOs.Responses.Contabilidad
{
public class MatrizConversionResponse
{
    public int PkidMatrizConversion { get; set; }
    public int FkidAnioSis { get; set; }
    public int FkidProgramaPres { get; set; }
    public int FkidPartidaSis { get; set; }
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

    // Navegación (opcional para mostrar en UI)
    public string ProgramaClave { get; set; }
    public string PartidaDescripcion { get; set; }
    
    // Navegación para cuentas contables
    public string CuentaAprobadoNombre { get; set; }
    public string CuentaPorEjercerNombre { get; set; }
    public string CuentaModificadoNombre { get; set; }
    public string CuentaComprometidoNombre { get; set; }
    public string CuentaDevengadoNombre { get; set; }
    public string CuentaEjercidoNombre { get; set; }
    public string CuentaPagadoNombre { get; set; }
    public string CuentaGastoNombre { get; set; }
}
}

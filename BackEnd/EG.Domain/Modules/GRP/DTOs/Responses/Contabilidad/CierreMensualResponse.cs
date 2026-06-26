namespace EG.Domain.DTOs.Responses.Contabilidad
{
    public class CierreMensualResponse
    {
        public int PkidSaldoMensual { get; set; }
        public int PkidMesActual { get; set; }
        public int FkidAnioSis { get; set; }
        public int Anio { get; set; }
        public int FkidMesSis { get; set; }
        public string Mes { get; set; } = string.Empty;
        public string MesAbreviatura { get; set; } = string.Empty;
        public string PeriodoNombre { get; set; } = string.Empty;
        public int FkidCuentaContable { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string CuentaClave { get; set; } = string.Empty;
        public string CuentaDescripcion { get; set; } = string.Empty;
        public string CuentaClaveNombre { get; set; } = string.Empty;
        public decimal SaldoInicial { get; set; }
        public decimal Cargos { get; set; }
        public decimal Abonos { get; set; }
        public decimal SaldoFinal { get; set; }
        public decimal TotalSaldoInicial { get; set; }
        public decimal TotalCargos { get; set; }
        public decimal TotalAbonos { get; set; }
        public decimal TotalSaldoFinal { get; set; }
        public int CuentasConSaldo { get; set; }
        public int SaldosGenerados { get; set; }
        public int TotalPolizas { get; set; }
        public int PolizasBalanceadas { get; set; }
        public int PolizasPendientes { get; set; }
        public int Movimientos { get; set; }
        public decimal TotalDebe { get; set; }
        public decimal TotalHaber { get; set; }
        public decimal Diferencia { get; set; }
        public bool PuedeRealizarCierre { get; set; }
        public string MotivoBloqueo { get; set; } = string.Empty;
        public DateTime? FechaUltimoCierre { get; set; }
        public string ResultTipo { get; set; } = string.Empty;
        public string ResultLiga { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}

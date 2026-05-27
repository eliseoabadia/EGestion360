namespace EG.Domain.DTOs.Responses.Tesoreria
{
    public class BancoResponse
    {
        public int PkidBanco { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string NombreCorto { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public string EmpresaRfc { get; set; } = string.Empty;
        public string ClaveNombre { get; set; } = string.Empty;
    }

    public class CuentaBancariaResponse
    {
        public int PkidCuentaBancaria { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int? FkidBancoTes { get; set; }
        public int? FkidCuentaContableSis { get; set; }
        public int FkidTipoMonedaTes { get; set; }
        public string NumeroCuenta { get; set; } = string.Empty;
        public string Clabe { get; set; } = string.Empty;
        public string Titular { get; set; } = string.Empty;
        public decimal SaldoInicial { get; set; }
        public decimal SaldoActual { get; set; }
        public DateOnly? FechaApertura { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string BancoNombre { get; set; } = string.Empty;
        public string BancoClave { get; set; } = string.Empty;
        public string MonedaDescripcion { get; set; } = string.Empty;
        public string MonedaSimbolo { get; set; } = string.Empty;
        public string CuentaContable { get; set; } = string.Empty;
        public string CuentaContableDescripcion { get; set; } = string.Empty;
    }

    public class IntermediarioFinancieroResponse
    {
        public int PkidIntermediarioFinanciero { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string RazonSocial { get; set; } = string.Empty;
        public string Rfc { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public string EmpresaRfc { get; set; } = string.Empty;
        public string ClaveNombre { get; set; } = string.Empty;
    }

    public class InstrumentoResponse
    {
        public int PkidInstrumento { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidTipoInversionTes { get; set; }
        public int FkidIntermediarioFinancieroTes { get; set; }
        public int? FkidTipoPlazoTes { get; set; }
        public int FkidTipoMonedaTes { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public decimal? TasaInteres { get; set; }
        public int? PlazoOriginal { get; set; }
        public DateOnly? FechaEmision { get; set; }
        public DateOnly? FechaVencimiento { get; set; }
        public decimal? MontoMinimo { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public string TipoInversionDescripcion { get; set; } = string.Empty;
        public string IntermediarioNombre { get; set; } = string.Empty;
        public string IntermediarioClave { get; set; } = string.Empty;
        public string TipoPlazoDescripcion { get; set; } = string.Empty;
        public int? TipoPlazoDias { get; set; }
        public string TipoMonedaDescripcion { get; set; } = string.Empty;
        public string TipoMonedaCodigo { get; set; } = string.Empty;
        public string TipoMonedaSimbolo { get; set; } = string.Empty;
        public string ClaveNombre { get; set; } = string.Empty;
    }

    public class InversionResponse
    {
        public int PkidInversion { get; set; }
        public int FkidInstrumento { get; set; }
        public int FkidCuentaBancaria { get; set; }
        public decimal Monto { get; set; }
        public DateOnly FechaInversion { get; set; }
        public DateOnly? FechaVencimiento { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string CuentaBan { get; set; } = string.Empty;
        public string Instrumento { get; set; } = string.Empty;
        public decimal Intereses { get; set; }
        public decimal Retiros { get; set; }
        public decimal? Saldo { get; set; }
    }

    public class InteresResponse
    {
        public int PkidInteres { get; set; }
        public int FkidInversion { get; set; }
        public decimal Monto { get; set; }
        public DateOnly FechaGeneracion { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }

    public class RetiroResponse
    {
        public int PkidRetiro { get; set; }
        public int FkidInversion { get; set; }
        public int? FkidTipoRetiroTes { get; set; }
        public decimal Monto { get; set; }
        public DateOnly FechaRetiro { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string TipoRetiroDescripcion { get; set; } = string.Empty;
    }

    public class TipoPlazoResponse
    {
        public int PkidTipoPlazo { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public int Dias { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string ClaveNombre { get; set; } = string.Empty;
    }

    public class TipoRetiroResponse
    {
        public int PkidTipoRetiro { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public string ClaveNombre { get; set; } = string.Empty;
    }
}

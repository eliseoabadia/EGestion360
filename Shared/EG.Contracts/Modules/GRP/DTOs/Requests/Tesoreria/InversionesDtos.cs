namespace EG.Domain.DTOs.Requests.Tesoreria
{
    public class BancoDto
    {
        public int PkidBanco { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string NombreCorto { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class CuentaBancariaDto
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
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class IntermediarioFinancieroDto
    {
        public int PkidIntermediarioFinanciero { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string RazonSocial { get; set; } = string.Empty;
        public string Rfc { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class InstrumentoDto
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
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class InversionDto
    {
        public int PkidInversion { get; set; }
        public int FkidInstrumento { get; set; }
        public int FkidCuentaBancaria { get; set; }
        public decimal Monto { get; set; }
        public DateOnly FechaInversion { get; set; }
        public DateOnly? FechaVencimiento { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class InteresDto
    {
        public int PkidInteres { get; set; }
        public int FkidInversion { get; set; }
        public decimal Monto { get; set; }
        public DateOnly FechaGeneracion { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class RetiroDto
    {
        public int PkidRetiro { get; set; }
        public int FkidInversion { get; set; }
        public int? FkidTipoRetiroTes { get; set; }
        public decimal Monto { get; set; }
        public DateOnly FechaRetiro { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class TipoPlazoDto
    {
        public int PkidTipoPlazo { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public int Dias { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class TipoRetiroDto
    {
        public int PkidTipoRetiro { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}

using System;

namespace EG.Domain.DTOs.Requests.Nomina
{
    public class NomConceptoDto
    {
        public int PkidConcepto { get; set; }

        public string Clave { get; set; } = string.Empty;

        public string SubClave { get; set; } = string.Empty;

        public string PerDed { get; set; } = string.Empty;

        public string Nombre { get; set; } = string.Empty;

        public int FkidFormaCalculoNom { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomConceptoFactorDto
    {
        public int PkidConceptoFactor { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal Factor { get; set; }

        public int QuincenaInicio { get; set; }

        public int QuincenaFin { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string Observaciones { get; set; } = string.Empty;
    }

    public class NomConceptoFijoDto
    {
        public int PkidConceptoFijo { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidConceptoNom { get; set; }

        public int FkidPuestoNom { get; set; }

        public decimal ImporteMensualFijo { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public DateOnly? FechaIni { get; set; }

        public DateOnly? FechaFin { get; set; }
    }

    public class NomConceptoPorcentajeDto
    {
        public int PkidConceptoPorcentaje { get; set; }

        public int FkidConceptoProporcionalNom { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal Porcentaje { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomConceptoProporcionalDto
    {
        public int PkidConceptoProporcional { get; set; }

        public int? FkidEmpresaSis { get; set; }

        public int? FkidPuestoNom { get; set; }

        public int? FkidConceptoNom { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomConceptoTabularDto
    {
        public int PkidConceptoTabulador { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidConceptoNom { get; set; }

        public int FkidPuestoNom { get; set; }

        public decimal ImporteMensual { get; set; }

        public DateOnly? FechaInicio { get; set; }

        public DateOnly? FechaFin { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomConceptoVariableDto
    {
        public int PkidConceptoVariable { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidPeriodo { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal Importe { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomContratoTercerosDto
    {
        public int PkidContratoTercero { get; set; }

        public int FkidEmpresaSis { get; set; }

        public string NombreContrato { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomCreditoDto
    {
        public int PkidCredito { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidContratoTerceroNom { get; set; }

        public string MotivoCredito { get; set; } = string.Empty;

        public decimal ImporteCredito { get; set; }

        public decimal TasaInteres { get; set; }

        public int NumeroPagos { get; set; }

        public int FkidPeriodoInicial { get; set; }

        public decimal ImportePago { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomDescuentoCreditoDto
    {
        public int PkidDescuentoCredito { get; set; }

        public int FkidCreditoNom { get; set; }

        public int FkidPeriodo { get; set; }

        public int NumeroPago { get; set; }

        public bool EstaDescontado { get; set; }

        public DateOnly? FechaDescuento { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomDescuentoInfonavitDto
    {
        public int PkidDescuentoInfonavit { get; set; }

        public int FkidInfonavitNom { get; set; }

        public int FkidPeriodo { get; set; }

        public int NumeroPago { get; set; }

        public int EstaDescontado { get; set; }

        public DateOnly? FechaDescuento { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomEstatusPagoDto
    {
        public int PkidEstatusPago { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }

    public class NomFactorIntDto
    {
        public int PkidFactor { get; set; }

        public int Anio { get; set; }

        public int Vacaciones { get; set; }

        public decimal Vacacional { get; set; }

        public int Aguinaldo { get; set; }

        public decimal? Integracion { get; set; }

        public decimal? PrimaDominical { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomInfonavitDto
    {
        public int PkidInfonavit { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidUnidadInfonavitNom { get; set; }

        public string MotivoInfonavit { get; set; } = string.Empty;

        public decimal ImporteInfonavit { get; set; }

        public decimal TasaInteres { get; set; }

        public int NumeroPagos { get; set; }

        public int FkidPeriodoInicial { get; set; }

        public decimal ImportePago { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public int? FkidPeriodoFinal { get; set; }

        public DateOnly FechaInicial { get; set; }

        public DateOnly FechaFinal { get; set; }
    }

    public class NomPeriodoActivoDto
    {
        public int PkidPeriodoActivo { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int IdPeriodo { get; set; }

        public bool EstaCerrado { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public bool? EstaComprometido { get; set; }

        public bool? EstaDevengado { get; set; }

        public bool? EstaEjercido { get; set; }
    }

    public class NomSalarioMinimoDto
    {
        public int PkidSalarioMinimo { get; set; }

        public int ZonaEconomica { get; set; }

        public int QuincenaInicio { get; set; }

        public int QuincenaFin { get; set; }

        public decimal Importe { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomSueldoEspecialDto
    {
        public int PkidSueldoEspecial { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidNominaEspecialNom { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal? Percepcion { get; set; }

        public decimal? Deduccion { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public decimal? Aportacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomSueldoLiqFinDto
    {
        public int PkidSueldoLiqFin { get; set; }

        public int FkidContratoPres { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal Percepcion { get; set; }

        public decimal Deduccion { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public decimal? Aportacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomSueldoMensualDto
    {
        public int PkidSueldoMensual { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidPeriodoMensualNom { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal? Percepcion { get; set; }

        public decimal? Deduccion { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public decimal? Aportacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomSueldoQuincenalDto
    {
        public int PkidSueldoQuincenal { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidPeriodoQuincenalNom { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal? Percepcion { get; set; }

        public decimal? Deduccion { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public decimal? Aportacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomSueldoSemanalDto
    {
        public int PkidSueldoSemanal { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidPersonaNom { get; set; }

        public int FkidPeriodoSemanalNom { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal? Percepcion { get; set; }

        public decimal? Deduccion { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public decimal? Aportacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomTipoIncapacidadDto
    {
        public int PkidTipoIncapacidad { get; set; }

        public int Clave { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomTipoPagoDto
    {
        public int PkidTipoPago { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public int TotalPeriodos { get; set; }
    }

    public class NomTipoPensionDto
    {
        public int PkidTipoPension { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }
}
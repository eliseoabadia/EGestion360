using System;

namespace EG.Domain.DTOs.Requests.Nomina
{
    public class NomEmpresaNominaDto
    {
        public int PkidEmpresaNomina { get; set; }

        public string RazonSocial { get; set; } = string.Empty;

        public string RegImss { get; set; } = string.Empty;

        public string RegInfonavit { get; set; } = string.Empty;

        public string CedEmpadronam { get; set; } = string.Empty;

        public string NoFonacot { get; set; } = string.Empty;

        public string UsAdmin { get; set; } = string.Empty;

        public string EmailAdmin { get; set; } = string.Empty;

        public int? FkidPeriodoPagoSis { get; set; }

        public decimal? PrimaRiesgoImss { get; set; }

        public bool UsaSueldoTabular { get; set; }

        public int? FkidTipoPagoNom { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomUniversoDto
    {
        public int PkidUniverso { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomNivelDto
    {
        public int PkidNivel { get; set; }

        public string Clave { get; set; } = string.Empty;

        public int? FkidUniversoNom { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomClasePuestoDto
    {
        public int PkidClasePuesto { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomPuestoDto
    {
        public int PkidPuesto { get; set; }

        public int? FkidPuestoPadreNom { get; set; }

        public int FkidEmpresaNominaNom { get; set; }

        public string Nombre { get; set; } = string.Empty;

        public int? FkidNivelNom { get; set; }

        public int? FkidClasePuestoNom { get; set; }

        public string Descripcion1 { get; set; } = string.Empty;

        public string Descripcion2 { get; set; } = string.Empty;

        public int? Orden { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomPlazaAutorizadaDto
    {
        public int PkidPlazaAutorizada { get; set; }
        public int? FkidPuestoNom { get; set; }
        public int? FkidAreaSis { get; set; }
        public int? FkidSituacionPlazaRh { get; set; }
        public string SituacionPlaza { get; set; } = string.Empty;
        public int? Plaza { get; set; }
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public int? TipoPlaza { get; set; }
        public string Documento { get; set; } = string.Empty;
        public DateTime? FechaDocumento { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public int? FkidEmpresaSis { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public bool Activo { get; set; }
    }

    public class NomNombramientoDto
    {
        public int PkidNombramiento { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomImporteNivelDto
    {
        public int PkidImporteNivel { get; set; }

        public string Clave { get; set; } = string.Empty;

        public decimal ImpSdi { get; set; }

        public decimal ImpImss15 { get; set; }

        public decimal ImpImss16 { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomContratoLaboralDto
    {
        public int PkidContratoLaboral { get; set; }

        public int FkidEmpresaNominaNom { get; set; }

        public int FkidPersonaNom { get; set; }

        public DateOnly FechaInicio { get; set; }

        public DateOnly FechaFin { get; set; }

        public int FkidPuestoNom { get; set; }

        public string NumeroContrato { get; set; } = string.Empty;

        public string Vigencia { get; set; } = string.Empty;

        public decimal SueldoMensual { get; set; }

        public int? FkidNombramientoNom { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

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

    public class NomTablaFiscalDto
    {
        public int PkidTablaFiscal { get; set; }

        public string Catalogo { get; set; } = string.Empty;

        public string LegacyTable { get; set; } = string.Empty;

        public int? LegacyId { get; set; }

        public string Clave { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public decimal? Valor1 { get; set; }

        public decimal? Valor2 { get; set; }

        public decimal? Valor3 { get; set; }

        public decimal? Valor4 { get; set; }

        public DateTime? FechaInicio { get; set; }

        public DateTime? FechaFin { get; set; }

        public int? FkidCatalogoPadreNom { get; set; }

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

    public class NomCatalogoSimpleDto
    {
        public int PkidCatalogoSimple { get; set; }

        public string Catalogo { get; set; } = string.Empty;

        public string LegacyTable { get; set; } = string.Empty;

        public int? LegacyId { get; set; }

        public string Clave { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public string DescripcionCorta { get; set; } = string.Empty;

        public int? FkidCatalogoPadreNom { get; set; }

        public decimal? ValorDecimal1 { get; set; }

        public decimal? ValorDecimal2 { get; set; }

        public int? ValorEntero1 { get; set; }

        public int? ValorEntero2 { get; set; }

        public DateTime? FechaInicio { get; set; }

        public DateTime? FechaFin { get; set; }

        public string DatoExtra1 { get; set; } = string.Empty;

        public string DatoExtra2 { get; set; } = string.Empty;

        public int? Orden { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomEstadoCivilDto
    {
        public int PkidEstadoCivil { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomEscolaridadDto
    {
        public int PkidEscolaridad { get; set; }

        public int? LegacyId { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomDiaSemanaDto
    {
        public int PkidDiaSemana { get; set; }

        public int? LegacyId { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomMedodoPagoDto
    {
        public int PkidMetodoPago { get; set; }

        public int? LegacyId { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomParentescoDto
    {
        public int PkidParentesco { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomTipoContratacionDto
    {
        public int PkidTipoContratacion { get; set; }

        public string Tipo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public string Explicacion { get; set; } = string.Empty;

        public string DoctoComprobacion { get; set; } = string.Empty;

        public string Normatividad { get; set; } = string.Empty;

        public string Deducciones { get; set; } = string.Empty;

        public string DoctoComprob { get; set; } = string.Empty;

        public string RelacionLaboral { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomTipoIncidenciaDto
    {
        public int PkidTipoIncidencia { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public double? DiasPenalizacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }

    public class NomTipoJustificacionDto
    {
        public int PkidTipoJustificacion { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }
    }
}

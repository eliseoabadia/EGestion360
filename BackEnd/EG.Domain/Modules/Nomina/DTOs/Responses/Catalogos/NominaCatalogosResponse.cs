using System;

namespace EG.Domain.DTOs.Responses.Nomina
{
    public class NomEmpresaNominaResponse
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

        public string ClaveNombre => $"{PkidEmpresaNomina} - {RazonSocial}".Trim(' ', '-');
    }

    public class NomUniversoResponse
    {
        public int PkidUniverso { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{PkidUniverso} - {Descripcion}".Trim(' ', '-');
    }

    public class NomNivelResponse
    {
        public int PkidNivel { get; set; }

        public string Clave { get; set; } = string.Empty;

        public int? FkidUniversoNom { get; set; }

        public string UniversoDescripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{Clave} - Universo {UniversoDescripcion}".Trim(' ', '-');
    }

    public class NomClasePuestoResponse
    {
        public int PkidClasePuesto { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{PkidClasePuesto} - {Descripcion}".Trim(' ', '-');
    }

    public class NomPuestoResponse
    {
        public int PkidPuesto { get; set; }

        public int? FkidPuestoPadreNom { get; set; }

        public string PuestoPadreNombre { get; set; } = string.Empty;

        public int FkidEmpresaNominaNom { get; set; }

        public string EmpresaNominaNombre { get; set; } = string.Empty;

        public string Nombre { get; set; } = string.Empty;

        public int? FkidNivelNom { get; set; }

        public string NivelClave { get; set; } = string.Empty;

        public string UniversoDescripcion { get; set; } = string.Empty;

        public int? FkidClasePuestoNom { get; set; }

        public string ClasePuestoDescripcion { get; set; } = string.Empty;

        public string Descripcion1 { get; set; } = string.Empty;

        public string Descripcion2 { get; set; } = string.Empty;

        public int? Orden { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{PkidPuesto} - {Nombre} - Nivel {NivelClave}".Trim(' ', '-');
    }

    public class NomNombramientoResponse
    {
        public int PkidNombramiento { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{PkidNombramiento} - {Descripcion}".Trim(' ', '-');
    }

    public class NomImporteNivelResponse
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

        public string ClaveNombre => $"{Clave} - SDI {ImpSdi:0.00}".Trim(' ', '-');
    }

    public class NomContratoLaboralResponse
    {
        public int PkidContratoLaboral { get; set; }

        public int FkidEmpresaNominaNom { get; set; }

        public string EmpresaNominaNombre { get; set; } = string.Empty;

        public int FkidPersonaNom { get; set; }

        public string PersonaClaveNombre { get; set; } = string.Empty;

        public DateOnly FechaInicio { get; set; }

        public DateOnly FechaFin { get; set; }

        public int FkidPuestoNom { get; set; }

        public string PuestoNombre { get; set; } = string.Empty;

        public string NumeroContrato { get; set; } = string.Empty;

        public string Vigencia { get; set; } = string.Empty;

        public decimal SueldoMensual { get; set; }

        public int? FkidNombramientoNom { get; set; }

        public string NombramientoDescripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{NumeroContrato} - {PersonaClaveNombre}".Trim(' ', '-');
    }

    public class NomConceptoResponse
    {
        public int PkidConcepto { get; set; }

        public int PkidNomConcepto
        {
            get => PkidConcepto;
            set => PkidConcepto = value;
        }

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

        public string ClaveNombre => $"{Clave} - {Nombre}".Trim(' ', '-');
    }

    public class NomConceptoFactorResponse
    {
        public int PkidConceptoFactor { get; set; }

        public int PkidNomConceptoFactor
        {
            get => PkidConceptoFactor;
            set => PkidConceptoFactor = value;
        }

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

        public string ClaveNombre => PkidConceptoFactor.ToString();
    }

    public class NomConceptoFijoResponse
    {
        public int PkidConceptoFijo { get; set; }

        public int PkidNomConceptoFijo
        {
            get => PkidConceptoFijo;
            set => PkidConceptoFijo = value;
        }

        public int FkidEmpresaSis { get; set; }

        public string EmpresaNominaNombre { get; set; } = string.Empty;

        public int FkidConceptoNom { get; set; }

        public string ConceptoClaveNombre { get; set; } = string.Empty;

        public int FkidPuestoNom { get; set; }

        public string PuestoNombre { get; set; } = string.Empty;

        public string PuestoClaveNombre { get; set; } = string.Empty;

        public string NivelClave { get; set; } = string.Empty;

        public string UniversoDescripcion { get; set; } = string.Empty;

        public string ClasePuestoDescripcion { get; set; } = string.Empty;

        public decimal ImporteMensualFijo { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public DateOnly? FechaIni { get; set; }

        public DateOnly? FechaFin { get; set; }

        public string ClaveNombre => $"{PuestoNombre} - {ConceptoClaveNombre}".Trim(' ', '-');
    }

    public class NomConceptoPorcentajeResponse
    {
        public int PkidConceptoPorcentaje { get; set; }

        public int PkidNomConceptoPorcentaje
        {
            get => PkidConceptoPorcentaje;
            set => PkidConceptoPorcentaje = value;
        }

        public int FkidConceptoProporcionalNom { get; set; }

        public int FkidConceptoNom { get; set; }

        public decimal Porcentaje { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => PkidConceptoPorcentaje.ToString();
    }

    public class NomConceptoProporcionalResponse
    {
        public int PkidConceptoProporcional { get; set; }

        public int PkidNomConceptoProporcional
        {
            get => PkidConceptoProporcional;
            set => PkidConceptoProporcional = value;
        }

        public int? FkidEmpresaSis { get; set; }

        public string EmpresaNominaNombre { get; set; } = string.Empty;

        public int? FkidPuestoNom { get; set; }

        public string PuestoNombre { get; set; } = string.Empty;

        public string PuestoClaveNombre { get; set; } = string.Empty;

        public string NivelClave { get; set; } = string.Empty;

        public string UniversoDescripcion { get; set; } = string.Empty;

        public string ClasePuestoDescripcion { get; set; } = string.Empty;

        public int? FkidConceptoNom { get; set; }

        public string ConceptoClaveNombre { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{PuestoNombre} - {ConceptoClaveNombre}".Trim(' ', '-');
    }

    public class NomConceptoTabularResponse
    {
        public int PkidConceptoTabulador { get; set; }

        public int PkidNomConceptoTabulador
        {
            get => PkidConceptoTabulador;
            set => PkidConceptoTabulador = value;
        }

        public int FkidEmpresaSis { get; set; }

        public string EmpresaNominaNombre { get; set; } = string.Empty;

        public int FkidConceptoNom { get; set; }

        public string ConceptoClaveNombre { get; set; } = string.Empty;

        public int FkidPuestoNom { get; set; }

        public string PuestoNombre { get; set; } = string.Empty;

        public string PuestoClaveNombre { get; set; } = string.Empty;

        public string NivelClave { get; set; } = string.Empty;

        public string UniversoDescripcion { get; set; } = string.Empty;

        public string ClasePuestoDescripcion { get; set; } = string.Empty;

        public decimal ImporteMensual { get; set; }

        public DateOnly? FechaInicio { get; set; }

        public DateOnly? FechaFin { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{PuestoNombre} - {ConceptoClaveNombre}".Trim(' ', '-');
    }

    public class NomConceptoVariableResponse
    {
        public int PkidConceptoVariable { get; set; }

        public int PkidNomConceptoVariable
        {
            get => PkidConceptoVariable;
            set => PkidConceptoVariable = value;
        }

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

        public string ClaveNombre => Referencia ?? string.Empty;
    }

    public class NomContratoTercerosResponse
    {
        public int PkidContratoTercero { get; set; }

        public int PkidNomContratoTercero
        {
            get => PkidContratoTercero;
            set => PkidContratoTercero = value;
        }

        public int FkidEmpresaSis { get; set; }

        public string NombreContrato { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => Descripcion ?? string.Empty;
    }

    public class NomCreditoResponse
    {
        public int PkidCredito { get; set; }

        public int PkidNomCredito
        {
            get => PkidCredito;
            set => PkidCredito = value;
        }

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

        public string ClaveNombre => MotivoCredito ?? string.Empty;
    }

    public class NomDescuentoCreditoResponse
    {
        public int PkidDescuentoCredito { get; set; }

        public int PkidNomDescuentoCredito
        {
            get => PkidDescuentoCredito;
            set => PkidDescuentoCredito = value;
        }

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

        public string ClaveNombre => PkidDescuentoCredito.ToString();
    }

    public class NomDescuentoInfonavitResponse
    {
        public int PkidDescuentoInfonavit { get; set; }

        public int PkidNomDescuentoInfonavit
        {
            get => PkidDescuentoInfonavit;
            set => PkidDescuentoInfonavit = value;
        }

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

        public string ClaveNombre => PkidDescuentoInfonavit.ToString();
    }

    public class NomEstatusPagoResponse
    {
        public int PkidEstatusPago { get; set; }

        public int PkidNomEstatusPago
        {
            get => PkidEstatusPago;
            set => PkidEstatusPago = value;
        }

        public string Descripcion { get; set; } = string.Empty;

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public string ClaveNombre => Descripcion ?? string.Empty;
    }

    public class NomFactorIntResponse
    {
        public int PkidFactor { get; set; }

        public int PkidNomFactor
        {
            get => PkidFactor;
            set => PkidFactor = value;
        }

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

        public string ClaveNombre => PkidFactor.ToString();
    }

    public class NomInfonavitResponse
    {
        public int PkidInfonavit { get; set; }

        public int PkidNomInfonavit
        {
            get => PkidInfonavit;
            set => PkidInfonavit = value;
        }

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

        public string ClaveNombre => MotivoInfonavit ?? string.Empty;
    }

    public class NomPeriodoActivoResponse
    {
        public int PkidPeriodoActivo { get; set; }

        public int PkidNomPeriodoActivo
        {
            get => PkidPeriodoActivo;
            set => PkidPeriodoActivo = value;
        }

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

        public string ClaveNombre => PkidPeriodoActivo.ToString();
    }

    public class NomSalarioMinimoResponse
    {
        public int PkidSalarioMinimo { get; set; }

        public int PkidNomSalarioMinimo
        {
            get => PkidSalarioMinimo;
            set => PkidSalarioMinimo = value;
        }

        public int ZonaEconomica { get; set; }

        public int QuincenaInicio { get; set; }

        public int QuincenaFin { get; set; }

        public decimal Importe { get; set; }

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => PkidSalarioMinimo.ToString();
    }

    public class NomSueldoEspecialResponse
    {
        public int PkidSueldoEspecial { get; set; }

        public int PkidNomSueldoEspecial
        {
            get => PkidSueldoEspecial;
            set => PkidSueldoEspecial = value;
        }

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

        public string ClaveNombre => Referencia ?? string.Empty;
    }

    public class NomSueldoLiqFinResponse
    {
        public int PkidSueldoLiqFin { get; set; }

        public int PkidNomSueldoLiqFin
        {
            get => PkidSueldoLiqFin;
            set => PkidSueldoLiqFin = value;
        }

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

        public string ClaveNombre => Referencia ?? string.Empty;
    }

    public class NomSueldoMensualResponse
    {
        public int PkidSueldoMensual { get; set; }

        public int PkidNomSueldoMensual
        {
            get => PkidSueldoMensual;
            set => PkidSueldoMensual = value;
        }

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

        public string ClaveNombre => Referencia ?? string.Empty;
    }

    public class NomSueldoQuincenalResponse
    {
        public int PkidSueldoQuincenal { get; set; }

        public int PkidNomSueldoQuincenal
        {
            get => PkidSueldoQuincenal;
            set => PkidSueldoQuincenal = value;
        }

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

        public string ClaveNombre => Referencia ?? string.Empty;
    }

    public class NomSueldoSemanalResponse
    {
        public int PkidSueldoSemanal { get; set; }

        public int PkidNomSueldoSemanal
        {
            get => PkidSueldoSemanal;
            set => PkidSueldoSemanal = value;
        }

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

        public string ClaveNombre => Referencia ?? string.Empty;
    }

    public class NomTipoIncapacidadResponse
    {
        public int PkidTipoIncapacidad { get; set; }

        public int PkidNomTipoIncapacidad
        {
            get => PkidTipoIncapacidad;
            set => PkidTipoIncapacidad = value;
        }

        public int Clave { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => $"{Clave} - {Descripcion}".Trim(' ', '-');
    }

    public class NomTipoPagoResponse
    {
        public int PkidTipoPago { get; set; }

        public int PkidNomTipoPago
        {
            get => PkidTipoPago;
            set => PkidTipoPago = value;
        }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public int TotalPeriodos { get; set; }

        public string ClaveNombre => Descripcion ?? string.Empty;
    }

    public class NomTipoPensionResponse
    {
        public int PkidTipoPension { get; set; }

        public int PkidNomTipoPension
        {
            get => PkidTipoPension;
            set => PkidTipoPension = value;
        }

        public string Descripcion { get; set; } = string.Empty;

        public int? UsuarioCreacion { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int? UsuarioModificacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => Descripcion ?? string.Empty;
    }
}

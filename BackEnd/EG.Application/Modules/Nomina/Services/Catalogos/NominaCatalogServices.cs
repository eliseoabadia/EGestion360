using EG.Business.Services;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Nomina
{
    public class NomEmpresaNominaAppService : NominaCrudAppService<Empresa, NomEmpresaNominaDto, NomEmpresaNominaResponse>
    {
        public NomEmpresaNominaAppService(GenericService<Empresa, NomEmpresaNominaDto, NomEmpresaNominaResponse> service)
            : base(service, "PkidEmpresa", "Empresa de nomina", (dto, id) => dto.PkidEmpresaNomina = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomUniversoAppService : NominaCrudAppService<Universo, NomUniversoDto, NomUniversoResponse>
    {
        public NomUniversoAppService(GenericService<Universo, NomUniversoDto, NomUniversoResponse> service)
            : base(service, "PkidUniverso", "Universo", (dto, id) => dto.PkidUniverso = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomNivelAppService : NominaCrudAppService<Nivel1, NomNivelDto, NomNivelResponse>
    {
        public NomNivelAppService(GenericService<Nivel1, NomNivelDto, NomNivelResponse> service)
            : base(service, "PkidNivel", "Nivel", (dto, id) => dto.PkidNivel = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidUniversoNomNavigation)
                .AddRelationFilter(nameof(Nivel1.FkidUniversoNomNavigation), new List<string> { nameof(Universo.Descripcion) });
        }
    }

    public class NomClasePuestoAppService : NominaCrudAppService<ClasePuesto, NomClasePuestoDto, NomClasePuestoResponse>
    {
        public NomClasePuestoAppService(GenericService<ClasePuesto, NomClasePuestoDto, NomClasePuestoResponse> service)
            : base(service, "PkidClasePuesto", "Clase de puesto", (dto, id) => dto.PkidClasePuesto = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomPuestoAppService : NominaCrudAppService<Puesto, NomPuestoDto, NomPuestoResponse>
    {
        public NomPuestoAppService(GenericService<Puesto, NomPuestoDto, NomPuestoResponse> service)
            : base(service, "PkidPuesto", "Puesto", (dto, id) => dto.PkidPuesto = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaSisNavigation)
                .AddInclude(x => x.FkidNivelNomNavigation)
                .AddInclude(x => x.FkidNivelNomNavigation.FkidUniversoNomNavigation)
                .AddInclude(x => x.FkidClasePuestoNomNavigation)
                .AddInclude(x => x.FkidPuestoPadreNomNavigation)
                .AddRelationFilter(nameof(Puesto.FkidEmpresaSisNavigation), new List<string> { nameof(Empresa.RazonSocial) })
                .AddRelationFilter(nameof(Puesto.FkidNivelNomNavigation), new List<string> { nameof(Nivel1.Clave) })
                .AddRelationFilter(nameof(Puesto.FkidClasePuestoNomNavigation), new List<string> { nameof(ClasePuesto.Descripcion) });
        }
    }

    public class NomNombramientoAppService : NominaCrudAppService<Nombramiento, NomNombramientoDto, NomNombramientoResponse>
    {
        public NomNombramientoAppService(GenericService<Nombramiento, NomNombramientoDto, NomNombramientoResponse> service)
            : base(service, "PkidNombramiento", "Nombramiento", (dto, id) => dto.PkidNombramiento = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomImporteNivelAppService : NominaCrudAppService<ImporteNivel, NomImporteNivelDto, NomImporteNivelResponse>
    {
        public NomImporteNivelAppService(GenericService<ImporteNivel, NomImporteNivelDto, NomImporteNivelResponse> service)
            : base(service, "PkidImporteNivel", "Importe por nivel", (dto, id) => dto.PkidImporteNivel = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomContratoLaboralAppService : NominaCrudAppService<ContratoLaboral, NomContratoLaboralDto, NomContratoLaboralResponse>
    {
        public NomContratoLaboralAppService(GenericService<ContratoLaboral, NomContratoLaboralDto, NomContratoLaboralResponse> service)
            : base(service, "PkidContratoLaboral", "Contrato laboral", (dto, id) => dto.PkidContratoLaboral = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaSisNavigation)
                .AddInclude(x => x.FkidPersonaNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation)
                .AddInclude(x => x.FkidNombramientoNomNavigation)
                .AddRelationFilter(nameof(ContratoLaboral.FkidEmpresaSisNavigation), new List<string> { nameof(Empresa.RazonSocial) })
                .AddRelationFilter(nameof(ContratoLaboral.FkidPuestoNomNavigation), new List<string> { nameof(Puesto.Nombre) })
                .AddRelationFilter(nameof(ContratoLaboral.FkidNombramientoNomNavigation), new List<string> { nameof(Nombramiento.Descripcion) });
        }
    }

    public class NomConceptoAppService : NominaCrudAppService<Concepto1, NomConceptoDto, NomConceptoResponse>
    {
        public NomConceptoAppService(GenericService<Concepto1, NomConceptoDto, NomConceptoResponse> service)
            : base(service, "PkidConcepto", "Concepto", (dto, id) => dto.PkidConcepto = id)
        {
        }
    }

    public class NomConceptoFactorAppService : NominaCrudAppService<ConceptoFactor, NomConceptoFactorDto, NomConceptoFactorResponse>
    {
        public NomConceptoFactorAppService(GenericService<ConceptoFactor, NomConceptoFactorDto, NomConceptoFactorResponse> service)
            : base(service, "PkidConceptoFactor", "Factor de concepto", (dto, id) => dto.PkidConceptoFactor = id)
        {
        }
    }

    public class NomConceptoFijoAppService : NominaCrudAppService<ConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse>
    {
        public NomConceptoFijoAppService(GenericService<ConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse> service)
            : base(service, "PkidConceptoFijo", "Concepto fijo", (dto, id) => dto.PkidConceptoFijo = id)
        {
            ConfigureConceptoPuestoService(service);
        }

        private static void ConfigureConceptoPuestoService(GenericService<ConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse> service)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaSisNavigation)
                .AddInclude(x => x.FkidConceptoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidNivelNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation)
                .AddRelationFilter(nameof(ConceptoFijo.FkidEmpresaSisNavigation), new List<string> { nameof(Empresa.RazonSocial) })
                .AddRelationFilter(nameof(ConceptoFijo.FkidConceptoNomNavigation), new List<string> { nameof(Concepto1.Nombre) })
                .AddRelationFilter(nameof(ConceptoFijo.FkidPuestoNomNavigation), new List<string> { nameof(Puesto.Nombre) });
        }
    }

    public class NomConceptoPorcentajeAppService : NominaCrudAppService<ConceptoPorcentaje, NomConceptoPorcentajeDto, NomConceptoPorcentajeResponse>
    {
        public NomConceptoPorcentajeAppService(GenericService<ConceptoPorcentaje, NomConceptoPorcentajeDto, NomConceptoPorcentajeResponse> service)
            : base(service, "PkidConceptoPorcentaje", "Concepto porcentaje", (dto, id) => dto.PkidConceptoPorcentaje = id)
        {
        }
    }

    public class NomConceptoProporcionalAppService : NominaCrudAppService<ConceptoProporcional, NomConceptoProporcionalDto, NomConceptoProporcionalResponse>
    {
        public NomConceptoProporcionalAppService(GenericService<ConceptoProporcional, NomConceptoProporcionalDto, NomConceptoProporcionalResponse> service)
            : base(service, "PkidConceptoProporcional", "Concepto proporcional", (dto, id) => dto.PkidConceptoProporcional = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaSisNavigation)
                .AddInclude(x => x.FkidConceptoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidNivelNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation)
                .AddRelationFilter(nameof(ConceptoProporcional.FkidEmpresaSisNavigation), new List<string> { nameof(Empresa.RazonSocial) })
                .AddRelationFilter(nameof(ConceptoProporcional.FkidConceptoNomNavigation), new List<string> { nameof(Concepto1.Nombre) })
                .AddRelationFilter(nameof(ConceptoProporcional.FkidPuestoNomNavigation), new List<string> { nameof(Puesto.Nombre) });
        }
    }

    public class NomConceptoTabularAppService : NominaCrudAppService<ConceptoTabular, NomConceptoTabularDto, NomConceptoTabularResponse>
    {
        public NomConceptoTabularAppService(GenericService<ConceptoTabular, NomConceptoTabularDto, NomConceptoTabularResponse> service)
            : base(service, "PkidConceptoTabulador", "Concepto tabular", (dto, id) => dto.PkidConceptoTabulador = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaSisNavigation)
                .AddInclude(x => x.FkidConceptoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidNivelNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation)
                .AddRelationFilter(nameof(ConceptoTabular.FkidEmpresaSisNavigation), new List<string> { nameof(Empresa.RazonSocial) })
                .AddRelationFilter(nameof(ConceptoTabular.FkidConceptoNomNavigation), new List<string> { nameof(Concepto1.Nombre) })
                .AddRelationFilter(nameof(ConceptoTabular.FkidPuestoNomNavigation), new List<string> { nameof(Puesto.Nombre) });
        }
    }

    public class NomConceptoVariableAppService : NominaCrudAppService<ConceptoVariable, NomConceptoVariableDto, NomConceptoVariableResponse>
    {
        public NomConceptoVariableAppService(GenericService<ConceptoVariable, NomConceptoVariableDto, NomConceptoVariableResponse> service)
            : base(service, "PkidConceptoVariable", "Concepto variable", (dto, id) => dto.PkidConceptoVariable = id)
        {
        }
    }

    public class NomContratoTercerosAppService : NominaCrudAppService<ContratoTercero, NomContratoTercerosDto, NomContratoTercerosResponse>
    {
        public NomContratoTercerosAppService(GenericService<ContratoTercero, NomContratoTercerosDto, NomContratoTercerosResponse> service)
            : base(service, "PkidContratoTercero", "Contrato de terceros", (dto, id) => dto.PkidContratoTercero = id)
        {
        }
    }

    public class NomCreditoAppService : NominaCrudAppService<Credito, NomCreditoDto, NomCreditoResponse>
    {
        public NomCreditoAppService(GenericService<Credito, NomCreditoDto, NomCreditoResponse> service)
            : base(service, "PkidCredito", "Credito", (dto, id) => dto.PkidCredito = id)
        {
        }
    }

    public class NomDescuentoCreditoAppService : NominaCrudAppService<DescuentoCredito, NomDescuentoCreditoDto, NomDescuentoCreditoResponse>
    {
        public NomDescuentoCreditoAppService(GenericService<DescuentoCredito, NomDescuentoCreditoDto, NomDescuentoCreditoResponse> service)
            : base(service, "PkidDescuentoCredito", "Descuento credito", (dto, id) => dto.PkidDescuentoCredito = id)
        {
        }
    }

    public class NomDescuentoInfonavitAppService : NominaCrudAppService<DescuentoInfonavit, NomDescuentoInfonavitDto, NomDescuentoInfonavitResponse>
    {
        public NomDescuentoInfonavitAppService(GenericService<DescuentoInfonavit, NomDescuentoInfonavitDto, NomDescuentoInfonavitResponse> service)
            : base(service, "PkidDescuentoInfonavit", "Descuento Infonavit", (dto, id) => dto.PkidDescuentoInfonavit = id)
        {
        }
    }

    public class NomEstatusPagoAppService : NominaCrudAppService<EstatusPago, NomEstatusPagoDto, NomEstatusPagoResponse>
    {
        public NomEstatusPagoAppService(GenericService<EstatusPago, NomEstatusPagoDto, NomEstatusPagoResponse> service)
            : base(service, "PkidEstatusPago", "Estatus de pago", (dto, id) => dto.PkidEstatusPago = id)
        {
        }
    }

    public class NomFactorIntAppService : NominaCrudAppService<FactorInt, NomFactorIntDto, NomFactorIntResponse>
    {
        public NomFactorIntAppService(GenericService<FactorInt, NomFactorIntDto, NomFactorIntResponse> service)
            : base(service, "PkidFactor", "Factor de integracion", (dto, id) => dto.PkidFactor = id)
        {
        }
    }

    public class NomInfonavitAppService : NominaCrudAppService<Infonavit, NomInfonavitDto, NomInfonavitResponse>
    {
        public NomInfonavitAppService(GenericService<Infonavit, NomInfonavitDto, NomInfonavitResponse> service)
            : base(service, "PkidInfonavit", "Infonavit", (dto, id) => dto.PkidInfonavit = id)
        {
        }
    }

    public class NomPeriodoActivoAppService : NominaCrudAppService<PeriodoActivo, NomPeriodoActivoDto, NomPeriodoActivoResponse>
    {
        public NomPeriodoActivoAppService(GenericService<PeriodoActivo, NomPeriodoActivoDto, NomPeriodoActivoResponse> service)
            : base(service, "PkidPeriodoActivo", "Periodo activo", (dto, id) => dto.PkidPeriodoActivo = id)
        {
        }
    }

    public class NomSalarioMinimoAppService : NominaCrudAppService<SalarioMinimo, NomSalarioMinimoDto, NomSalarioMinimoResponse>
    {
        public NomSalarioMinimoAppService(GenericService<SalarioMinimo, NomSalarioMinimoDto, NomSalarioMinimoResponse> service)
            : base(service, "PkidSalarioMinimo", "Salario minimo", (dto, id) => dto.PkidSalarioMinimo = id)
        {
        }
    }

    public class NomSueldoEspecialAppService : NominaCrudAppService<SueldoEspecial, NomSueldoEspecialDto, NomSueldoEspecialResponse>
    {
        public NomSueldoEspecialAppService(GenericService<SueldoEspecial, NomSueldoEspecialDto, NomSueldoEspecialResponse> service)
            : base(service, "PkidSueldoEspecial", "Sueldo especial", (dto, id) => dto.PkidSueldoEspecial = id)
        {
        }
    }

    public class NomSueldoLiqFinAppService : NominaCrudAppService<SueldoLiqFin, NomSueldoLiqFinDto, NomSueldoLiqFinResponse>
    {
        public NomSueldoLiqFinAppService(GenericService<SueldoLiqFin, NomSueldoLiqFinDto, NomSueldoLiqFinResponse> service)
            : base(service, "PkidSueldoLiqFin", "Sueldo liquidacion finiquito", (dto, id) => dto.PkidSueldoLiqFin = id)
        {
        }
    }

    public class NomSueldoMensualAppService : NominaCrudAppService<SueldoMensual, NomSueldoMensualDto, NomSueldoMensualResponse>
    {
        public NomSueldoMensualAppService(GenericService<SueldoMensual, NomSueldoMensualDto, NomSueldoMensualResponse> service)
            : base(service, "PkidSueldoMensual", "Sueldo mensual", (dto, id) => dto.PkidSueldoMensual = id)
        {
        }
    }

    public class NomSueldoQuincenalAppService : NominaCrudAppService<SueldoQuincenal, NomSueldoQuincenalDto, NomSueldoQuincenalResponse>
    {
        public NomSueldoQuincenalAppService(GenericService<SueldoQuincenal, NomSueldoQuincenalDto, NomSueldoQuincenalResponse> service)
            : base(service, "PkidSueldoQuincenal", "Sueldo quincenal", (dto, id) => dto.PkidSueldoQuincenal = id)
        {
        }
    }

    public class NomSueldoSemanalAppService : NominaCrudAppService<SueldoSemanal, NomSueldoSemanalDto, NomSueldoSemanalResponse>
    {
        public NomSueldoSemanalAppService(GenericService<SueldoSemanal, NomSueldoSemanalDto, NomSueldoSemanalResponse> service)
            : base(service, "PkidSueldoSemanal", "Sueldo semanal", (dto, id) => dto.PkidSueldoSemanal = id)
        {
        }
    }

    public class NomTipoIncapacidadAppService : NominaCrudAppService<TipoIncapacidad, NomTipoIncapacidadDto, NomTipoIncapacidadResponse>
    {
        public NomTipoIncapacidadAppService(GenericService<TipoIncapacidad, NomTipoIncapacidadDto, NomTipoIncapacidadResponse> service)
            : base(service, "PkidTipoIncapacidad", "Tipo de incapacidad", (dto, id) => dto.PkidTipoIncapacidad = id)
        {
        }
    }

    public class NomTipoPagoAppService : NominaCrudAppService<TipoPago, NomTipoPagoDto, NomTipoPagoResponse>
    {
        public NomTipoPagoAppService(GenericService<TipoPago, NomTipoPagoDto, NomTipoPagoResponse> service)
            : base(service, "PkidTipoPago", "Tipo de pago nomina", (dto, id) => dto.PkidTipoPago = id)
        {
        }
    }

    public class NomTipoPensionAppService : NominaCrudAppService<TipoPension, NomTipoPensionDto, NomTipoPensionResponse>
    {
        public NomTipoPensionAppService(GenericService<TipoPension, NomTipoPensionDto, NomTipoPensionResponse> service)
            : base(service, "PkidTipoPension", "Tipo de pension", (dto, id) => dto.PkidTipoPension = id)
        {
        }
    }

    public class NomCatalogoSimpleAppService : NominaCrudAppService<CatalogoSimple, NomCatalogoSimpleDto, NomCatalogoSimpleResponse>
    {
        public NomCatalogoSimpleAppService(GenericService<CatalogoSimple, NomCatalogoSimpleDto, NomCatalogoSimpleResponse> service)
            : base(service, "PkidCatalogoSimple", "Catalogo simple", (dto, id) => dto.PkidCatalogoSimple = id)
        {
            service.DisableEmpresaFilter();
        }
    }
}

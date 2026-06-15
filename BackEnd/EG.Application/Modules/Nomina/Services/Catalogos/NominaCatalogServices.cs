using EG.Business.Services;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Nomina
{
    public class NomEmpresaNominaAppService : NominaCrudAppService<NomEmpresaNomina, NomEmpresaNominaDto, NomEmpresaNominaResponse>
    {
        public NomEmpresaNominaAppService(GenericService<NomEmpresaNomina, NomEmpresaNominaDto, NomEmpresaNominaResponse> service)
            : base(service, "PkidEmpresaNomina", "Empresa de nomina", (dto, id) => dto.PkidEmpresaNomina = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomUniversoAppService : NominaCrudAppService<NomUniverso, NomUniversoDto, NomUniversoResponse>
    {
        public NomUniversoAppService(GenericService<NomUniverso, NomUniversoDto, NomUniversoResponse> service)
            : base(service, "PkidUniverso", "Universo", (dto, id) => dto.PkidUniverso = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomNivelAppService : NominaCrudAppService<NomNivel, NomNivelDto, NomNivelResponse>
    {
        public NomNivelAppService(GenericService<NomNivel, NomNivelDto, NomNivelResponse> service)
            : base(service, "PkidNivel", "Nivel", (dto, id) => dto.PkidNivel = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidUniversoNomNavigation)
                .AddRelationFilter(nameof(NomNivel.FkidUniversoNomNavigation), new List<string> { nameof(NomUniverso.Descripcion) });
        }
    }

    public class NomClasePuestoAppService : NominaCrudAppService<NomClasePuesto, NomClasePuestoDto, NomClasePuestoResponse>
    {
        public NomClasePuestoAppService(GenericService<NomClasePuesto, NomClasePuestoDto, NomClasePuestoResponse> service)
            : base(service, "PkidClasePuesto", "Clase de puesto", (dto, id) => dto.PkidClasePuesto = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomPuestoAppService : NominaCrudAppService<NomPuesto, NomPuestoDto, NomPuestoResponse>
    {
        public NomPuestoAppService(GenericService<NomPuesto, NomPuestoDto, NomPuestoResponse> service)
            : base(service, "PkidPuesto", "Puesto", (dto, id) => dto.PkidPuesto = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaNominaNomNavigation)
                .AddInclude(x => x.FkidNivelNomNavigation)
                .AddInclude(x => x.FkidNivelNomNavigation.FkidUniversoNomNavigation)
                .AddInclude(x => x.FkidClasePuestoNomNavigation)
                .AddInclude(x => x.FkidPuestoPadreNomNavigation)
                .AddRelationFilter(nameof(NomPuesto.FkidEmpresaNominaNomNavigation), new List<string> { nameof(NomEmpresaNomina.RazonSocial) })
                .AddRelationFilter(nameof(NomPuesto.FkidNivelNomNavigation), new List<string> { nameof(NomNivel.Clave) })
                .AddRelationFilter(nameof(NomPuesto.FkidClasePuestoNomNavigation), new List<string> { nameof(NomClasePuesto.Descripcion) });
        }
    }

    public class NomNombramientoAppService : NominaCrudAppService<NomNombramiento, NomNombramientoDto, NomNombramientoResponse>
    {
        public NomNombramientoAppService(GenericService<NomNombramiento, NomNombramientoDto, NomNombramientoResponse> service)
            : base(service, "PkidNombramiento", "Nombramiento", (dto, id) => dto.PkidNombramiento = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomImporteNivelAppService : NominaCrudAppService<NomImporteNivel, NomImporteNivelDto, NomImporteNivelResponse>
    {
        public NomImporteNivelAppService(GenericService<NomImporteNivel, NomImporteNivelDto, NomImporteNivelResponse> service)
            : base(service, "PkidImporteNivel", "Importe por nivel", (dto, id) => dto.PkidImporteNivel = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomContratoLaboralAppService : NominaCrudAppService<NomContratoLaboral, NomContratoLaboralDto, NomContratoLaboralResponse>
    {
        public NomContratoLaboralAppService(GenericService<NomContratoLaboral, NomContratoLaboralDto, NomContratoLaboralResponse> service)
            : base(service, "PkidContratoLaboral", "Contrato laboral", (dto, id) => dto.PkidContratoLaboral = id)
        {
            service
                .DisableEmpresaFilter()
                .AddInclude(x => x.FkidEmpresaNominaNomNavigation)
                .AddInclude(x => x.FkidPersonaNomNavigation)
                .AddInclude(x => x.FkidPuestoNomNavigation)
                .AddInclude(x => x.FkidNombramientoNomNavigation)
                .AddRelationFilter(nameof(NomContratoLaboral.FkidEmpresaNominaNomNavigation), new List<string> { nameof(NomEmpresaNomina.RazonSocial) })
                .AddRelationFilter(nameof(NomContratoLaboral.FkidPuestoNomNavigation), new List<string> { nameof(NomPuesto.Nombre) })
                .AddRelationFilter(nameof(NomContratoLaboral.FkidNombramientoNomNavigation), new List<string> { nameof(NomNombramiento.Descripcion) });
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
                .AddRelationFilter(nameof(ConceptoFijo.FkidEmpresaSisNavigation), new List<string> { nameof(NomEmpresaNomina.RazonSocial) })
                .AddRelationFilter(nameof(ConceptoFijo.FkidConceptoNomNavigation), new List<string> { nameof(Concepto1.Nombre) })
                .AddRelationFilter(nameof(ConceptoFijo.FkidPuestoNomNavigation), new List<string> { nameof(NomPuesto.Nombre) });
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
                .AddRelationFilter(nameof(ConceptoProporcional.FkidEmpresaSisNavigation), new List<string> { nameof(NomEmpresaNomina.RazonSocial) })
                .AddRelationFilter(nameof(ConceptoProporcional.FkidConceptoNomNavigation), new List<string> { nameof(Concepto1.Nombre) })
                .AddRelationFilter(nameof(ConceptoProporcional.FkidPuestoNomNavigation), new List<string> { nameof(NomPuesto.Nombre) });
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
                .AddRelationFilter(nameof(ConceptoTabular.FkidEmpresaSisNavigation), new List<string> { nameof(NomEmpresaNomina.RazonSocial) })
                .AddRelationFilter(nameof(ConceptoTabular.FkidConceptoNomNavigation), new List<string> { nameof(Concepto1.Nombre) })
                .AddRelationFilter(nameof(ConceptoTabular.FkidPuestoNomNavigation), new List<string> { nameof(NomPuesto.Nombre) });
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
}

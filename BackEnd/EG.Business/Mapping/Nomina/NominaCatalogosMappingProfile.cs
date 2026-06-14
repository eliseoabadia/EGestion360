using Mapster;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Nomina
{
    public class NominaCatalogosMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Concepto1, NomConceptoDto>().TwoWays();
            config.NewConfig<Concepto1, NomConceptoResponse>().TwoWays();
            config.NewConfig<NomConceptoResponse, NomConceptoDto>().TwoWays();

            config.NewConfig<ConceptoFactor, NomConceptoFactorDto>().TwoWays();
            config.NewConfig<ConceptoFactor, NomConceptoFactorResponse>().TwoWays();
            config.NewConfig<NomConceptoFactorResponse, NomConceptoFactorDto>().TwoWays();

            config.NewConfig<ConceptoFijo, NomConceptoFijoDto>().TwoWays();
            config.NewConfig<ConceptoFijo, NomConceptoFijoResponse>().TwoWays();
            config.NewConfig<NomConceptoFijoResponse, NomConceptoFijoDto>().TwoWays();

            config.NewConfig<ConceptoPorcentaje, NomConceptoPorcentajeDto>().TwoWays();
            config.NewConfig<ConceptoPorcentaje, NomConceptoPorcentajeResponse>().TwoWays();
            config.NewConfig<NomConceptoPorcentajeResponse, NomConceptoPorcentajeDto>().TwoWays();

            config.NewConfig<ConceptoProporcional, NomConceptoProporcionalDto>().TwoWays();
            config.NewConfig<ConceptoProporcional, NomConceptoProporcionalResponse>().TwoWays();
            config.NewConfig<NomConceptoProporcionalResponse, NomConceptoProporcionalDto>().TwoWays();

            config.NewConfig<ConceptoTabular, NomConceptoTabularDto>().TwoWays();
            config.NewConfig<ConceptoTabular, NomConceptoTabularResponse>().TwoWays();
            config.NewConfig<NomConceptoTabularResponse, NomConceptoTabularDto>().TwoWays();

            config.NewConfig<ConceptoVariable, NomConceptoVariableDto>().TwoWays();
            config.NewConfig<ConceptoVariable, NomConceptoVariableResponse>().TwoWays();
            config.NewConfig<NomConceptoVariableResponse, NomConceptoVariableDto>().TwoWays();

            config.NewConfig<ContratoTercero, NomContratoTercerosDto>().TwoWays();
            config.NewConfig<ContratoTercero, NomContratoTercerosResponse>().TwoWays();
            config.NewConfig<NomContratoTercerosResponse, NomContratoTercerosDto>().TwoWays();

            config.NewConfig<Credito, NomCreditoDto>().TwoWays();
            config.NewConfig<Credito, NomCreditoResponse>().TwoWays();
            config.NewConfig<NomCreditoResponse, NomCreditoDto>().TwoWays();

            config.NewConfig<DescuentoCredito, NomDescuentoCreditoDto>().TwoWays();
            config.NewConfig<DescuentoCredito, NomDescuentoCreditoResponse>().TwoWays();
            config.NewConfig<NomDescuentoCreditoResponse, NomDescuentoCreditoDto>().TwoWays();

            config.NewConfig<DescuentoInfonavit, NomDescuentoInfonavitDto>().TwoWays();
            config.NewConfig<DescuentoInfonavit, NomDescuentoInfonavitResponse>().TwoWays();
            config.NewConfig<NomDescuentoInfonavitResponse, NomDescuentoInfonavitDto>().TwoWays();

            config.NewConfig<EstatusPago, NomEstatusPagoDto>().TwoWays();
            config.NewConfig<EstatusPago, NomEstatusPagoResponse>().TwoWays();
            config.NewConfig<NomEstatusPagoResponse, NomEstatusPagoDto>().TwoWays();

            config.NewConfig<FactorInt, NomFactorIntDto>().TwoWays();
            config.NewConfig<FactorInt, NomFactorIntResponse>().TwoWays();
            config.NewConfig<NomFactorIntResponse, NomFactorIntDto>().TwoWays();

            config.NewConfig<Infonavit, NomInfonavitDto>().TwoWays();
            config.NewConfig<Infonavit, NomInfonavitResponse>().TwoWays();
            config.NewConfig<NomInfonavitResponse, NomInfonavitDto>().TwoWays();

            config.NewConfig<PeriodoActivo, NomPeriodoActivoDto>().TwoWays();
            config.NewConfig<PeriodoActivo, NomPeriodoActivoResponse>().TwoWays();
            config.NewConfig<NomPeriodoActivoResponse, NomPeriodoActivoDto>().TwoWays();

            config.NewConfig<SalarioMinimo, NomSalarioMinimoDto>().TwoWays();
            config.NewConfig<SalarioMinimo, NomSalarioMinimoResponse>().TwoWays();
            config.NewConfig<NomSalarioMinimoResponse, NomSalarioMinimoDto>().TwoWays();

            config.NewConfig<SueldoEspecial, NomSueldoEspecialDto>().TwoWays();
            config.NewConfig<SueldoEspecial, NomSueldoEspecialResponse>().TwoWays();
            config.NewConfig<NomSueldoEspecialResponse, NomSueldoEspecialDto>().TwoWays();

            config.NewConfig<SueldoLiqFin, NomSueldoLiqFinDto>().TwoWays();
            config.NewConfig<SueldoLiqFin, NomSueldoLiqFinResponse>().TwoWays();
            config.NewConfig<NomSueldoLiqFinResponse, NomSueldoLiqFinDto>().TwoWays();

            config.NewConfig<SueldoMensual, NomSueldoMensualDto>().TwoWays();
            config.NewConfig<SueldoMensual, NomSueldoMensualResponse>().TwoWays();
            config.NewConfig<NomSueldoMensualResponse, NomSueldoMensualDto>().TwoWays();

            config.NewConfig<SueldoQuincenal, NomSueldoQuincenalDto>().TwoWays();
            config.NewConfig<SueldoQuincenal, NomSueldoQuincenalResponse>().TwoWays();
            config.NewConfig<NomSueldoQuincenalResponse, NomSueldoQuincenalDto>().TwoWays();

            config.NewConfig<SueldoSemanal, NomSueldoSemanalDto>().TwoWays();
            config.NewConfig<SueldoSemanal, NomSueldoSemanalResponse>().TwoWays();
            config.NewConfig<NomSueldoSemanalResponse, NomSueldoSemanalDto>().TwoWays();

            config.NewConfig<TipoIncapacidad, NomTipoIncapacidadDto>().TwoWays();
            config.NewConfig<TipoIncapacidad, NomTipoIncapacidadResponse>().TwoWays();
            config.NewConfig<NomTipoIncapacidadResponse, NomTipoIncapacidadDto>().TwoWays();

            config.NewConfig<TipoPago, NomTipoPagoDto>().TwoWays();
            config.NewConfig<TipoPago, NomTipoPagoResponse>().TwoWays();
            config.NewConfig<NomTipoPagoResponse, NomTipoPagoDto>().TwoWays();

            config.NewConfig<TipoPension, NomTipoPensionDto>().TwoWays();
            config.NewConfig<TipoPension, NomTipoPensionResponse>().TwoWays();
            config.NewConfig<NomTipoPensionResponse, NomTipoPensionDto>().TwoWays();
        }
    }
}
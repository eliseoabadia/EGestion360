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
            config.NewConfig<NomEmpresaNomina, NomEmpresaNominaDto>().TwoWays();
            config.NewConfig<NomEmpresaNomina, NomEmpresaNominaResponse>().TwoWays();
            config.NewConfig<NomEmpresaNominaResponse, NomEmpresaNominaDto>().TwoWays();

            config.NewConfig<NomUniverso, NomUniversoDto>().TwoWays();
            config.NewConfig<NomUniverso, NomUniversoResponse>().TwoWays();
            config.NewConfig<NomUniversoResponse, NomUniversoDto>().TwoWays();

            config.NewConfig<NomNivel, NomNivelDto>().TwoWays();
            config.NewConfig<NomNivel, NomNivelResponse>()
                .Map(dest => dest.UniversoDescripcion, src => src.FkidUniversoNomNavigation != null ? src.FkidUniversoNomNavigation.Descripcion : string.Empty);
            config.NewConfig<NomNivelResponse, NomNivelDto>().TwoWays();

            config.NewConfig<NomClasePuesto, NomClasePuestoDto>().TwoWays();
            config.NewConfig<NomClasePuesto, NomClasePuestoResponse>().TwoWays();
            config.NewConfig<NomClasePuestoResponse, NomClasePuestoDto>().TwoWays();

            config.NewConfig<NomPuesto, NomPuestoDto>().TwoWays();
            config.NewConfig<NomPuesto, NomPuestoResponse>()
                .Map(dest => dest.PuestoPadreNombre, src => src.FkidPuestoPadreNomNavigation != null ? src.FkidPuestoPadreNomNavigation.Nombre : string.Empty)
                .Map(dest => dest.EmpresaNominaNombre, src => src.FkidEmpresaNominaNomNavigation != null ? src.FkidEmpresaNominaNomNavigation.RazonSocial : string.Empty)
                .Map(dest => dest.NivelClave, src => src.FkidNivelNomNavigation != null ? src.FkidNivelNomNavigation.Clave : string.Empty)
                .Map(dest => dest.UniversoDescripcion, src => src.FkidNivelNomNavigation != null && src.FkidNivelNomNavigation.FkidUniversoNomNavigation != null ? src.FkidNivelNomNavigation.FkidUniversoNomNavigation.Descripcion : string.Empty)
                .Map(dest => dest.ClasePuestoDescripcion, src => src.FkidClasePuestoNomNavigation != null ? src.FkidClasePuestoNomNavigation.Descripcion : string.Empty);
            config.NewConfig<NomPuestoResponse, NomPuestoDto>().TwoWays();

            config.NewConfig<NomNombramiento, NomNombramientoDto>().TwoWays();
            config.NewConfig<NomNombramiento, NomNombramientoResponse>().TwoWays();
            config.NewConfig<NomNombramientoResponse, NomNombramientoDto>().TwoWays();

            config.NewConfig<NomImporteNivel, NomImporteNivelDto>().TwoWays();
            config.NewConfig<NomImporteNivel, NomImporteNivelResponse>().TwoWays();
            config.NewConfig<NomImporteNivelResponse, NomImporteNivelDto>().TwoWays();

            config.NewConfig<NomContratoLaboral, NomContratoLaboralDto>().TwoWays();
            config.NewConfig<NomContratoLaboral, NomContratoLaboralResponse>()
                .Map(dest => dest.EmpresaNominaNombre, src => src.FkidEmpresaNominaNomNavigation != null ? src.FkidEmpresaNominaNomNavigation.RazonSocial : string.Empty)
                .Map(dest => dest.PersonaClaveNombre, src => src.FkidPersonaNomNavigation != null ? (src.FkidPersonaNomNavigation.Clave + " - " + src.FkidPersonaNomNavigation.Nombre + " " + src.FkidPersonaNomNavigation.Paterno + " " + src.FkidPersonaNomNavigation.Materno).Trim() : string.Empty)
                .Map(dest => dest.PuestoNombre, src => src.FkidPuestoNomNavigation != null ? src.FkidPuestoNomNavigation.Nombre : string.Empty)
                .Map(dest => dest.NombramientoDescripcion, src => src.FkidNombramientoNomNavigation != null ? src.FkidNombramientoNomNavigation.Descripcion : string.Empty);
            config.NewConfig<NomContratoLaboralResponse, NomContratoLaboralDto>().TwoWays();

            config.NewConfig<Concepto1, NomConceptoDto>().TwoWays();
            config.NewConfig<Concepto1, NomConceptoResponse>().TwoWays();
            config.NewConfig<NomConceptoResponse, NomConceptoDto>().TwoWays();

            config.NewConfig<ConceptoFactor, NomConceptoFactorDto>().TwoWays();
            config.NewConfig<ConceptoFactor, NomConceptoFactorResponse>().TwoWays();
            config.NewConfig<NomConceptoFactorResponse, NomConceptoFactorDto>().TwoWays();

            config.NewConfig<ConceptoFijo, NomConceptoFijoDto>().TwoWays();
            config.NewConfig<ConceptoFijo, NomConceptoFijoResponse>()
                .Map(dest => dest.EmpresaNominaNombre, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.RazonSocial : string.Empty)
                .Map(dest => dest.ConceptoClaveNombre, src => src.FkidConceptoNomNavigation != null ? (src.FkidConceptoNomNavigation.Clave + " - " + src.FkidConceptoNomNavigation.Nombre).Trim() : string.Empty)
                .Map(dest => dest.PuestoNombre, src => src.FkidPuestoNomNavigation != null ? src.FkidPuestoNomNavigation.Nombre : string.Empty)
                .Map(dest => dest.PuestoClaveNombre, src => src.FkidPuestoNomNavigation != null ? (src.FkidPuestoNomNavigation.PkidPuesto.ToString() + " - " + src.FkidPuestoNomNavigation.Nombre).Trim() : string.Empty)
                .Map(dest => dest.NivelClave, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation != null ? src.FkidPuestoNomNavigation.FkidNivelNomNavigation.Clave : string.Empty)
                .Map(dest => dest.UniversoDescripcion, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation != null ? src.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation.Descripcion : string.Empty)
                .Map(dest => dest.ClasePuestoDescripcion, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation != null ? src.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation.Descripcion : string.Empty);
            config.NewConfig<NomConceptoFijoResponse, NomConceptoFijoDto>().TwoWays();

            config.NewConfig<ConceptoPorcentaje, NomConceptoPorcentajeDto>().TwoWays();
            config.NewConfig<ConceptoPorcentaje, NomConceptoPorcentajeResponse>().TwoWays();
            config.NewConfig<NomConceptoPorcentajeResponse, NomConceptoPorcentajeDto>().TwoWays();

            config.NewConfig<ConceptoProporcional, NomConceptoProporcionalDto>().TwoWays();
            config.NewConfig<ConceptoProporcional, NomConceptoProporcionalResponse>()
                .Map(dest => dest.EmpresaNominaNombre, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.RazonSocial : string.Empty)
                .Map(dest => dest.ConceptoClaveNombre, src => src.FkidConceptoNomNavigation != null ? (src.FkidConceptoNomNavigation.Clave + " - " + src.FkidConceptoNomNavigation.Nombre).Trim() : string.Empty)
                .Map(dest => dest.PuestoNombre, src => src.FkidPuestoNomNavigation != null ? src.FkidPuestoNomNavigation.Nombre : string.Empty)
                .Map(dest => dest.PuestoClaveNombre, src => src.FkidPuestoNomNavigation != null ? (src.FkidPuestoNomNavigation.PkidPuesto.ToString() + " - " + src.FkidPuestoNomNavigation.Nombre).Trim() : string.Empty)
                .Map(dest => dest.NivelClave, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation != null ? src.FkidPuestoNomNavigation.FkidNivelNomNavigation.Clave : string.Empty)
                .Map(dest => dest.UniversoDescripcion, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation != null ? src.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation.Descripcion : string.Empty)
                .Map(dest => dest.ClasePuestoDescripcion, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation != null ? src.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation.Descripcion : string.Empty);
            config.NewConfig<NomConceptoProporcionalResponse, NomConceptoProporcionalDto>().TwoWays();

            config.NewConfig<ConceptoTabular, NomConceptoTabularDto>().TwoWays();
            config.NewConfig<ConceptoTabular, NomConceptoTabularResponse>()
                .Map(dest => dest.EmpresaNominaNombre, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.RazonSocial : string.Empty)
                .Map(dest => dest.ConceptoClaveNombre, src => src.FkidConceptoNomNavigation != null ? (src.FkidConceptoNomNavigation.Clave + " - " + src.FkidConceptoNomNavigation.Nombre).Trim() : string.Empty)
                .Map(dest => dest.PuestoNombre, src => src.FkidPuestoNomNavigation != null ? src.FkidPuestoNomNavigation.Nombre : string.Empty)
                .Map(dest => dest.PuestoClaveNombre, src => src.FkidPuestoNomNavigation != null ? (src.FkidPuestoNomNavigation.PkidPuesto.ToString() + " - " + src.FkidPuestoNomNavigation.Nombre).Trim() : string.Empty)
                .Map(dest => dest.NivelClave, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation != null ? src.FkidPuestoNomNavigation.FkidNivelNomNavigation.Clave : string.Empty)
                .Map(dest => dest.UniversoDescripcion, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation != null && src.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation != null ? src.FkidPuestoNomNavigation.FkidNivelNomNavigation.FkidUniversoNomNavigation.Descripcion : string.Empty)
                .Map(dest => dest.ClasePuestoDescripcion, src => src.FkidPuestoNomNavigation != null && src.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation != null ? src.FkidPuestoNomNavigation.FkidClasePuestoNomNavigation.Descripcion : string.Empty);
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

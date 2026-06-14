using EG.Application.Interfaces.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Modules.Nomina.Catalogos
{
    [Route("api/NomConcepto")]
    public class NomConceptoController : NominaCatalogControllerBase<NomConceptoResponse>
    {
        public NomConceptoController(
            INominaCrudAppService<NomConceptoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Concepto")
        {
        }
    }

    [Route("api/NomConceptoFactor")]
    public class NomConceptoFactorController : NominaCatalogControllerBase<NomConceptoFactorResponse>
    {
        public NomConceptoFactorController(
            INominaCrudAppService<NomConceptoFactorResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Factor de concepto")
        {
        }
    }

    [Route("api/NomConceptoFijo")]
    public class NomConceptoFijoController : NominaCatalogControllerBase<NomConceptoFijoResponse>
    {
        public NomConceptoFijoController(
            INominaCrudAppService<NomConceptoFijoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Concepto fijo")
        {
        }
    }

    [Route("api/NomConceptoPorcentaje")]
    public class NomConceptoPorcentajeController : NominaCatalogControllerBase<NomConceptoPorcentajeResponse>
    {
        public NomConceptoPorcentajeController(
            INominaCrudAppService<NomConceptoPorcentajeResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Concepto porcentaje")
        {
        }
    }

    [Route("api/NomConceptoProporcional")]
    public class NomConceptoProporcionalController : NominaCatalogControllerBase<NomConceptoProporcionalResponse>
    {
        public NomConceptoProporcionalController(
            INominaCrudAppService<NomConceptoProporcionalResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Concepto proporcional")
        {
        }
    }

    [Route("api/NomConceptoTabular")]
    public class NomConceptoTabularController : NominaCatalogControllerBase<NomConceptoTabularResponse>
    {
        public NomConceptoTabularController(
            INominaCrudAppService<NomConceptoTabularResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Concepto tabular")
        {
        }
    }

    [Route("api/NomConceptoVariable")]
    public class NomConceptoVariableController : NominaCatalogControllerBase<NomConceptoVariableResponse>
    {
        public NomConceptoVariableController(
            INominaCrudAppService<NomConceptoVariableResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Concepto variable")
        {
        }
    }

    [Route("api/NomContratoTerceros")]
    public class NomContratoTercerosController : NominaCatalogControllerBase<NomContratoTercerosResponse>
    {
        public NomContratoTercerosController(
            INominaCrudAppService<NomContratoTercerosResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Contrato de terceros")
        {
        }
    }

    [Route("api/NomCredito")]
    public class NomCreditoController : NominaCatalogControllerBase<NomCreditoResponse>
    {
        public NomCreditoController(
            INominaCrudAppService<NomCreditoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Credito")
        {
        }
    }

    [Route("api/NomDescuentoCredito")]
    public class NomDescuentoCreditoController : NominaCatalogControllerBase<NomDescuentoCreditoResponse>
    {
        public NomDescuentoCreditoController(
            INominaCrudAppService<NomDescuentoCreditoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Descuento credito")
        {
        }
    }

    [Route("api/NomDescuentoInfonavit")]
    public class NomDescuentoInfonavitController : NominaCatalogControllerBase<NomDescuentoInfonavitResponse>
    {
        public NomDescuentoInfonavitController(
            INominaCrudAppService<NomDescuentoInfonavitResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Descuento Infonavit")
        {
        }
    }

    [Route("api/NomEstatusPago")]
    public class NomEstatusPagoController : NominaCatalogControllerBase<NomEstatusPagoResponse>
    {
        public NomEstatusPagoController(
            INominaCrudAppService<NomEstatusPagoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Estatus de pago")
        {
        }
    }

    [Route("api/NomFactorInt")]
    public class NomFactorIntController : NominaCatalogControllerBase<NomFactorIntResponse>
    {
        public NomFactorIntController(
            INominaCrudAppService<NomFactorIntResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Factor de integracion")
        {
        }
    }

    [Route("api/NomInfonavit")]
    public class NomInfonavitController : NominaCatalogControllerBase<NomInfonavitResponse>
    {
        public NomInfonavitController(
            INominaCrudAppService<NomInfonavitResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Infonavit")
        {
        }
    }

    [Route("api/NomPeriodoActivo")]
    public class NomPeriodoActivoController : NominaCatalogControllerBase<NomPeriodoActivoResponse>
    {
        public NomPeriodoActivoController(
            INominaCrudAppService<NomPeriodoActivoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Periodo activo")
        {
        }
    }

    [Route("api/NomSalarioMinimo")]
    public class NomSalarioMinimoController : NominaCatalogControllerBase<NomSalarioMinimoResponse>
    {
        public NomSalarioMinimoController(
            INominaCrudAppService<NomSalarioMinimoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Salario minimo")
        {
        }
    }

    [Route("api/NomSueldoEspecial")]
    public class NomSueldoEspecialController : NominaCatalogControllerBase<NomSueldoEspecialResponse>
    {
        public NomSueldoEspecialController(
            INominaCrudAppService<NomSueldoEspecialResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Sueldo especial")
        {
        }
    }

    [Route("api/NomSueldoLiqFin")]
    public class NomSueldoLiqFinController : NominaCatalogControllerBase<NomSueldoLiqFinResponse>
    {
        public NomSueldoLiqFinController(
            INominaCrudAppService<NomSueldoLiqFinResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Sueldo liquidacion finiquito")
        {
        }
    }

    [Route("api/NomSueldoMensual")]
    public class NomSueldoMensualController : NominaCatalogControllerBase<NomSueldoMensualResponse>
    {
        public NomSueldoMensualController(
            INominaCrudAppService<NomSueldoMensualResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Sueldo mensual")
        {
        }
    }

    [Route("api/NomSueldoQuincenal")]
    public class NomSueldoQuincenalController : NominaCatalogControllerBase<NomSueldoQuincenalResponse>
    {
        public NomSueldoQuincenalController(
            INominaCrudAppService<NomSueldoQuincenalResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Sueldo quincenal")
        {
        }
    }

    [Route("api/NomSueldoSemanal")]
    public class NomSueldoSemanalController : NominaCatalogControllerBase<NomSueldoSemanalResponse>
    {
        public NomSueldoSemanalController(
            INominaCrudAppService<NomSueldoSemanalResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Sueldo semanal")
        {
        }
    }

    [Route("api/NomTipoIncapacidad")]
    public class NomTipoIncapacidadController : NominaCatalogControllerBase<NomTipoIncapacidadResponse>
    {
        public NomTipoIncapacidadController(
            INominaCrudAppService<NomTipoIncapacidadResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Tipo de incapacidad")
        {
        }
    }

    [Route("api/NomTipoPago")]
    public class NomTipoPagoController : NominaCatalogControllerBase<NomTipoPagoResponse>
    {
        public NomTipoPagoController(
            INominaCrudAppService<NomTipoPagoResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Tipo de pago nomina")
        {
        }
    }

    [Route("api/NomTipoPension")]
    public class NomTipoPensionController : NominaCatalogControllerBase<NomTipoPensionResponse>
    {
        public NomTipoPensionController(
            INominaCrudAppService<NomTipoPensionResponse> appService,
            IUserContextService userContext)
            : base(appService, userContext, "Tipo de pension")
        {
        }
    }
}
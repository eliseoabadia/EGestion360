using EG.Business.Services;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

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

    public class NomPlazaAutorizadaAppService : NominaCrudAppService<PlazaAutorizadum, NomPlazaAutorizadaDto, NomPlazaAutorizadaResponse>
    {
        private readonly GenericService<VwPlazaAutorizadum, NomPlazaAutorizadaDto, NomPlazaAutorizadaResponse> _readService;
        private readonly EGestionContext _context;

        public NomPlazaAutorizadaAppService(
            GenericService<PlazaAutorizadum, NomPlazaAutorizadaDto, NomPlazaAutorizadaResponse> service,
            GenericService<VwPlazaAutorizadum, NomPlazaAutorizadaDto, NomPlazaAutorizadaResponse> readService,
            EGestionContext context)
            : base(service, "PkidPlazaAutorizada", "Plaza autorizada", (dto, id) => dto.PkidPlazaAutorizada = id)
        {
            _readService = readService;
            _context = context;
            service.AddInclude(x => x.FkidEmpresaSisNavigation);
        }

        public override async Task<PagedResult<NomPlazaAutorizadaResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Plazas autorizadas obtenidas correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomPlazaAutorizadaResponse>(UserFacingMessages.OperationFailed("obtener plazas autorizadas"));
            }
        }

        public override async Task<PagedResult<NomPlazaAutorizadaResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidPlazaAutorizada");
                return item == null
                    ? Failure<NomPlazaAutorizadaResponse>($"Plaza autorizada con ID {id} no encontrada", "NOT_FOUND")
                    : Success("Plaza autorizada encontrada", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomPlazaAutorizadaResponse>(UserFacingMessages.OperationFailed("obtener la plaza autorizada"));
            }
        }

        public override async Task<PagedResult<NomPlazaAutorizadaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(request);
                result.Message = result.Success
                    ? "Plazas autorizadas obtenidas correctamente"
                    : UserFacingMessages.OperationFailed("obtener plazas autorizadas");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomPlazaAutorizadaResponse>(UserFacingMessages.OperationFailed("obtener plazas autorizadas"));
            }
        }

        public override async Task<PagedResult<NomPlazaAutorizadaResponse>> CreateAsync(NomPlazaAutorizadaResponse response, int usuarioActual)
        {
            if (response.PkidPlazaAutorizada <= 0)
            {
                response.PkidPlazaAutorizada = (await _context.PlazaAutorizada
                    .MaxAsync(x => (int?)x.PkidPlazaAutorizada) ?? 0) + 1;
            }

            return await base.CreateAsync(response, usuarioActual);
        }

        private static PagedResult<NomPlazaAutorizadaResponse> Success(
            string message,
            NomPlazaAutorizadaResponse? data,
            IList<NomPlazaAutorizadaResponse> items,
            int totalCount) => new()
        {
            Success = true,
            Message = message,
            Code = "SUCCESS",
            Data = data,
            Items = items,
            TotalCount = totalCount
        };
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
        private readonly GenericService<VwConceptoVariable, NomConceptoVariableDto, NomConceptoVariableResponse> _readService;

        public NomConceptoVariableAppService(
            GenericService<ConceptoVariable, NomConceptoVariableDto, NomConceptoVariableResponse> service,
            GenericService<VwConceptoVariable, NomConceptoVariableDto, NomConceptoVariableResponse> readService)
            : base(service, "PkidConceptoVariable", "Concepto variable", (dto, id) => dto.PkidConceptoVariable = id)
        {
            _readService = readService;
        }

        public override async Task<PagedResult<NomConceptoVariableResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Conceptos variables obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoVariableResponse>(UserFacingMessages.OperationFailed("obtener conceptos variables"));
            }
        }

        public override async Task<PagedResult<NomConceptoVariableResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidConceptoVariable");
                return item == null
                    ? Failure<NomConceptoVariableResponse>($"Concepto variable con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Concepto variable encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoVariableResponse>(UserFacingMessages.OperationFailed("obtener el concepto variable"));
            }
        }

        public override async Task<PagedResult<NomConceptoVariableResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(request);
                result.Message = result.Success
                    ? "Conceptos variables obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener conceptos variables");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoVariableResponse>(UserFacingMessages.OperationFailed("obtener conceptos variables"));
            }
        }

        private static PagedResult<NomConceptoVariableResponse> Success(
            string message,
            NomConceptoVariableResponse? data,
            IList<NomConceptoVariableResponse> items,
            int totalCount) => new()
        {
            Success = true,
            Message = message,
            Code = "SUCCESS",
            Data = data,
            Items = items,
            TotalCount = totalCount
        };
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

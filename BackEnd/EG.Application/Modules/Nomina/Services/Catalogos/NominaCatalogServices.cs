using EG.Business.Services;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;
using Mapster;
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
        private static readonly IReadOnlyDictionary<int, string> FormaCalculoFallback = new Dictionary<int, string>
        {
            [1] = "Concepto proporción de otros conceptos",
            [2] = "Conceptos de Importe Fijo",
            [3] = "Concepto Variable",
            [4] = "Deducción ISR",
            [5] = "Aportaciones al IMSS",
            [6] = "Deducción Importe Fijo",
            [7] = "Deducción Variable",
            [8] = "Aguinaldo",
            [9] = "Descuento por pago a terceros",
            [10] = "Conceptos que aplican un Tabulador",
            [12] = "Aportaciones al fondo de vivienda del INFONAVIT",
            [13] = "Conceptos ISSSTE"
        };

        private readonly GenericService<VwNomConcepto, NomConceptoDto, NomConceptoResponse> _readService;
        private readonly EGestionContext _context;

        public NomConceptoAppService(
            GenericService<Concepto1, NomConceptoDto, NomConceptoResponse> service,
            GenericService<VwNomConcepto, NomConceptoDto, NomConceptoResponse> readService,
            EGestionContext context)
            : base(service, "PkidConcepto", "Concepto", (dto, id) => dto.PkidConcepto = id)
        {
            _readService = readService;
            _context = context;
            readService.DisableEmpresaFilter();
        }

        public override async Task<PagedResult<NomConceptoResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                await SetFormaCalculoDescriptionsAsync(items);
                return Success("Conceptos obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoResponse>(UserFacingMessages.OperationFailed("obtener conceptos"));
            }
        }

        public override async Task<PagedResult<NomConceptoResponse>> GetByIdAsync(int id)
        {
            try
            {
                var viewItem = await _context.VwNomConceptos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(item => item.PkidConcepto == id);

                if (viewItem == null)
                {
                    return Failure<NomConceptoResponse>($"Concepto con ID {id} no encontrado", "NOT_FOUND");
                }

                var item = viewItem.Adapt<NomConceptoResponse>();
                await SetFormaCalculoDescriptionsAsync([item]);
                return Success("Concepto encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoResponse>(UserFacingMessages.OperationFailed("obtener el concepto"));
            }
        }

        public override async Task<PagedResult<NomConceptoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(MapViewRequest(request));
                if (result.Items != null)
                {
                    await SetFormaCalculoDescriptionsAsync(result.Items);
                }

                result.Message = result.Success
                    ? "Conceptos obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener conceptos");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoResponse>(UserFacingMessages.OperationFailed("obtener conceptos"));
            }
        }

        private async Task SetFormaCalculoDescriptionsAsync(IList<NomConceptoResponse> items)
        {
            var ids = items
                .Select(item => item.FkidFormaCalculoNom)
                .Where(id => id > 0)
                .Distinct()
                .ToList();

            if (ids.Count == 0)
            {
                return;
            }

            var descriptions = await _context.CatalogoSimples
                .AsNoTracking()
                .Where(item => item.Catalogo == "Forma_Calculo" && item.LegacyId.HasValue && ids.Contains(item.LegacyId.Value))
                .Select(item => new { Id = item.LegacyId!.Value, item.Descripcion })
                .ToDictionaryAsync(item => item.Id, item => item.Descripcion);

            foreach (var item in items)
            {
                item.FormaCalculoDescripcion = descriptions.TryGetValue(item.FkidFormaCalculoNom, out var description)
                    ? description
                    : FormaCalculoFallback.GetValueOrDefault(item.FkidFormaCalculoNom, item.FkidFormaCalculoNom.ToString());
            }
        }

        private static PagedRequest MapViewRequest(PagedRequest request)
            => NominaCatalogRequestMapper.MapPagedRequest(request, new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                [nameof(NomConceptoResponse.FkidFormaCalculoNom)] = nameof(VwNomConcepto.FormaCalculoId),
                [nameof(NomConceptoResponse.FormaCalculoDescripcion)] = nameof(VwNomConcepto.FormaCalculoId)
            });

        private static PagedResult<NomConceptoResponse> Success(
            string message,
            NomConceptoResponse? data,
            IList<NomConceptoResponse> items,
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

    public class NomConceptoFactorAppService : NominaCrudAppService<ConceptoFactor, NomConceptoFactorDto, NomConceptoFactorResponse>
    {
        private readonly GenericService<VwConceptoFactor, NomConceptoFactorDto, NomConceptoFactorResponse> _readService;

        public NomConceptoFactorAppService(
            GenericService<ConceptoFactor, NomConceptoFactorDto, NomConceptoFactorResponse> service,
            GenericService<VwConceptoFactor, NomConceptoFactorDto, NomConceptoFactorResponse> readService)
            : base(service, "PkidConceptoFactor", "Factor de concepto", (dto, id) => dto.PkidConceptoFactor = id)
        {
            _readService = readService;
        }

        public override async Task<PagedResult<NomConceptoFactorResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Factores de concepto obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoFactorResponse>(UserFacingMessages.OperationFailed("obtener factores de concepto"));
            }
        }

        public override async Task<PagedResult<NomConceptoFactorResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidConceptoFactor");
                return item == null
                    ? Failure<NomConceptoFactorResponse>($"Factor de concepto con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Factor de concepto encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoFactorResponse>(UserFacingMessages.OperationFailed("obtener el factor de concepto"));
            }
        }

        public override async Task<PagedResult<NomConceptoFactorResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(MapViewRequest(request));
                result.Message = result.Success
                    ? "Factores de concepto obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener factores de concepto");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoFactorResponse>(UserFacingMessages.OperationFailed("obtener factores de concepto"));
            }
        }

        private static PagedRequest MapViewRequest(PagedRequest request)
            => NominaCatalogRequestMapper.MapPagedRequest(request, new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                [nameof(NomConceptoFactorResponse.FkidConceptoNom)] = nameof(VwConceptoFactor.ConceptoId)
            });

        private static PagedResult<NomConceptoFactorResponse> Success(
            string message,
            NomConceptoFactorResponse? data,
            IList<NomConceptoFactorResponse> items,
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

    public class NomConceptoFijoAppService : NominaCrudAppService<ConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse>
    {
        private readonly GenericService<VwConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse> _readService;

        public NomConceptoFijoAppService(
            GenericService<ConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse> service,
            GenericService<VwConceptoFijo, NomConceptoFijoDto, NomConceptoFijoResponse> readService)
            : base(service, "PkidConceptoFijo", "Concepto fijo", (dto, id) => dto.PkidConceptoFijo = id)
        {
            _readService = readService;
            ConfigureConceptoPuestoService(service);
        }

        public override async Task<PagedResult<NomConceptoFijoResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Conceptos fijos obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoFijoResponse>(UserFacingMessages.OperationFailed("obtener conceptos fijos"));
            }
        }

        public override async Task<PagedResult<NomConceptoFijoResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidConceptoFijo");
                return item == null
                    ? Failure<NomConceptoFijoResponse>($"Concepto fijo con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Concepto fijo encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoFijoResponse>(UserFacingMessages.OperationFailed("obtener el concepto fijo"));
            }
        }

        public override async Task<PagedResult<NomConceptoFijoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(request);
                result.Message = result.Success
                    ? "Conceptos fijos obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener conceptos fijos");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoFijoResponse>(UserFacingMessages.OperationFailed("obtener conceptos fijos"));
            }
        }

        private static PagedResult<NomConceptoFijoResponse> Success(
            string message,
            NomConceptoFijoResponse? data,
            IList<NomConceptoFijoResponse> items,
            int totalCount) => new()
        {
            Success = true,
            Message = message,
            Code = "SUCCESS",
            Data = data,
            Items = items,
            TotalCount = totalCount
        };

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
        private readonly GenericService<VwConceptoPorcentaje, NomConceptoPorcentajeDto, NomConceptoPorcentajeResponse> _readService;

        public NomConceptoPorcentajeAppService(
            GenericService<ConceptoPorcentaje, NomConceptoPorcentajeDto, NomConceptoPorcentajeResponse> service,
            GenericService<VwConceptoPorcentaje, NomConceptoPorcentajeDto, NomConceptoPorcentajeResponse> readService)
            : base(service, "PkidConceptoPorcentaje", "Concepto porcentaje", (dto, id) => dto.PkidConceptoPorcentaje = id)
        {
            _readService = readService;
        }

        public override async Task<PagedResult<NomConceptoPorcentajeResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Conceptos porcentaje obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoPorcentajeResponse>(UserFacingMessages.OperationFailed("obtener conceptos porcentaje"));
            }
        }

        public override async Task<PagedResult<NomConceptoPorcentajeResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidConceptoPorcentaje");
                return item == null
                    ? Failure<NomConceptoPorcentajeResponse>($"Concepto porcentaje con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Concepto porcentaje encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoPorcentajeResponse>(UserFacingMessages.OperationFailed("obtener el concepto porcentaje"));
            }
        }

        public override async Task<PagedResult<NomConceptoPorcentajeResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(MapViewRequest(request));
                result.Message = result.Success
                    ? "Conceptos porcentaje obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener conceptos porcentaje");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoPorcentajeResponse>(UserFacingMessages.OperationFailed("obtener conceptos porcentaje"));
            }
        }

        private static PagedRequest MapViewRequest(PagedRequest request)
            => NominaCatalogRequestMapper.MapPagedRequest(request, new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                [nameof(NomConceptoPorcentajeResponse.FkidConceptoNom)] = nameof(VwConceptoPorcentaje.ConceptoId),
                [nameof(NomConceptoPorcentajeResponse.FkidConceptoProporcionalNom)] = nameof(VwConceptoPorcentaje.ConceptoProporcionalId)
            });

        private static PagedResult<NomConceptoPorcentajeResponse> Success(
            string message,
            NomConceptoPorcentajeResponse? data,
            IList<NomConceptoPorcentajeResponse> items,
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

    public class NomConceptoProporcionalAppService : NominaCrudAppService<ConceptoProporcional, NomConceptoProporcionalDto, NomConceptoProporcionalResponse>
    {
        private readonly GenericService<VwConceptoProporcional, NomConceptoProporcionalDto, NomConceptoProporcionalResponse> _readService;

        public NomConceptoProporcionalAppService(
            GenericService<ConceptoProporcional, NomConceptoProporcionalDto, NomConceptoProporcionalResponse> service,
            GenericService<VwConceptoProporcional, NomConceptoProporcionalDto, NomConceptoProporcionalResponse> readService)
            : base(service, "PkidConceptoProporcional", "Concepto proporcional", (dto, id) => dto.PkidConceptoProporcional = id)
        {
            _readService = readService;
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

        public override async Task<PagedResult<NomConceptoProporcionalResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Conceptos proporcionales obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoProporcionalResponse>(UserFacingMessages.OperationFailed("obtener conceptos proporcionales"));
            }
        }

        public override async Task<PagedResult<NomConceptoProporcionalResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidConceptoProporcional");
                return item == null
                    ? Failure<NomConceptoProporcionalResponse>($"Concepto proporcional con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Concepto proporcional encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoProporcionalResponse>(UserFacingMessages.OperationFailed("obtener el concepto proporcional"));
            }
        }

        public override async Task<PagedResult<NomConceptoProporcionalResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(request);
                result.Message = result.Success
                    ? "Conceptos proporcionales obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener conceptos proporcionales");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoProporcionalResponse>(UserFacingMessages.OperationFailed("obtener conceptos proporcionales"));
            }
        }

        private static PagedResult<NomConceptoProporcionalResponse> Success(
            string message,
            NomConceptoProporcionalResponse? data,
            IList<NomConceptoProporcionalResponse> items,
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

    public class NomConceptoTabularAppService : NominaCrudAppService<ConceptoTabular, NomConceptoTabularDto, NomConceptoTabularResponse>
    {
        private readonly GenericService<VwConceptoTabular, NomConceptoTabularDto, NomConceptoTabularResponse> _readService;

        public NomConceptoTabularAppService(
            GenericService<ConceptoTabular, NomConceptoTabularDto, NomConceptoTabularResponse> service,
            GenericService<VwConceptoTabular, NomConceptoTabularDto, NomConceptoTabularResponse> readService)
            : base(service, "PkidConceptoTabulador", "Concepto tabular", (dto, id) => dto.PkidConceptoTabulador = id)
        {
            _readService = readService;
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

        public override async Task<PagedResult<NomConceptoTabularResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Conceptos tabulares obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomConceptoTabularResponse>(UserFacingMessages.OperationFailed("obtener conceptos tabulares"));
            }
        }

        public override async Task<PagedResult<NomConceptoTabularResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidConceptoTabulador");
                return item == null
                    ? Failure<NomConceptoTabularResponse>($"Concepto tabular con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Concepto tabular encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomConceptoTabularResponse>(UserFacingMessages.OperationFailed("obtener el concepto tabular"));
            }
        }

        public override async Task<PagedResult<NomConceptoTabularResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(request);
                result.Message = result.Success
                    ? "Conceptos tabulares obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener conceptos tabulares");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomConceptoTabularResponse>(UserFacingMessages.OperationFailed("obtener conceptos tabulares"));
            }
        }

        private static PagedResult<NomConceptoTabularResponse> Success(
            string message,
            NomConceptoTabularResponse? data,
            IList<NomConceptoTabularResponse> items,
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

    public class NomTablaFiscalAppService : NominaCrudAppService<TablaFiscal, NomTablaFiscalDto, NomTablaFiscalResponse>
    {
        private readonly EGestionContext _context;

        public NomTablaFiscalAppService(
            GenericService<TablaFiscal, NomTablaFiscalDto, NomTablaFiscalResponse> service,
            EGestionContext context)
            : base(service, "PkidTablaFiscal", "Tabla fiscal", (dto, id) => dto.PkidTablaFiscal = id)
        {
            _context = context;
            service.DisableEmpresaFilter();
        }

        public override async Task<PagedResult<NomTablaFiscalResponse>> CreateAsync(NomTablaFiscalResponse response, int usuarioActual)
        {
            if (string.IsNullOrWhiteSpace(response.LegacyTable))
            {
                response.LegacyTable = "EGestion360";
            }

            if (response.LegacyId is not > 0)
            {
                response.LegacyId = (await _context.TablaFiscals
                    .Where(item => item.LegacyTable == response.LegacyTable)
                    .MaxAsync(item => (int?)item.LegacyId) ?? 0) + 1;
            }

            return await base.CreateAsync(response, usuarioActual);
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
        private readonly GenericService<VwCatalogoSimple, NomCatalogoSimpleDto, NomCatalogoSimpleResponse> _readService;

        public NomCatalogoSimpleAppService(
            GenericService<CatalogoSimple, NomCatalogoSimpleDto, NomCatalogoSimpleResponse> service,
            GenericService<VwCatalogoSimple, NomCatalogoSimpleDto, NomCatalogoSimpleResponse> readService)
            : base(service, "PkidCatalogoSimple", "Catalogo simple", (dto, id) => dto.PkidCatalogoSimple = id)
        {
            _readService = readService;
            service.DisableEmpresaFilter();
            readService.DisableEmpresaFilter();
        }

        public override async Task<PagedResult<NomCatalogoSimpleResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _readService.GetAllAsync()).ToList();
                return Success("Catalogos simples obtenidos correctamente", items.FirstOrDefault(), items, items.Count);
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<NomCatalogoSimpleResponse>(UserFacingMessages.OperationFailed("obtener catalogos simples"));
            }
        }

        public override async Task<PagedResult<NomCatalogoSimpleResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _readService.GetByIdAsync(id, idPropertyName: "PkidCatalogoSimple");
                return item == null
                    ? Failure<NomCatalogoSimpleResponse>($"Catalogo simple con ID {id} no encontrado", "NOT_FOUND")
                    : Success("Catalogo simple encontrado", item, [item], 1);
            }
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<NomCatalogoSimpleResponse>(UserFacingMessages.OperationFailed("obtener el catalogo simple"));
            }
        }

        public override async Task<PagedResult<NomCatalogoSimpleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _readService.GetAllPaginadoAsync(request);
                result.Message = result.Success
                    ? "Catalogos simples obtenidos correctamente"
                    : UserFacingMessages.OperationFailed("obtener catalogos simples");
                result.Code = result.Success ? "SUCCESS" : "ERROR";
                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<NomCatalogoSimpleResponse>(UserFacingMessages.OperationFailed("obtener catalogos simples"));
            }
        }

        private static PagedResult<NomCatalogoSimpleResponse> Success(
            string message,
            NomCatalogoSimpleResponse? data,
            IList<NomCatalogoSimpleResponse> items,
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

    public class NomEstadoCivilAppService : NominaCrudAppService<SisEstadoCivil, NomEstadoCivilDto, NomEstadoCivilResponse>
    {
        public NomEstadoCivilAppService(GenericService<SisEstadoCivil, NomEstadoCivilDto, NomEstadoCivilResponse> service)
            : base(service, "PkIdEstadoCivil", "Estado civil", (dto, id) => dto.PkidEstadoCivil = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomEscolaridadAppService : NominaCrudAppService<Escolaridad, NomEscolaridadDto, NomEscolaridadResponse>
    {
        public NomEscolaridadAppService(GenericService<Escolaridad, NomEscolaridadDto, NomEscolaridadResponse> service)
            : base(service, "PkidEscolaridad", "Escolaridad", (dto, id) => dto.PkidEscolaridad = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomDiaSemanaAppService : NominaCrudAppService<DiaSemana, NomDiaSemanaDto, NomDiaSemanaResponse>
    {
        public NomDiaSemanaAppService(GenericService<DiaSemana, NomDiaSemanaDto, NomDiaSemanaResponse> service)
            : base(service, "PkidDiaSemana", "Dia de la semana", (dto, id) => dto.PkidDiaSemana = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomMedodoPagoAppService : NominaCrudAppService<MedodoPago, NomMedodoPagoDto, NomMedodoPagoResponse>
    {
        public NomMedodoPagoAppService(GenericService<MedodoPago, NomMedodoPagoDto, NomMedodoPagoResponse> service)
            : base(service, "PkidMetodoPago", "Metodo de pago", (dto, id) => dto.PkidMetodoPago = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomParentescoAppService : NominaCrudAppService<Parentesco, NomParentescoDto, NomParentescoResponse>
    {
        public NomParentescoAppService(GenericService<Parentesco, NomParentescoDto, NomParentescoResponse> service)
            : base(service, "PkidParentesco", "Parentesco", (dto, id) => dto.PkidParentesco = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomTipoContratacionAppService : NominaCrudAppService<TipoContratacion, NomTipoContratacionDto, NomTipoContratacionResponse>
    {
        public NomTipoContratacionAppService(GenericService<TipoContratacion, NomTipoContratacionDto, NomTipoContratacionResponse> service)
            : base(service, "PkidTipoContratacion", "Tipo de contratacion", (dto, id) => dto.PkidTipoContratacion = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomTipoIncidenciaAppService : NominaCrudAppService<TipoIncidencium, NomTipoIncidenciaDto, NomTipoIncidenciaResponse>
    {
        public NomTipoIncidenciaAppService(GenericService<TipoIncidencium, NomTipoIncidenciaDto, NomTipoIncidenciaResponse> service)
            : base(service, "PkidTipoIncidencia", "Tipo de incidencia", (dto, id) => dto.PkidTipoIncidencia = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    public class NomTipoJustificacionAppService : NominaCrudAppService<TipoJustificacion, NomTipoJustificacionDto, NomTipoJustificacionResponse>
    {
        public NomTipoJustificacionAppService(GenericService<TipoJustificacion, NomTipoJustificacionDto, NomTipoJustificacionResponse> service)
            : base(service, "PkidTipoJustificacion", "Tipo de justificacion", (dto, id) => dto.PkidTipoJustificacion = id)
        {
            service.DisableEmpresaFilter();
        }
    }

    internal static class NominaCatalogRequestMapper
    {
        public static PagedRequest MapPagedRequest(PagedRequest request, IReadOnlyDictionary<string, string> propertyMap)
        {
            return new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.Filtro,
                SortLabel = MapProperty(request.SortLabel, propertyMap),
                SortDirection = request.SortDirection,
                SearchString = request.SearchString,
                AdditionalFilters = request.AdditionalFilters?
                    .ToDictionary(
                        item => MapProperty(item.Key, propertyMap),
                        item => item.Value,
                        StringComparer.OrdinalIgnoreCase)
                    ?? new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase)
            };
        }

        private static string MapProperty(string propertyName, IReadOnlyDictionary<string, string> propertyMap)
            => !string.IsNullOrWhiteSpace(propertyName) && propertyMap.TryGetValue(propertyName, out var mapped)
                ? mapped
                : propertyName;
    }
}

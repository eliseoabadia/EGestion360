using AutoMapper;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio
{
    public class TipoBienService : ITipoBienService
    {
        private readonly GenericService<TipoBien, TipoBienDto, TipoBienResponse> _service;
        private readonly GenericService<VwTipoBien, TipoBienDto, TipoBienResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoBienService(
            GenericService<TipoBien, TipoBienDto, TipoBienResponse> service,
            GenericService<VwTipoBien, TipoBienDto, TipoBienResponse> serviceView,
            EGestionContext context,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.FkidGrupoBienAlmaNavigation);
            _service.AddInclude(e => e.FkidNivelAlmaNavigation);
            _service.AddInclude(e => e.FkidPartidaContaNavigation);
            _service.AddInclude(e => e.FkidCuentaContableContaNavigation);
            _service.AddInclude(e => e.FkidUnidadesAlmaNavigation);
            _service.AddInclude(e => e.FkidUnidadesEquivalenteNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueCodigoClave", async (dto) =>
            {
                var tbDto = dto as TipoBienDto;
                if (tbDto == null || string.IsNullOrEmpty(tbDto.CodigoClave)) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.CodigoClave == tbDto.CodigoClave && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueCodigoClaveUpdate", async (dto, id) =>
            {
                var tbDto = dto as TipoBienDto;
                if (tbDto == null || string.IsNullOrEmpty(tbDto.CodigoClave) || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.CodigoClave == tbDto.CodigoClave && x.PkidTipoBien != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<TipoBienResponse>> GetAllAsync()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                return new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipos de bien obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de bien: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoBienResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id);
                if (result == null)
                    return new PagedResult<TipoBienResponse> { Success = false, Message = "Tipo de bien no encontrado", Code = "NOT_FOUND" };

                return new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien obtenido correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoBienResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipo de bien: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoBienResponse>> CreateAsync(TipoBienResponse request)
        {
            try
            {
                var dto = _mapper.Map<TipoBienDto>(request);
                var userId = _userContext.GetCurrentUserId();

                await _context.Procedures.SP_MantenimientoTipoBienAsync(
                    action: 1,
                    pKIdTipoBien: null,
                    fKIdGrupoBien_ALMA: dto.FkidGrupoBienAlma,
                    fKIdNivel_ALMA: dto.FkidNivelAlma,
                    fKIdPartida_CONTA: dto.FkidPartidaConta,
                    fKIdCuentaContable_CONTA: dto.FkidCuentaContableConta,
                    fKIdUnidades_ALMA: dto.FkidUnidadesAlma,
                    fKIdLocalizacion_ALMA: dto.FkidLocalizacionAlma,
                    fKIdUnidades_Equivalente: dto.FkidUnidadesEquivalente,
                    codigoClave: dto.CodigoClave,
                    descripcion: dto.Descripcion,
                    depreciacionAnual: dto.DepreciacionAnual,
                    consecutivo: dto.Consecutivo,
                    cABMS: dto.Cabms,
                    identificador: dto.Identificador,
                    existenciaMinima: dto.ExistenciaMinima,
                    existenciaMaxima: dto.ExistenciaMaxima,
                    tiempoVida: dto.TiempoVida,
                    pk_IdTratadoInt: dto.PkIdTratadoInt,
                    cuota: dto.Cuota,
                    proveeduriaNac: dto.ProveeduriaNac,
                    catalogoBasico: dto.CatalogoBasico,
                    cUCOP_PLUS: dto.CucopPlus,
                    cantidad_Equivalente: dto.CantidadEquivalente,
                    idC: null,
                    idUser: userId,
                    id: null);

                var createdView = await _serviceView.GetQueryWithIncludes()
                    .OrderByDescending(x => x.PkidTipoBien)
                    .FirstOrDefaultAsync();

                return new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien creado correctamente",
                    Code = "SUCCESS",
                    Data = createdView != null ? _mapper.Map<TipoBienResponse>(createdView) : null,
                    Items = createdView != null ? new List<TipoBienResponse> { _mapper.Map<TipoBienResponse>(createdView) } : new List<TipoBienResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<TipoBienResponse>> UpdateAsync(int id, TipoBienResponse request)
        {
            try
            {
                var existingView = await _serviceView.GetByIdAsync(id);
                if (existingView == null)
                    return new PagedResult<TipoBienResponse> { Success = false, Message = "Tipo de bien no encontrado", Code = "NOT_FOUND" };

                var dto = _mapper.Map<TipoBienDto>(request);
                var userId = _userContext.GetCurrentUserId();

                await _service.CanUpdateAsync(id, dto);

                await _context.Procedures.SP_MantenimientoTipoBienAsync(
                    action: 2,
                    pKIdTipoBien: id,
                    fKIdGrupoBien_ALMA: dto.FkidGrupoBienAlma,
                    fKIdNivel_ALMA: dto.FkidNivelAlma,
                    fKIdPartida_CONTA: dto.FkidPartidaConta,
                    fKIdCuentaContable_CONTA: dto.FkidCuentaContableConta,
                    fKIdUnidades_ALMA: dto.FkidUnidadesAlma,
                    fKIdLocalizacion_ALMA: dto.FkidLocalizacionAlma,
                    fKIdUnidades_Equivalente: dto.FkidUnidadesEquivalente,
                    codigoClave: dto.CodigoClave,
                    descripcion: dto.Descripcion,
                    depreciacionAnual: dto.DepreciacionAnual,
                    consecutivo: dto.Consecutivo,
                    cABMS: dto.Cabms,
                    identificador: dto.Identificador,
                    existenciaMinima: dto.ExistenciaMinima,
                    existenciaMaxima: dto.ExistenciaMaxima,
                    tiempoVida: dto.TiempoVida,
                    pk_IdTratadoInt: dto.PkIdTratadoInt,
                    cuota: dto.Cuota,
                    proveeduriaNac: dto.ProveeduriaNac,
                    catalogoBasico: dto.CatalogoBasico,
                    cUCOP_PLUS: dto.CucopPlus,
                    cantidad_Equivalente: dto.CantidadEquivalente,
                    idC: null,
                    idUser: userId,
                    id: null);

                var updatedView = await _serviceView.GetByIdAsync(id);
                return new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updatedView != null ? _mapper.Map<TipoBienResponse>(updatedView) : null,
                    Items = updatedView != null ? new List<TipoBienResponse> { _mapper.Map<TipoBienResponse>(updatedView) } : new List<TipoBienResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existingView = await _serviceView.GetByIdAsync(id);
                if (existingView == null)
                    return new PagedResult<bool> { Success = false, Message = "Tipo de bien no encontrado", Code = "NOT_FOUND" };

                var userId = _userContext.GetCurrentUserId();

                await _context.Procedures.SP_MantenimientoTipoBienAsync(
                    action: 3,
                    pKIdTipoBien: id,
                    fKIdGrupoBien_ALMA: existingView.FkidGrupoBienAlma,
                    fKIdNivel_ALMA: existingView.FkidNivelAlma,
                    fKIdPartida_CONTA: existingView.FkidPartidaConta,
                    fKIdCuentaContable_CONTA: existingView.FkidCuentaContableConta,
                    fKIdUnidades_ALMA: existingView.FkidUnidadesAlma,
                    fKIdLocalizacion_ALMA: existingView.FkidLocalizacionAlma,
                    fKIdUnidades_Equivalente: existingView.FkidUnidadesEquivalente,
                    codigoClave: existingView.CodigoClave,
                    descripcion: existingView.TipoBienDescripcion,
                    depreciacionAnual: existingView.DepreciacionAnual,
                    consecutivo: existingView.Consecutivo,
                    cABMS: existingView.Cabms,
                    identificador: existingView.Identificador,
                    existenciaMinima: existingView.ExistenciaMinima,
                    existenciaMaxima: existingView.ExistenciaMaxima,
                    tiempoVida: existingView.TiempoVida,
                    pk_IdTratadoInt: existingView.PkIdTratadoInt,
                    cuota: existingView.Cuota,
                    proveeduriaNac: existingView.ProveeduriaNac,
                    catalogoBasico: existingView.CatalogoBasico,
                    cUCOP_PLUS: existingView.CucopPlus,
                    cantidad_Equivalente: existingView.CantidadEquivalente,
                    idC: null,
                    idUser: userId,
                    id: null);

                return new PagedResult<bool> { Success = true, Message = "Tipo de bien eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<TipoBienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    query = query.Where(e =>
                        e.TipoBienDescripcion.Contains(request.Filtro) ||
                        e.CodigoClave.Contains(request.Filtro) ||
                        e.GrupoBienDescripcion.Contains(request.Filtro) ||
                        e.PartidaDescripcion.Contains(request.Filtro) ||
                        (e.CucopPlus != null && e.CucopPlus.Contains(request.Filtro)));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidTipoBien" => isAscending ? query.OrderBy(e => e.PkidTipoBien) : query.OrderByDescending(e => e.PkidTipoBien),
                        "TipoBienDescripcion" => isAscending ? query.OrderBy(e => e.TipoBienDescripcion) : query.OrderByDescending(e => e.TipoBienDescripcion),
                        "GrupoBienDescripcion" => isAscending ? query.OrderBy(e => e.GrupoBienDescripcion) : query.OrderByDescending(e => e.GrupoBienDescripcion),
                        "CodigoClave" => isAscending ? query.OrderBy(e => e.CodigoClave) : query.OrderByDescending(e => e.CodigoClave),
                        "PartidaDescripcion" => isAscending ? query.OrderBy(e => e.PartidaDescripcion) : query.OrderByDescending(e => e.PartidaDescripcion),
                        "DepreciacionAnual" => isAscending ? query.OrderBy(e => e.DepreciacionAnual) : query.OrderByDescending(e => e.DepreciacionAnual),
                        "Consecutivo" => isAscending ? query.OrderBy(e => e.Consecutivo) : query.OrderByDescending(e => e.Consecutivo),
                        "Identificador" => isAscending ? query.OrderBy(e => e.Identificador) : query.OrderByDescending(e => e.Identificador),
                        "ExistenciaMinima" => isAscending ? query.OrderBy(e => e.ExistenciaMinima) : query.OrderByDescending(e => e.ExistenciaMinima),
                        "ExistenciaMaxima" => isAscending ? query.OrderBy(e => e.ExistenciaMaxima) : query.OrderByDescending(e => e.ExistenciaMaxima),
                        "TiempoVida" => isAscending ? query.OrderBy(e => e.TiempoVida) : query.OrderByDescending(e => e.TiempoVida),
                        "UnidadMedida" => isAscending ? query.OrderBy(e => e.UnidadMedida) : query.OrderByDescending(e => e.UnidadMedida),
                        "UnidadEquivalenteMedida" => isAscending ? query.OrderBy(e => e.UnidadEquivalenteMedida) : query.OrderByDescending(e => e.UnidadEquivalenteMedida),
                        "CatalogoBasico" => isAscending ? query.OrderBy(e => e.CatalogoBasico) : query.OrderByDescending(e => e.CatalogoBasico),
                        "CucopPlus" => isAscending ? query.OrderBy(e => e.CucopPlus) : query.OrderByDescending(e => e.CucopPlus),
                        "CantidadEquivalente" => isAscending ? query.OrderBy(e => e.CantidadEquivalente) : query.OrderByDescending(e => e.CantidadEquivalente),
                        _ => query.OrderBy(e => e.TipoBienDescripcion)
                    };
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<TipoBienResponse>
                {
                    Items = _mapper.Map<List<TipoBienResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de bien: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}

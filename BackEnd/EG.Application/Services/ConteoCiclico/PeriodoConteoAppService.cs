using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class PeriodoConteoAppService : IPeriodoConteoAppService
    {
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _service;
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public PeriodoConteoAppService(
            GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> service,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Includes para la entidad (operaciones de escritura)
            _service.AddInclude(p => p.FkidSucursalSisNavigation);
            _service.AddInclude(p => p.FkidTipoConteoAlmaNavigation);
            _service.AddInclude(p => p.FkidEstatusAlmaNavigation);
            _service.AddInclude(p => p.FkidResponsableSisNavigation);
            _service.AddInclude(p => p.FkidSupervisorSisNavigation);

            // Filtros de relación para búsquedas dinámicas (entidad)
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "Codigo" });
            _service.AddRelationFilter("TipoConteo", new List<string> { "Nombre", "Clave" });
            _service.AddRelationFilter("Estatus", new List<string> { "Nombre" });
            _service.AddRelationFilter("Responsable", new List<string> { "NombreUsuario", "Email" });
            _service.AddRelationFilter("Supervisor", new List<string> { "NombreUsuario", "Email" });

            // Configuración para la vista (consultas)
            _serviceView.AddRelationFilter("Sucursal", new List<string> { "SucursalNombre" });
            _serviceView.AddRelationFilter("TipoConteo", new List<string> { "TipoConteoNombre" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre" });
            _serviceView.AddRelationFilter("Responsable", new List<string> { "ResponsableNombre" });
            _serviceView.AddRelationFilter("Supervisor", new List<string> { "SupervisorNombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Código de periodo único (creación)
            _service.AddValidationRule("UniqueCodigoPeriodo", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null || string.IsNullOrWhiteSpace(periodoDto.CodigoPeriodo))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.CodigoPeriodo.ToLower() == periodoDto.CodigoPeriodo.ToLower() && p.Activo);
                return !exists;
            });

            // REGLA 2: Código de periodo único (actualización)
            _service.AddValidationRuleWithId("UniqueCodigoPeriodoUpdate", async (dto, id) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null || !id.HasValue || string.IsNullOrWhiteSpace(periodoDto.CodigoPeriodo))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.CodigoPeriodo.ToLower() == periodoDto.CodigoPeriodo.ToLower() &&
                                   p.PkidPeriodoConteo != id.Value &&
                                   p.Activo);
                return !exists;
            });

            // REGLA 3: Nombre obligatorio
            _service.AddValidationRule("NombreRequerido", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return !string.IsNullOrWhiteSpace(periodoDto?.Nombre);
            });

            // REGLA 4: Fecha inicio no puede ser mayor que fecha fin (si se especifica)
            _service.AddValidationRule("FechasConsistentes", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null) return true;
                if (periodoDto.FechaFin.HasValue && periodoDto.FechaInicio > periodoDto.FechaFin.Value)
                    return false;
                return true;
            });

            // REGLA 5: Máximo de conteos por artículo debe ser positivo
            _service.AddValidationRule("MaximoConteosPositivo", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                return periodoDto?.MaximoConteosPorArticulo > 0;
            });
        }

        // ==================== CONSULTAS ====================

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllAsync()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Listado de periodos obtenido correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PeriodoConteoResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
            }
            catch
            {
                return null;
            }
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Listado paginado obtenido",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetBySucursalIdAsync(int sucursalId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    p => p.SucursalId == sucursalId && p.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodos por sucursal obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetByEstatusIdAsync(int estatusId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    p => p.EstatusId == estatusId && p.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodos por estatus obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetPeriodosAbiertosAsync()
        {
            try
            {
                // Asumiendo que el estatus "abierto" tiene un Id específico (ej: 1)
                // O podríamos filtrar por aquellos sin fecha de cierre
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    p => p.FechaCierre == null && p.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodos abiertos obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetPeriodosCerradosAsync()
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    p => p.FechaCierre != null && p.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Periodos cerrados obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        // ==================== ESCRITURA ====================

        public async Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del periodo son requeridos");

            // Asignar valores de auditoría
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioActual;
            dto.Activo = true;

            // Inicializar contadores en cero
            dto.TotalArticulos = 0;
            dto.ArticulosConcluidos = 0;
            dto.ArticulosConDiferencia = 0;

            // Validar reglas de negocio
            if (!await _service.CanAddAsync(dto))
            {
                var existeCodigo = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.CodigoPeriodo.ToLower() == dto.CodigoPeriodo.ToLower() && p.Activo);
                if (existeCodigo)
                    throw new InvalidOperationException($"El código de periodo '{dto.CodigoPeriodo}' ya está registrado para otro periodo activo");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidPeriodoConteo);
        }

        public async Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del periodo son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID de periodo inválido", nameof(id));

            // Verificar si el periodo ya está cerrado
            var periodoExistente = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (periodoExistente == null)
                throw new InvalidOperationException("Periodo no encontrado");
            if (periodoExistente.FechaCierre.HasValue)
                throw new InvalidOperationException("No se puede modificar un periodo cerrado");

            dto.PkidPeriodoConteo = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;
            // Mantener los contadores originales (no se actualizan desde el DTO)
            dto.TotalArticulos = periodoExistente.TotalArticulos;
            dto.ArticulosConcluidos = periodoExistente.ArticulosConcluidos;
            dto.ArticulosConDiferencia = periodoExistente.ArticulosConDiferencia;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                var existeCodigo = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.CodigoPeriodo.ToLower() == dto.CodigoPeriodo.ToLower() &&
                                   p.PkidPeriodoConteo != id &&
                                   p.Activo);
                if (existeCodigo)
                    throw new InvalidOperationException($"El código de periodo '{dto.CodigoPeriodo}' ya está registrado para otro periodo activo");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de periodo inválido", nameof(id));

            var _periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (_periodo == null)
                throw new InvalidOperationException("Periodo no encontrado");

            var periodoDto = _mapper.Map<PeriodoConteoDto>(_periodo);
            // Soft delete
            periodoDto.Activo = false;
            periodoDto.FechaModificacion = DateTime.Now;
            periodoDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, periodoDto);
            return true;
        }

        // ==================== ACCIONES DE NEGOCIO ====================

        public async Task<bool> CerrarPeriodoAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de periodo inválido", nameof(id));

            var _periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (_periodo == null)
                throw new InvalidOperationException("Periodo no encontrado");

            if (_periodo.FechaCierre.HasValue)
                throw new InvalidOperationException("El periodo ya está cerrado");

            // Actualizar estadísticas antes de cerrar
            await ActualizarEstadisticasAsync(id);

            var periodoDto = _mapper.Map<PeriodoConteoDto>(_periodo);

            periodoDto.FechaCierre = DateTime.Now;
            periodoDto.FechaModificacion = DateTime.Now;
            periodoDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, periodoDto);
            return true;
        }

        public async Task<bool> ReabrirPeriodoAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de periodo inválido", nameof(id));

            var _periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (_periodo == null)
                throw new InvalidOperationException("Periodo no encontrado");

            if (!_periodo.FechaCierre.HasValue)
                throw new InvalidOperationException("El periodo no está cerrado");


            var periodoDto = _mapper.Map<PeriodoConteoDto>(_periodo);
            periodoDto.FechaCierre = null;
            periodoDto.FechaModificacion = DateTime.Now;
            periodoDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, periodoDto);
            return true;
        }

        public async Task<bool> ActualizarEstadisticasAsync(int id)
        {
            // Este método podría ejecutar un procedimiento almacenado o cálculos manuales
            // Por simplicidad, solo retornamos true; en un caso real se actualizarían los contadores
            // desde los artículos asociados.
            return true;
        }

        public async Task<bool> CambiarEstatusAsync(int id, int estatusId, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de periodo inválido", nameof(id));

            // Obtener la entidad directamente usando el repositorio del GenericService
            var query = _service.GetQueryWithIncludes(p => p.PkidPeriodoConteo == id);
            var entity = await Task.Run(() => query.FirstOrDefault());
            
            if (entity == null)
                throw new InvalidOperationException("Periodo no encontrado");

            // Validar transición de estatus
            if (!EsTransicionValida(entity.FkidEstatusAlma, estatusId))
                throw new InvalidOperationException($"Transición de estatus no válida: {entity.FkidEstatusAlma} -> {estatusId}");

            // Mapear a DTO y actualizar
            var periodoDto = _mapper.Map<PeriodoConteoDto>(entity);
            periodoDto.FkidEstatusAlma = estatusId;
            periodoDto.FechaModificacion = DateTime.Now;
            periodoDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, periodoDto);
            return true;
        }

        private bool EsTransicionValida(int estatusActual, int estatusNuevo)
        {
            return (estatusActual, estatusNuevo) switch
            {
                (1, 2) => true,  // Pendiente -> En Proceso
                (1, 4) => true,  // Pendiente -> Cerrado
                (2, 3) => true,  // En Proceso -> Completado
                (2, 4) => true,  // En Proceso -> Cerrado
                (3, 4) => true,  // Completado -> Cerrado
                _ => false
            };
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetMisPeriodosAsync(int usuarioId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    p => (p.ResponsableId == usuarioId || p.SupervisorId == usuarioId) && p.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Mis periodos obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
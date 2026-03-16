using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Net.NetworkInformation;

namespace EG.Application.Services.ConteoCiclico
{
    public class ArticuloConteoAppService : IArticuloConteoAppService
    {
        private readonly GenericService<ArticuloConteo, ArticuloConteoDto, PeriodoConteoResponse> _service;
        private readonly GenericService<VwArticuloConteo, ArticuloConteoDto, PeriodoConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public ArticuloConteoAppService(
            GenericService<ArticuloConteo, ArticuloConteoDto, PeriodoConteoResponse> service,
            GenericService<VwArticuloConteo, ArticuloConteoDto, PeriodoConteoResponse> serviceView,
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
            // Includes necesarios para el servicio de entidad (para operaciones de escritura)
            _service.AddInclude(a => a.FkidEstatusAlmaNavigation);
            _service.AddInclude(a => a.FkidPeriodoConteoAlmaNavigation);
            _service.AddInclude(a => a.FkidSucursalSisNavigation);
            _service.AddInclude(a => a.FkidTipoBienAlmaNavigation);
            _service.AddInclude(a => a.FkidUsuarioConcluyoSisNavigation);

            // Filtros de relación para búsquedas dinámicas
            _service.AddRelationFilter("Periodo", new List<string> { "Codigo", "Nombre" });
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "Codigo" });
            _service.AddRelationFilter("Estatus", new List<string> { "Nombre", "Descripcion" });
            _service.AddRelationFilter("TipoBien", new List<string> { "Codigo", "Descripcion" });

            // Configuración para la vista (solo consultas)
            _serviceView.AddRelationFilter("Periodo", new List<string> { "CodigoPeriodo", "PeriodoNombre" });
            _serviceView.AddRelationFilter("Sucursal", new List<string> { "SucursalNombre" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre", "EstatusDescripcion" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Código de barras único (creación)
            _service.AddValidationRule("UniqueCodigoBarras", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || string.IsNullOrWhiteSpace(articuloDto.CodigoBarras))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.CodigoBarras == articuloDto.CodigoBarras && a.Activo);
                return !exists;
            });

            // REGLA 2: Código de barras único (actualización)
            _service.AddValidationRuleWithId("UniqueCodigoBarrasUpdate", async (dto, id) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || !id.HasValue || string.IsNullOrWhiteSpace(articuloDto.CodigoBarras))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.CodigoBarras == articuloDto.CodigoBarras &&
                                   a.PkidArticuloConteo != id.Value &&
                                   a.Activo);
                return !exists;
            });

            // REGLA 3: Descripción obligatoria
            _service.AddValidationRule("DescripcionRequerida", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return !string.IsNullOrWhiteSpace(articuloDto?.DescripcionArticulo);
            });

            // REGLA 4: Existencia sistema debe ser >= 0
            _service.AddValidationRule("ExistenciaSistemaValida", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                return articuloDto?.ExistenciaSistema >= 0;
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
                    Message = "Listado de artículos obtenido correctamente",
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

        public async Task<PagedResult<PeriodoConteoResponse>> GetByPeriodoIdAsync(int periodoId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.PeriodoId == periodoId && x.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Artículos por periodo obtenidos",
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
                    x => x.SucursalId == sucursalId && x.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Artículos por sucursal obtenidos",
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

        public async Task<PagedResult<PeriodoConteoResponse>> GetPendientesAsync(int periodoId, int sucursalId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.PeriodoId == periodoId &&
                         x.SucursalId == sucursalId &&
                         x.EstaConcluido == 0 &&
                         x.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Artículos pendientes obtenidos",
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

        public async Task<PagedResult<PeriodoConteoResponse>> GetConcluidosAsync(int periodoId, int sucursalId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.PeriodoId == periodoId &&
                         x.SucursalId == sucursalId &&
                         x.EstaConcluido == 1 &&
                         x.Activo
                );
                return new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Artículos concluidos obtenidos",
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

        public async Task<PeriodoConteoResponse> CreateAsync(ArticuloConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del artículo son requeridos");

            // Asignar valores de auditoría
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioActual;
            dto.Activo = true;
            dto.ConteosRealizados = 0;
            dto.ConteosPendientes = 0; // Se calculará después según configuración

            // Validar reglas de negocio
            if (!await _service.CanAddAsync(dto))
            {
                var existeCodigo = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.CodigoBarras == dto.CodigoBarras && a.Activo);
                if (existeCodigo)
                    throw new InvalidOperationException($"El código de barras '{dto.CodigoBarras}' ya está registrado para otro artículo activo");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidArticuloConteo);
        }

        public async Task<PeriodoConteoResponse> UpdateAsync(int id, ArticuloConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del artículo son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID de artículo inválido", nameof(id));

            dto.PkidArticuloConteo = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                var existeCodigo = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.CodigoBarras == dto.CodigoBarras &&
                                   a.PkidArticuloConteo != id &&
                                   a.Activo);
                if (existeCodigo)
                    throw new InvalidOperationException($"El código de barras '{dto.CodigoBarras}' ya está registrado para otro artículo activo");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de artículo inválido", nameof(id));

            var _articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
            if (_articulo == null)
                throw new InvalidOperationException("Artículo no encontrado");

            var articuloDto = _mapper.Map<ArticuloConteoDto>(_articulo);
            // Soft delete
            articuloDto.Activo = false;
            articuloDto.FechaModificacion = DateTime.Now;
            articuloDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, articuloDto);
            return true;
        }

        // ==================== MÉTODOS DE NEGOCIO ====================

        public async Task<bool> IniciarConteoAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de artículo inválido", nameof(id));

            var _articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
            if (_articulo == null)
                throw new InvalidOperationException("Artículo no encontrado");

            //if (_articulo.FechaInicio.)
            //    throw new InvalidOperationException("El conteo ya fue iniciado anteriormente");

            var articuloDto = _mapper.Map<ArticuloConteoDto>(_articulo);

            articuloDto.FechaInicioConteo = DateTime.Now;
            articuloDto.FechaModificacion = DateTime.Now;
            articuloDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, articuloDto);
            return true;
        }

        public async Task<bool> ConcluirConteoAsync(int id, decimal existenciaFinal, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de artículo inválido", nameof(id));

            var _articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
            if (_articulo == null)
                throw new InvalidOperationException("Artículo no encontrado");

            if (_articulo.FechaCierre.HasValue)
                throw new InvalidOperationException("El conteo ya fue concluido anteriormente");


            var articuloDto = _mapper.Map<ArticuloConteoDto>(_articulo);

            // Calcular diferencias
            articuloDto.ExistenciaFinal = existenciaFinal;
            articuloDto.Diferencia = existenciaFinal - articuloDto.ExistenciaSistema;
            if (articuloDto.ExistenciaSistema != 0)
            {
                articuloDto.PorcentajeDiferencia = (articuloDto.Diferencia / articuloDto.ExistenciaSistema) * 100;
            }
            else
            {
                articuloDto.PorcentajeDiferencia = articuloDto.Diferencia != 0 ? 100 : 0;
            }

            articuloDto.FechaConclusion = DateTime.Now;
            articuloDto.FkidUsuarioConcluyoSis = usuarioActual;
            articuloDto.FechaModificacion = DateTime.Now;
            articuloDto.UsuarioModificacion = usuarioActual;

            // Actualizar estatus si es necesario (ej: a un estatus de concluido)
            // articuloDto.FkidEstatusAlma = idEstatusConcluido;

            await _service.UpdateAsync(id, articuloDto);
            return true;
        }
    }
}
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
    public class ArticuloConteoAppService : IArticuloConteoAppService
    {
        private readonly GenericService<ArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> _service;
        private readonly GenericService<VwArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public ArticuloConteoAppService(
            GenericService<ArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> service,
            GenericService<VwArticuloConteo, ArticuloConteoDto, VwArticuloConteoResponse> serviceView,
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
            _service.AddInclude(a => a.FkidPeriodoConteoAlmaNavigation);
            _service.AddInclude(a => a.FkidTipoBienAlmaNavigation);
            _service.AddInclude(a => a.FkidSucursalSisNavigation);
            _service.AddInclude(a => a.FkidEstatusAlmaNavigation);
            _service.AddInclude(a => a.RegistroConteos);
            _service.AddInclude(a => a.HistorialEstatusArticulos);

            _serviceView.AddRelationFilter("Periodo", new List<string> { "PeriodoNombre", "PeriodoId" });
            _serviceView.AddRelationFilter("TipoBien", new List<string> { "ArticuloDescripcion" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA: Código de artículo único por período
            _service.AddValidationRule("UniqueCodigoArticulo", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null || string.IsNullOrWhiteSpace(articuloDto.CodigoBarras))
                    return true; // Si no tiene código, permitir

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.FkidPeriodoConteoAlma == articuloDto.FkidPeriodoConteoAlma &&
                                  a.CodigoBarras == articuloDto.CodigoBarras &&
                                  a.Activo);

                return !exists;
            });

            // REGLA: Existencia mínima/máxima validadas
            _service.AddValidationRule("ValidExistencia", async (dto) =>
            {
                var articuloDto = dto as ArticuloConteoDto;
                if (articuloDto == null) return false;

                return articuloDto.ExistenciaSistema >= 0;
            });
        }

        // ===== CONSULTAS =====
        public async Task<PagedResult<VwArticuloConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            var response = _mapper.Map<List<VwArticuloConteoResponse>>(result);
            return new PagedResult<VwArticuloConteoResponse>
            {
                Success = true,
                Items = response,
                TotalCount = response.Count
            };
        }

        public async Task<VwArticuloConteoResponse> GetByIdAsync(int id)
        {
            var articulo = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
            if (articulo == null)
                throw new KeyNotFoundException($"Artículo {id} no encontrado");

            return articulo;
        }

        public async Task<PagedResult<VwArticuloConteoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<VwArticuloConteoResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        // ===== FILTRADOS =====
        public async Task<PagedResult<VwArticuloConteoResponse>> GetAllByPeriodoAsync(int periodoId)
        {
            var parametros = new Dictionary<string, object> { ["periodoId"] = periodoId };
            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SearchString = "",
                SortLabel = "CodigoBarras",
                SortDirection = "Ascending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        public async Task<PagedResult<VwArticuloConteoResponse>> GetPendientesAsync(int periodoId)
        {
            // 🔧 LÓGICA: Artículos pendientes = ConteosPendientes > 0
            var parametros = new Dictionary<string, object>
            {
                ["periodoId"] = periodoId,
                ["conteosRestantes"] = 1 // >0
            };

            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SearchString = "",
                SortLabel = "CodigoBarras",
                SortDirection = "Ascending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        public async Task<PagedResult<VwArticuloConteoResponse>> GetByEstatusAsync(int periodoId, int estatusId)
        {
            var parametros = new Dictionary<string, object>
            {
                ["periodoId"] = periodoId,
                ["estatusId"] = estatusId
            };

            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SearchString = "",
                SortLabel = "CodigoBarras",
                SortDirection = "Ascending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        // ===== COMANDOS =====
        public async Task<VwArticuloConteoResponse> CreateAsync(ArticuloConteoDto dto, int usuarioActual)
        {
            if (dto.FkidPeriodoConteoAlma <= 0 || dto.FkidTipoBienAlma <= 0)
                throw new ArgumentException("Período y Tipo de Bien son requeridos");

            // 🔧 LÓGICA: Inicializar valores de conteo
            dto.ConteosRealizados = 0;
            dto.ConteosPendientes = 1;
            dto.FkidEstatusAlma = 1; // Pendiente 1er Conteo

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Validación falló");

            await _service.AddAsync(dto);

            var articuloCreado = await _serviceView.GetByIdAsync(dto.PkidArticuloConteo, idPropertyName: "Id");
            return articuloCreado;
        }

        public async Task<VwArticuloConteoResponse> UpdateAsync(int id, ArticuloConteoDto dto, int usuarioActual)
        {
            if (id != dto.PkidArticuloConteo)
                throw new ArgumentException("ID no coincide");

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Validación falló");

            await _service.UpdateAsync(id, dto);

            return await GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
            if (articulo == null)
                throw new KeyNotFoundException($"Artículo {id} no encontrado");

            // 🔧 LÓGICA: No se puede eliminar si tiene conteos realizados
            if (articulo.ConteosRealizados > 0)
                throw new InvalidOperationException("No se puede eliminar: tiene conteos realizados");

            await _service.DeleteAsync(id);
        }

        // ===== OPERACIONES ESPECÍFICAS =====
        public async Task CambiarEstatusAsync(int id, int estatusId, int usuarioActual)
        {
            var articulo = await _service.GetByIdAsync(id, idPropertyName: "PkidArticuloConteo");
            if (articulo == null)
                throw new KeyNotFoundException($"Artículo {id} no encontrado");

            var dto = _mapper.Map<ArticuloConteoDto>(articulo);
            dto.FkidEstatusAlma = estatusId;

            // 🔧 LÓGICA: Si se marca como "Concluido Sin Diferencia", asignar fecha de conclusión
            if (estatusId == 4 || estatusId == 5) // Concluido
            {
                dto.FechaConclusion = DateTime.Now;
            }

            await _service.UpdateAsync(id, dto);
        }

        public async Task ActualizarProgresAsync(int periodoId, int usuarioActual)
        {
            // 🔧 LÓGICA DE NEGOCIO: Actualizar estadísticas del período
            var articulos = await _service.GetQueryWithIncludes()
                .Where(a => a.FkidPeriodoConteoAlma == periodoId && a.Activo)
                .ToListAsync();

            if (!articulos.Any())
                return;

            // Contar por estatus
            int totalArticulos = articulos.Count;
            int concluidos = articulos.Count(a => a.FkidEstatusAlma == 4 || a.FkidEstatusAlma == 5);
            int conDiferencia = articulos.Count(a => a.FkidEstatusAlma == 5);
            int pendientes = articulos.Count(a => a.ConteosPendientes > 0);
            int enDiscrepancia = articulos.Count(a => a.FkidEstatusAlma == 6);

            // Aquí podrías actualizar PeriodoConteo con estas estadísticas
            // await _periodoService.ActualizarEstadisticasAsync(periodoId, totalArticulos, concluidos, conDiferencia);
        }
    }
}
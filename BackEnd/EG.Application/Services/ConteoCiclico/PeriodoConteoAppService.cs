using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class PeriodoConteoAppService : IPeriodoConteoAppService
    {
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> _service;
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public PeriodoConteoAppService(
            GenericService<PeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> service,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, VwPeriodoConteoResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        // 🔧 TODA LA LÓGICA DE CONFIGURACIÓN AQUÍ (no en el controller)
        private void ConfigureService()
        {
            _service.AddInclude(p => p.FkidSucursalSisNavigation);
            _service.AddInclude(p => p.FkidTipoConteoAlmaNavigation);
            _service.AddInclude(p => p.FkidEstatusAlmaNavigation);
            _service.AddInclude(p => p.FkidResponsableSisNavigation);
            _service.AddInclude(p => p.FkidSupervisorSisNavigation);
            _service.AddInclude(p => p.ArticuloConteos);
            _service.AddInclude(p => p.RegistroConteos);

            _serviceView.AddRelationFilter("Sucursal", new List<string> { "SucursalNombre", "SucursalId" });
            _serviceView.AddRelationFilter("TipoConteo", new List<string> { "TipoConteoNombre" });
            _serviceView.AddRelationFilter("Estatus", new List<string> { "EstatusNombre" });
        }

        private void ConfigureValidations()
        {
            // 🔧 REGLAS DE NEGOCIO AQUÍ
            _service.AddValidationRule("UniqueCodigoPeriodo", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null || string.IsNullOrWhiteSpace(periodoDto.CodigoPeriodo))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.FkidSucursalSis == periodoDto.FkidSucursalSis &&
                                  p.CodigoPeriodo.ToLower() == periodoDto.CodigoPeriodo.ToLower() &&
                                  p.Activo);

                return !exists;
            });

            _service.AddValidationRule("ValidFechas", async (dto) =>
            {
                var periodoDto = dto as PeriodoConteoDto;
                if (periodoDto == null) return false;

                if (periodoDto.FechaFin.HasValue && periodoDto.FechaFin.Value < periodoDto.FechaInicio)
                    return false;

                return true;
            });

            _service.AddValidationRule("ValidNombre", async (dto) =>
                !string.IsNullOrWhiteSpace((dto as PeriodoConteoDto)?.Nombre));
        }

        // ===== CONSULTAS (READ) =====
        public async Task<PagedResult<VwPeriodoConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            var response = _mapper.Map<List<VwPeriodoConteoResponse>>(result);
            return new PagedResult<VwPeriodoConteoResponse>
            {
                Success = true,
                Items = response,
                TotalCount = response.Count
            };
        }

        public async Task<VwPeriodoConteoResponse> GetByIdAsync(int id)
        {
            var periodo = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
            if (periodo == null)
                throw new KeyNotFoundException($"Período {id} no encontrado");

            return periodo;
        }

        public async Task<PagedResult<VwPeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<VwPeriodoConteoResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        // ===== COMANDOS (CREATE, UPDATE, DELETE) =====
        public async Task<VwPeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual)
        {
            // 🔧 LÓGICA DE NEGOCIO AQUÍ
            if (string.IsNullOrWhiteSpace(dto.CodigoPeriodo) || string.IsNullOrWhiteSpace(dto.Nombre))
                throw new ArgumentException("Código y nombre son requeridos");

            dto.FkidEstatusAlma = dto.FkidEstatusAlma == 0 ? 1 : dto.FkidEstatusAlma; // Pendiente por defecto
            dto.MaximoConteosPorArticulo = dto.MaximoConteosPorArticulo == 0 ? 3 : dto.MaximoConteosPorArticulo;

            // Validar unicidad
            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException($"Código '{dto.CodigoPeriodo}' ya existe en esta sucursal");

            await _service.AddAsync(dto);

            var periodoCreado = await _serviceView.GetByIdAsync(dto.PkidPeriodoConteo, idPropertyName: "Id");
            return periodoCreado;
        }

        public async Task<VwPeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual)
        {
            if (id != dto.PkidPeriodoConteo)
                throw new ArgumentException("ID no coincide");

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Validación falló");

            await _service.UpdateAsync(id, dto);

            return await GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (periodo == null)
                throw new KeyNotFoundException($"Período {id} no encontrado");

            var tieneArticulos = await _service.GetQueryWithIncludes()
                .AnyAsync(p => p.PkidPeriodoConteo == id && p.ArticuloConteos.Any());

            if (tieneArticulos)
                throw new InvalidOperationException("No se puede eliminar: tiene artículos asociados");

            await _service.DeleteAsync(id);
        }

        // ===== OPERACIONES ESPECÍFICAS DE NEGOCIO =====
        public async Task CambiarEstatusAsync(int id, int estatusId, int usuarioActual)
        {
            var periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (periodo == null)
                throw new KeyNotFoundException($"Período {id} no encontrado");

            // 🔧 REGLA DE NEGOCIO: Si es "Completado", asignar fecha fin
            var dto = _mapper.Map<PeriodoConteoDto>(periodo);
            dto.FkidEstatusAlma = estatusId;

            if (estatusId == 3) // Completado
                dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);

            if (estatusId == 4) // Cerrado
            {
                dto.FechaCierre = DateTime.Now;
                if (!dto.FechaFin.HasValue)
                    dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);
            }

            await _service.UpdateAsync(id, dto);
        }

        public async Task CerrarPeriodoAsync(int id, int usuarioActual)
        {
            var periodo = await _service.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
            if (periodo == null)
                throw new KeyNotFoundException($"Período {id} no encontrado");

            // 🔧 REGLA DE NEGOCIO: Verificar si hay artículos pendientes
            if (periodo.ArticulosPendientes > 0)
                throw new InvalidOperationException("No se puede cerrar: hay artículos pendientes");

            var dto = _mapper.Map<PeriodoConteoDto>(periodo);
            dto.FkidEstatusAlma = 3; // Completado
            dto.FechaFin = DateOnly.FromDateTime(DateTime.Now);

            await _service.UpdateAsync(id, dto);
        }

        Task<PagedResult<VwPeriodoConteoResponse>> IPeriodoConteoAppService.GetAllAsync()
        {
            throw new NotImplementedException();
        }

        Task<PagedResult<VwPeriodoConteoResponse>> IPeriodoConteoAppService.GetAllPaginadoAsync(PagedRequest request)
        {
            throw new NotImplementedException();
        }
    }
}
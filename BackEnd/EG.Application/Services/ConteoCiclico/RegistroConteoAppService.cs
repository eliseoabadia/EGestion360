using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class RegistroConteoAppService : IRegistroConteoAppService
    {
        private readonly GenericService<RegistroConteo, RegistroConteoDto, VwRegistroConteoResponse> _service;
        private readonly GenericService<VwRegistroConteo, RegistroConteoDto, VwRegistroConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public RegistroConteoAppService(
            GenericService<RegistroConteo, RegistroConteoDto, VwRegistroConteoResponse> service,
            GenericService<VwRegistroConteo, RegistroConteoDto, VwRegistroConteoResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(r => r.FkidArticuloConteoAlmaNavigation);
            _service.AddInclude(r => r.FkidPeriodoConteoAlmaNavigation);
            _service.AddInclude(r => r.FkidUsuarioSisNavigation);

            _serviceView.AddRelationFilter("Articulo", new List<string> { "CodigoBarras", "ArticuloDescripcion" });
            _serviceView.AddRelationFilter("Periodo", new List<string> { "PeriodoNombre" });
            _serviceView.AddRelationFilter("Usuario", new List<string> { "UsuarioNombre" });
        }

        // ===== CONSULTAS =====
        public async Task<PagedResult<VwRegistroConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            var response = _mapper.Map<List<VwRegistroConteoResponse>>(result);
            return new PagedResult<VwRegistroConteoResponse>
            {
                Success = true,
                Items = response,
                TotalCount = response.Count
            };
        }

        public async Task<VwRegistroConteoResponse> GetByIdAsync(int id)
        {
            var registro = await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
            if (registro == null)
                throw new KeyNotFoundException($"Registro de conteo {id} no encontrado");

            return registro;
        }

        public async Task<PagedResult<VwRegistroConteoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<VwRegistroConteoResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        // ===== FILTRADOS =====
        public async Task<PagedResult<VwRegistroConteoResponse>> GetAllByArticuloAsync(int articuloId)
        {
            var parametros = new Dictionary<string, object> { ["articuloId"] = articuloId };
            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SearchString = "",
                SortLabel = "FechaConteo",
                SortDirection = "Descending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        public async Task<PagedResult<VwRegistroConteoResponse>> GetAllByPeriodoAsync(int periodoId)
        {
            var parametros = new Dictionary<string, object> { ["periodoId"] = periodoId };
            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SearchString = "",
                SortLabel = "FechaConteo",
                SortDirection = "Descending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        public async Task<PagedResult<VwRegistroConteoResponse>> GetAllByUsuarioAsync(int usuarioId)
        {
            var parametros = new Dictionary<string, object> { ["usuarioId"] = usuarioId };
            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SearchString = "",
                SortLabel = "FechaConteo",
                SortDirection = "Descending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        // ===== COMANDOS =====
        public async Task<VwRegistroConteoResponse> RegistrarConteoAsync(RegistroConteoDto registrarDto, int usuarioActual)
        {
            // 🔧 LÓGICA DE NEGOCIO: Validar y registrar conteo

            if (registrarDto.CantidadContada < 0)
                throw new ArgumentException("La cantidad no puede ser negativa");

            // Validar que el usuario no haya contado este artículo antes
            var yaConteo = await _service.GetQueryWithIncludes()
                .AnyAsync(r => r.FkidArticuloConteoAlma == registrarDto.FkidArticuloConteoAlma &&
                              r.FkidUsuarioSis == usuarioActual);

            if (yaConteo)
                throw new InvalidOperationException("Este usuario ya realizó un conteo para este artículo");

            // Mapear a DTO de creación
            var dto = new RegistroConteoDto
            {
                FkidArticuloConteoAlma = registrarDto.FkidArticuloConteoAlma,
                FkidPeriodoConteoAlma = registrarDto.FkidPeriodoConteoAlma,
                NumeroConteo = registrarDto.NumeroConteo,
                CantidadContada = registrarDto.CantidadContada,
                Observaciones = registrarDto.Observaciones,
                EsReconteo = registrarDto.EsReconteo,
                FkidUsuarioSis = usuarioActual,
                FechaConteo = DateTime.Now,
                Activo = true
            };

            await _service.AddAsync(dto);

            var registroCreado = await _serviceView.GetByIdAsync(dto.PkidRegistroConteo, idPropertyName: "Id");
            return registroCreado;
        }

        public async Task<VwRegistroConteoResponse> UpdateAsync(int id, RegistroConteoDto dto, int usuarioActual)
        {
            var registro = await _service.GetByIdAsync(id, idPropertyName: "PkidRegistroConteo");
            if (registro == null)
                throw new KeyNotFoundException($"Registro {id} no encontrado");

            // 🔧 LÓGICA: Solo se puede editar observaciones después de registrar
            if (string.IsNullOrEmpty(dto.Observaciones))
                dto.Observaciones = registro.Observaciones;

            dto.CantidadContada = registro.CantidadContada; // No permitir cambiar cantidad
            dto.FechaConteo = registro.FechaConteo;

            await _service.UpdateAsync(id, dto);

            return await GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var registro = await _service.GetByIdAsync(id, idPropertyName: "PkidRegistroConteo");
            if (registro == null)
                throw new KeyNotFoundException($"Registro {id} no encontrado");

            // 🔧 LÓGICA: Solo se puede eliminar si es el último conteo del artículo
            var otrosConteos = await _service.GetQueryWithIncludes()
                .Where(r => r.FkidArticuloConteoAlma == registro.ArticuloConteoId &&
                           r.PkidRegistroConteo != id)
                .CountAsync();

            if (otrosConteos > 0)
                throw new InvalidOperationException("No se puede eliminar: hay múltiples conteos para este artículo");

            await _service.DeleteAsync(id);
        }

        // ===== OPERACIONES ESPECÍFICAS =====
        public async Task<dynamic> ValidarYProcesarConteoAsync(int articuloId, decimal cantidadContada, int usuarioActual)
        {
            // 🔧 LÓGICA COMPLEJA: Determinar flujo del conteo (1º, 2º, 3º)

            var articulo = await _service.GetQueryWithIncludes()
                .Where(r => r.FkidArticuloConteoAlma == articuloId)
                .OrderByDescending(r => r.NumeroConteo)
                .FirstOrDefaultAsync();

            if (articulo == null)
                throw new KeyNotFoundException("Artículo no encontrado");

            var conteosRealizados = await _service.GetQueryWithIncludes()
                .Where(r => r.FkidArticuloConteoAlma == articuloId)
                .CountAsync();

            int proximoNumero = conteosRealizados + 1;

            // Obtener conteos anteriores para validación
            var conteosPrevios = await _service.GetQueryWithIncludes()
                .Where(r => r.FkidArticuloConteoAlma == articuloId)
                .OrderBy(r => r.NumeroConteo)
                .Select(r => r.CantidadContada)
                .ToListAsync();

            var resultado = new
            {
                NumeroConteo = proximoNumero,
                CantidadActual = cantidadContada,
                ConteosAnteriores = conteosPrevios,
                RequiereValidacion = false,
                Mensaje = ""
            };

            //// 🔧 REGLA: Si es 2º conteo, comparar con el 1º
            //if (proximoNumero == 2 && conteosPrevios.Count == 1)
            //{
            //    decimal primera = conteosPrevios[0];
            //    resultado.RequiereValidacion = primera != cantidadContada;

            //    if (resultado.RequiereValidacion)
            //    {
            //        resultado.Mensaje = $"Discrepancia detectada: 1º conteo={primera}, 2º conteo={cantidadContada}. Se requerirá 3º conteo.";
            //    }
            //    else
            //    {
            //        resultado.Mensaje = "Ambos conteos coinciden. El artículo se marca como concluido.";
            //    }
            //}

            //// 🔧 REGLA: Si es 3º conteo, resolver discrepancia
            //if (proximoNumero == 3)
            //{
            //    resultado.Mensaje = "Tercer conteo requerido para resolver discrepancia.";
            //}

            return resultado;
        }
    }
}
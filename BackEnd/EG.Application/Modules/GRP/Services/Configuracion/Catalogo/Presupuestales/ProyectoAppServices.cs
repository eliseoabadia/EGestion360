using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class ProyectoAppServices : IProyectoAppServices
    {
        private readonly GenericService<Py, ProyectoDto, ProyectoResponse> _service;
        private readonly Logger.Log4NetLogger _logger = new(typeof(ProyectoAppServices));

        public ProyectoAppServices(
            GenericService<Py, ProyectoDto, ProyectoResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueProyecto", async (dto) =>
            {
                var itemDto = dto as ProyectoDto;
                if (itemDto == null) return true;

                var clave = (itemDto.Clave ?? string.Empty).Trim().ToLower();
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => (p.Clave ?? string.Empty).ToLower() == clave && p.Activo);
            });

            _service.AddValidationRuleWithId("UniqueProyectoUpdate", async (dto, id) =>
            {
                var itemDto = dto as ProyectoDto;
                if (itemDto == null || !id.HasValue) return true;

                var clave = (itemDto.Clave ?? string.Empty).Trim().ToLower();
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => (p.Clave ?? string.Empty).ToLower() == clave && p.PkidPy != id.Value && p.Activo);
            });
        }

        public async Task<IEnumerable<ProyectoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<ProyectoResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPy");
        }

        public async Task<PagedResult<ProyectoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ProyectoResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                    items = items.Where(predicate);

                return new PagedResult<ProyectoResponse>
                {
                    Success = true,
                    Message = "Proyectos obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al obtener Proyectos: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(ProyectoAppServices),
                    string.Empty,
                    string.Empty);

                return new PagedResult<ProyectoResponse>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("obtener proyectos"),
                    Code = "ERROR",
                    Items = new List<ProyectoResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<ProyectoResponse> CreateAsync(ProyectoResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Proyecto son requeridos");

            response.Clave = response.Clave?.Trim() ?? string.Empty;
            response.Descripcion = response.Descripcion?.Trim() ?? string.Empty;

            var dto = response.Adapt<ProyectoDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un Proyecto activo con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidPy, idPropertyName: "PkidPy");
        }

        public async Task<ProyectoResponse> UpdateAsync(int id, ProyectoResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Proyecto son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Proyecto invalido", nameof(id));

            var existing = await _service.GetByIdAsync(id, idPropertyName: "PkidPy");
            if (existing == null)
                throw new KeyNotFoundException($"Proyecto con ID {id} no encontrado");

            response.Clave = response.Clave?.Trim() ?? string.Empty;
            response.Descripcion = response.Descripcion?.Trim() ?? string.Empty;

            var dto = response.Adapt<ProyectoDto>();
            dto.PkidPy = id;
            dto.UsuarioCreacion = existing.UsuarioCreacion;
            dto.FechaCreacion = existing.FechaCreacion;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro Proyecto activo con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidPy");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Proyecto invalido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidPy");
            if (entity == null)
                return false;

            var dto = entity.Adapt<ProyectoDto>();
            dto.Activo = false;
            dto.UsuarioCreacion = entity.UsuarioCreacion;
            dto.FechaCreacion = entity.FechaCreacion;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, dto);
            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidPy");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}

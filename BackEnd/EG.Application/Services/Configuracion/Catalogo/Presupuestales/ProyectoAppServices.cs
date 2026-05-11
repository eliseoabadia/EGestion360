using AutoMapper;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class ProyectoAppServices : IProyectoAppServices
    {
        private readonly GenericService<Proyecto, ProyectoDto, ProyectoResponse> _service;
        private readonly IMapper _mapper;

        public ProyectoAppServices(
            GenericService<Proyecto, ProyectoDto, ProyectoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueProyecto", async (dto) =>
            {
                var itemDto = dto as ProyectoDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Descripcion.ToLower() == itemDto.Descripcion.ToLower() && p.Activo);
            });

            _service.AddValidationRuleWithId("UniqueProyectoUpdate", async (dto, id) =>
            {
                var itemDto = dto as ProyectoDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(p => p.Descripcion.ToLower() == itemDto.Descripcion.ToLower() && p.PkidProyecto != id.Value && p.Activo);
            });
        }

        public async Task<IEnumerable<ProyectoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<ProyectoResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidProyecto");
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
                return new PagedResult<ProyectoResponse>
                {
                    Success = false,
                    Message = ex.Message,
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

            var dto = _mapper.Map<ProyectoDto>(response);
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un Proyecto activo con esa descripción");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidProyecto, idPropertyName: "PkidProyecto");
        }

        public async Task<ProyectoResponse> UpdateAsync(int id, ProyectoResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Proyecto son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Proyecto inválido", nameof(id));

            var dto = _mapper.Map<ProyectoDto>(response);
            dto.PkidProyecto = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro Proyecto activo con esa descripción");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidProyecto");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Proyecto inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidProyecto");
            if (entity == null)
                return false;

            var dto = _mapper.Map<ProyectoDto>(entity);
            dto.Activo = false;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, dto);
            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidProyecto");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}

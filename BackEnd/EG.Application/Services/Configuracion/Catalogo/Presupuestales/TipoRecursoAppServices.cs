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
    public class TipoRecursoAppServices : ITipoRecursoAppServices
    {
        private readonly GenericService<TipoRecurso, TipoRecursoDto, TipoRecursoResponse> _service;
        private readonly IMapper _mapper;

        public TipoRecursoAppServices(
            GenericService<TipoRecurso, TipoRecursoDto, TipoRecursoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueTipoRecurso", async (dto) =>
            {
                var itemDto = dto as TipoRecursoDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(t => t.Clave.ToLower() == itemDto.Clave.ToLower() && t.Activo);
            });

            _service.AddValidationRuleWithId("UniqueTipoRecursoUpdate", async (dto, id) =>
            {
                var itemDto = dto as TipoRecursoDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(t => t.Clave.ToLower() == itemDto.Clave.ToLower() && t.PkidTipoRecurso != id.Value && t.Activo);
            });
        }

        public async Task<IEnumerable<TipoRecursoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<TipoRecursoResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidTipoRecurso");
        }

        public async Task<PagedResult<TipoRecursoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<TipoRecursoResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                    items = items.Where(predicate);

                return new PagedResult<TipoRecursoResponse>
                {
                    Success = true,
                    Message = "Tipos de Recurso obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoRecursoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<TipoRecursoResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<TipoRecursoResponse> CreateAsync(TipoRecursoResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Tipo de Recurso son requeridos");

            var dto = _mapper.Map<TipoRecursoDto>(response);
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un Tipo de Recurso activo con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidTipoRecurso, idPropertyName: "PkidTipoRecurso");
        }

        public async Task<TipoRecursoResponse> UpdateAsync(int id, TipoRecursoResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Tipo de Recurso son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Tipo de Recurso inválido", nameof(id));

            var dto = _mapper.Map<TipoRecursoDto>(response);
            dto.PkidTipoRecurso = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro Tipo de Recurso activo con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidTipoRecurso");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Tipo de Recurso inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoRecurso");
            if (entity == null)
                return false;

            var dto = _mapper.Map<TipoRecursoDto>(entity);
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
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoRecurso");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}

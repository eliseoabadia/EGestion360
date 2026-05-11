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
    public class ActividadInstitucionalAppServices : IActividadInstitucionalAppServices
    {
        private readonly GenericService<ActividadInstitucional, ActividadInstitucionalDto, ActividadInstitucionalResponse> _service;
        private readonly IMapper _mapper;

        public ActividadInstitucionalAppServices(
            GenericService<ActividadInstitucional, ActividadInstitucionalDto, ActividadInstitucionalResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueActividad", async (dto) =>
            {
                var itemDto = dto as ActividadInstitucionalDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.Clave.ToLower() == itemDto.Clave.ToLower() && a.Activo);
            });

            _service.AddValidationRuleWithId("UniqueActividadUpdate", async (dto, id) =>
            {
                var itemDto = dto as ActividadInstitucionalDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.Clave.ToLower() == itemDto.Clave.ToLower() && a.PkidActividadInstitucional != id.Value && a.Activo);
            });
        }

        public async Task<IEnumerable<ActividadInstitucionalResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return result;
        }

        public async Task<ActividadInstitucionalResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidActividadInstitucional");
        }

        public async Task<PagedResult<ActividadInstitucionalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<ActividadInstitucionalResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                {
                    items = items.Where(predicate);
                }

                return new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = true,
                    Message = "Actividades Institucionales obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<ActividadInstitucionalResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<ActividadInstitucionalResponse> CreateAsync(ActividadInstitucionalResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos de la Actividad Institucional son requeridos");

            var dto = _mapper.Map<ActividadInstitucionalDto>(response);
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe una Actividad Institucional activa con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidActividadInstitucional, idPropertyName: "PkidActividadInstitucional");
        }

        public async Task<ActividadInstitucionalResponse> UpdateAsync(int id, ActividadInstitucionalResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos de la Actividad Institucional son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Actividad Institucional inválido", nameof(id));

            var dto = _mapper.Map<ActividadInstitucionalDto>(response);
            dto.PkidActividadInstitucional = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otra Actividad Institucional activa con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidActividadInstitucional");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Actividad Institucional inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidActividadInstitucional");
            if (entity == null)
                return false;

            var dto = _mapper.Map<ActividadInstitucionalDto>(entity);
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
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidActividadInstitucional");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}

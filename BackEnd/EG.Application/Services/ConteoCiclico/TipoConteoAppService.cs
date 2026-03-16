using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class TipoConteoAppService : ITipoConteoAppService
    {
        private readonly GenericService<TipoConteo, TipoConteoDto, TipoConteoResponse> _service;
        private readonly IMapper _mapper;

        public TipoConteoAppService(
            GenericService<TipoConteo, TipoConteoDto, TipoConteoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Si hay relaciones que siempre deban incluirse (ej: PeriodoConteos), se pueden agregar:
            // _service.AddInclude(t => t.PeriodoConteos);
            // Pero para un catálogo simple no es necesario.
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Nombre único (creación)
            _service.AddValidationRule("UniqueNombre", async (dto) =>
            {
                var tipoDto = dto as TipoConteoDto;
                if (tipoDto == null || string.IsNullOrWhiteSpace(tipoDto.Nombre))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(t => t.Nombre.ToLower() == tipoDto.Nombre.ToLower() && t.Activo);
                return !exists;
            });

            // REGLA 2: Nombre único (actualización)
            _service.AddValidationRuleWithId("UniqueNombreUpdate", async (dto, id) =>
            {
                var tipoDto = dto as TipoConteoDto;
                if (tipoDto == null || !id.HasValue || string.IsNullOrWhiteSpace(tipoDto.Nombre))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(t => t.Nombre.ToLower() == tipoDto.Nombre.ToLower() &&
                                   t.PkidTipoConteo != id.Value &&
                                   t.Activo);
                return !exists;
            });

            // REGLA 3: Nombre requerido
            _service.AddValidationRule("NombreRequerido", async (dto) =>
            {
                var tipoDto = dto as TipoConteoDto;
                return !string.IsNullOrWhiteSpace(tipoDto?.Nombre);
            });
        }

        public async Task<PagedResult<TipoConteoResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                var response = _mapper.Map<List<TipoConteoResponse>>(result);
                return new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Listado de tipos de conteo obtenido correctamente",
                    Code = "SUCCESS",
                    Items = response,
                    TotalCount = response.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<TipoConteoResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _service.GetByIdAsync(id, idPropertyName: "PkidTipoConteo");
            }
            catch
            {
                return null;
            }
        }

        public async Task<PagedResult<TipoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<TipoConteoResponse>
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
                return new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<TipoConteoResponse> CreateAsync(TipoConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del tipo de conteo son requeridos");

            dto.Activo = true;
            // Si tuviera campos de auditoría, se asignarían aquí:
            // dto.FechaCreacion = DateTime.Now;
            // dto.UsuarioCreacion = usuarioActual;

            if (!await _service.CanAddAsync(dto))
            {
                var existeNombre = await _service.GetQueryWithIncludes()
                    .AnyAsync(t => t.Nombre.ToLower() == dto.Nombre.ToLower() && t.Activo);
                if (existeNombre)
                    throw new InvalidOperationException($"El nombre '{dto.Nombre}' ya está registrado para otro tipo de conteo activo");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidTipoConteo);
        }

        public async Task<TipoConteoResponse> UpdateAsync(int id, TipoConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del tipo de conteo son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID de tipo de conteo inválido", nameof(id));

            dto.PkidTipoConteo = id;
            // Si tuviera campos de auditoría:
            // dto.FechaModificacion = DateTime.Now;
            // dto.UsuarioModificacion = usuarioActual;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                var existeNombre = await _service.GetQueryWithIncludes()
                    .AnyAsync(t => t.Nombre.ToLower() == dto.Nombre.ToLower() &&
                                   t.PkidTipoConteo != id &&
                                   t.Activo);
                if (existeNombre)
                    throw new InvalidOperationException($"El nombre '{dto.Nombre}' ya está registrado para otro tipo de conteo activo");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de tipo de conteo inválido", nameof(id));

            var _tipoConteo = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoConteo");
            if (_tipoConteo == null)
                throw new InvalidOperationException("Tipo de conteo no encontrado");

            var tipoDto = _mapper.Map<TipoConteoDto>(_tipoConteo);

            // Soft delete
            tipoDto.Activo = false;
            // Si hay auditoría:
            // tipoDto.FechaModificacion = DateTime.Now;
            // tipoDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, tipoDto);
            return true;
        }
    }
}
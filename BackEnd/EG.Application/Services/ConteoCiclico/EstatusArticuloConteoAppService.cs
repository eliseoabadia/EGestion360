using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class EstatusArticuloConteoAppService : IEstatusArticuloConteoAppService
    {
        private readonly GenericService<EstatusArticuloConteo, EstatusArticuloConteoDto, EstatusArticuloConteoResponse> _service;
        private readonly IMapper _mapper;

        public EstatusArticuloConteoAppService(
            GenericService<EstatusArticuloConteo, EstatusArticuloConteoDto, EstatusArticuloConteoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Si la entidad tiene relaciones que siempre deben incluirse, agrégalas aquí.
            // Ejemplo: _service.AddInclude(e => e.ArticuloConteos);

            // Configurar filtros de relación para búsquedas dinámicas (opcional)
            // _service.AddRelationFilter("ArticuloConteos", new List<string> { "Codigo", "Descripcion" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Nombre único (creación)
            _service.AddValidationRule("UniqueNombre", async (dto) =>
            {
                var estatusDto = dto as EstatusArticuloConteoDto;
                if (estatusDto == null || string.IsNullOrWhiteSpace(estatusDto.Nombre))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(e => e.Nombre.ToLower() == estatusDto.Nombre.ToLower() && e.Activo);
                return !exists;
            });

            // REGLA 2: Nombre único (actualización)
            _service.AddValidationRuleWithId("UniqueNombreUpdate", async (dto, id) =>
            {
                var estatusDto = dto as EstatusArticuloConteoDto;
                if (estatusDto == null || !id.HasValue || string.IsNullOrWhiteSpace(estatusDto.Nombre))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(e => e.Nombre.ToLower() == estatusDto.Nombre.ToLower() &&
                                   e.PkidEstatusArticulo != id.Value &&
                                   e.Activo);
                return !exists;
            });

            // REGLA 3: Nombre obligatorio
            _service.AddValidationRule("NombreRequerido", async (dto) =>
            {
                var estatusDto = dto as EstatusArticuloConteoDto;
                return !string.IsNullOrWhiteSpace(estatusDto?.Nombre);
            });

            // REGLA 4: Orden debe ser un número positivo (opcional)
            _service.AddValidationRule("OrdenPositivo", async (dto) =>
            {
                var estatusDto = dto as EstatusArticuloConteoDto;
                return estatusDto?.Orden >= 0;
            });
        }

        public async Task<PagedResult<EstatusArticuloConteoResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                var response = _mapper.Map<List<EstatusArticuloConteoResponse>>(result);
                return new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Listado de estatus obtenido correctamente",
                    Code = "SUCCESS",
                    Items = response,
                    TotalCount = response.Count
                };
            }
            catch (Exception ex)
            {
                // Reemplazar con ILogger si está disponible
                return new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<EstatusArticuloConteoResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _service.GetByIdAsync(id, idPropertyName: "PkidEstatusArticulo");
            }
            catch
            {
                return null;
            }
        }

        public async Task<PagedResult<EstatusArticuloConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<EstatusArticuloConteoResponse>
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
                return new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<EstatusArticuloConteoResponse> CreateAsync(EstatusArticuloConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del estatus son requeridos");

            // Asignar valores de auditoría
            dto.Activo = true;
            // Si tu entidad tiene campos de auditoría (FechaCreacion, UsuarioCreacion), descomenta:
            // dto.FechaCreacion = DateTime.Now;
            // dto.UsuarioCreacion = usuarioActual;

            if (!await _service.CanAddAsync(dto))
            {
                // Validación manual de duplicado por nombre
                var existeNombre = await _service.GetQueryWithIncludes()
                    .AnyAsync(e => e.Nombre.ToLower() == dto.Nombre.ToLower() && e.Activo);
                if (existeNombre)
                    throw new InvalidOperationException($"El nombre '{dto.Nombre}' ya está registrado para otro estatus activo");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidEstatusArticulo);
        }

        public async Task<EstatusArticuloConteoResponse> UpdateAsync(int id, EstatusArticuloConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del estatus son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID de estatus inválido", nameof(id));

            dto.PkidEstatusArticulo = id;
            // Si hay campos de auditoría de modificación:
            // dto.FechaModificacion = DateTime.Now;
            // dto.UsuarioModificacion = usuarioActual;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                var existeNombre = await _service.GetQueryWithIncludes()
                    .AnyAsync(e => e.Nombre.ToLower() == dto.Nombre.ToLower() &&
                                   e.PkidEstatusArticulo != id &&
                                   e.Activo);
                if (existeNombre)
                    throw new InvalidOperationException($"El nombre '{dto.Nombre}' ya está registrado para otro estatus activo");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de estatus inválido", nameof(id));

            var _estatus = await _service.GetByIdAsync(id, idPropertyName: "PkidEstatusArticulo");
            if (_estatus == null)
                throw new InvalidOperationException("Estatus no encontrado");

            var estatusDto = _mapper.Map<EstatusArticuloConteoDto>(_estatus);

            //// Soft delete
            //estatusDto.Activo = false;
            //// Si hay campos de auditoría:
            //estatusDto.FechaModificacion = DateTime.Now;
            //estatusDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, estatusDto);
            return true;
        }
    }
}
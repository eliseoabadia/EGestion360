using AutoMapper;
using EG.Application.Interfaces.Almacen;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Almacen
{
    public class FamiliaService : IFamiliaService
    {
        private readonly GenericService<Familium, FamiliaDto, FamiliaResponse> _service;
        private readonly IMapper _mapper;

        public FamiliaService(
            GenericService<Familium, FamiliaDto, FamiliaResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            // Ejemplo: Validar que la descripción no esté vacía (puedes agregar las reglas que necesites)
            _service.AddValidationRule("DescripcionRequerida", async (dto) =>
            {
                var familiaDto = dto as FamiliaDto;
                return !string.IsNullOrWhiteSpace(familiaDto?.Descripcion);
            });

            // Ejemplo: Clave única (opcional)
            _service.AddValidationRule("ClaveUnica", async (dto) =>
            {
                var familiaDto = dto as FamiliaDto;
                if (familiaDto == null || string.IsNullOrWhiteSpace(familiaDto.Clave))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(f => f.Clave == familiaDto.Clave && f.Activo);
                return !exists;
            });

            _service.AddValidationRuleWithId("ClaveUnicaUpdate", async (dto, id) =>
            {
                var familiaDto = dto as FamiliaDto;
                if (familiaDto == null || !id.HasValue || string.IsNullOrWhiteSpace(familiaDto.Clave))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(f => f.Clave == familiaDto.Clave &&
                                   f.PkidFamilia != id.Value &&
                                   f.Activo);
                return !exists;
            });
        }

        // ==================== CONSULTAS ====================

        public async Task<PagedResult<FamiliaResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Listado de familias obtenido correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<FamiliaResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _service.GetByIdAsync(id, idPropertyName: "PkidFamilia");
            }
            catch
            {
                return null;
            }
        }

        public async Task<PagedResult<FamiliaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                // Se asume que el método GetAllPaginadoAsync del servicio genérico ya retorna un PagedResult<FamiliaResponse>
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                // Si ya viene con Success, Message, etc., se puede retornar directamente
                return result;
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        // ==================== ESCRITURA ====================

        public async Task<FamiliaResponse> CreateAsync(FamiliaDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos de la familia son requeridos");

            // Asignar valores de auditoría
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioActual;
            dto.Activo = true;

            // Validar reglas de negocio
            if (!await _service.CanAddAsync(dto))
            {
                // Puedes personalizar el mensaje según la validación que falló
                throw new InvalidOperationException("No se puede crear la familia. Verifique las validaciones.");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidFamilia);
        }

        public async Task<FamiliaResponse> UpdateAsync(int id, FamiliaDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos de la familia son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID de familia inválido", nameof(id));

            dto.PkidFamilia = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                throw new InvalidOperationException("No se puede actualizar la familia. Verifique las validaciones.");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de familia inválido", nameof(id));

            var familia = await _service.GetByIdAsync(id, idPropertyName: "PkidFamilia");
            if (familia == null)
                throw new InvalidOperationException("Familia no encontrada");

            var familiaDto = _mapper.Map<FamiliaDto>(familia);
            // Soft delete
            familiaDto.Activo = false;
            familiaDto.FechaModificacion = DateTime.Now;
            familiaDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, familiaDto);
            return true;
        }
    }
}
using AutoMapper;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Catalogos.ClavePrograma
{
    public class GfService : IGfService
    {
        private readonly GenericService<Gf, GfDto, GfResponse> _service;
        private readonly IMapper _mapper;

        public GfService(
            GenericService<Gf, GfDto, GfResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Si Gf tiene navegaciones necesarias para búsquedas, agrégales aquí
            // _service.AddInclude(g => g.UsuarioCreacionNavigation);
            // _service.AddRelationFilter("UsuarioCreacionNavigation", new List<string> { "Nombre" });
        }

        private void ConfigureValidations()
        {
            // 1. Clave única (para creación)
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var gfDto = dto as GfDto;
                if (gfDto == null) return true;
                return !await _service.GetQueryWithIncludes().AnyAsync(e => e.Clave == gfDto.Clave && e.Activo);
            });

            // 2. Clave única en actualización (excluyendo el registro actual)
            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var gfDto = dto as GfDto;
                if (gfDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes().AnyAsync(e => e.Clave == gfDto.Clave && e.PkidGf != id.Value && e.Activo);
            });

            // 3. Descripción única (case-insensitive) para creación
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                var gfDto = dto as GfDto;
                if (gfDto == null) return true;
                return !await _service.GetQueryWithIncludes().AnyAsync(e => e.Descripcion.ToLower() == gfDto.Descripcion.ToLower() && e.Activo);
            });

            // 4. Descripción única en actualización
            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                var gfDto = dto as GfDto;
                if (gfDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes().AnyAsync(e => e.Descripcion.ToLower() == gfDto.Descripcion.ToLower() && e.PkidGf != id.Value && e.Activo);
            });

            // 5. Descripción no vacía y longitud entre 3 y 200
            _service.AddValidationRule("ValidDescripcionLength", async (dto) =>
            {
                var gfDto = dto as GfDto;
                if (gfDto == null) return false;
                return !string.IsNullOrWhiteSpace(gfDto.Descripcion) &&
                       gfDto.Descripcion.Length >= 3 &&
                       gfDto.Descripcion.Length <= 200;
            });

            // 6. Clave debe ser mayor a 0
            _service.AddValidationRule("ValidClave", async (dto) =>
            {
                var gfDto = dto as GfDto;
                return gfDto?.Clave > 0;
            });
        }

        public async Task<IEnumerable<GfResponse>> GetAllAsync()
        {
            var entities = await _service.GetAllAsync();
            return entities.ToList();
        }

        public async Task<GfResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<GfResponse> AddAsync(GfDto dto, int usuarioCreacion)
        {
            // Asignar auditoría
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;

            // Validar todas las reglas de negocio
            if (!await _service.CanAddAsync(dto))
            {
            }
                await _service.AddAsync(dto);

            // Obtener usuario creado
            var _result = await _service.GetByIdAsync(dto.PkidGf, idPropertyName: "PkidGf");
            return _result;
        }

        public async Task UpdateAsync(int id, GfDto dto, int usuarioModificacion)
        {
            // Asignar auditoría
            dto.UsuarioModificacion = usuarioModificacion;
            dto.FechaModificacion = DateTime.Now;

            // Validar todas las reglas de negocio
            //if (!await _service.CanUpdateAsync(dto))
            //{
            //}
            await _service.UpdateAsync(id, dto);


        }

        public async Task DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
        }

        public async Task<PagedResult<GfResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            // Limpiar configuración previa y reaplicar includes/validaciones
            _service.ClearConfiguration();
            ConfigureService();
            ConfigureValidations();

            return await _service.GetAllPaginadoAsync(request);
        }

        public async Task<bool> CanAddAsync(GfDto dto)
        {
            return await _service.CanAddAsync(dto);
        }

        public async Task<bool> CanUpdateAsync(int id, GfDto dto)
        {
            return await _service.CanUpdateAsync(id, dto);
        }
    }
}
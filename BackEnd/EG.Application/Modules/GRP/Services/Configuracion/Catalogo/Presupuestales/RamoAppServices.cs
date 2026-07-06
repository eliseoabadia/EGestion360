using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class RamoAppServices : IRamoAppServices
    {
        private readonly GenericService<Ramo, RamoDto, RamoResponse> _service;

        public RamoAppServices(GenericService<Ramo, RamoDto, RamoResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueRamo", async dto =>
                !await _service.GetQueryWithIncludes()
                    .AnyAsync(r => r.Clave == dto.Clave && r.Activo));

            _service.AddValidationRuleWithId("UniqueRamoUpdate", async (dto, id) =>
                !id.HasValue ||
                !await _service.GetQueryWithIncludes()
                    .AnyAsync(r => r.Clave == dto.Clave && r.PkidRamo != id.Value && r.Activo));
        }

        public async Task<IEnumerable<RamoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<RamoResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidRamo");
        }

        public async Task<PagedResult<RamoResponse>> GetAllPaginadoAsync(
            PagedRequest pageRequest,
            Func<RamoResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                {
                    items = items.Where(predicate);
                }

                return new PagedResult<RamoResponse>
                {
                    Success = result.Success,
                    Message = result.Success ? "Ramos obtenidos correctamente" : result.Message,
                    Code = result.Success ? "SUCCESS" : result.Code,
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RamoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<RamoResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<RamoResponse> CreateAsync(RamoResponse response, int usuarioCreacion)
        {
            ArgumentNullException.ThrowIfNull(response);

            var dto = response.Adapt<RamoDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
            {
                throw new InvalidOperationException("Ya existe un Ramo activo con esa clave");
            }

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidRamo, idPropertyName: "PkidRamo");
        }

        public async Task<RamoResponse> UpdateAsync(int id, RamoResponse response, int usuarioModificacion)
        {
            ArgumentNullException.ThrowIfNull(response);

            if (id <= 0)
            {
                throw new ArgumentException("ID de Ramo invalido", nameof(id));
            }

            var dto = response.Adapt<RamoDto>();
            dto.PkidRamo = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                throw new InvalidOperationException("Ya existe otro Ramo activo con esa clave");
            }

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidRamo");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
            {
                throw new ArgumentException("ID de Ramo invalido", nameof(id));
            }

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidRamo");
            if (entity == null)
            {
                return false;
            }

            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidRamo");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}

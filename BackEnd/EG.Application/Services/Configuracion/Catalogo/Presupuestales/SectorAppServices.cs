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
    public class SectorAppServices : ISectorAppServices
    {
        private readonly GenericService<Sector, SectorDto, SectorResponse> _service;

        public SectorAppServices(
            GenericService<Sector, SectorDto, SectorResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueSector", async (dto) =>
            {
                var itemDto = dto as SectorDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(s => s.Clave.ToLower() == itemDto.Clave.ToLower() && s.Activo);
            });

            _service.AddValidationRuleWithId("UniqueSectorUpdate", async (dto, id) =>
            {
                var itemDto = dto as SectorDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(s => s.Clave.ToLower() == itemDto.Clave.ToLower() && s.PkidSector != id.Value && s.Activo);
            });
        }

        public async Task<IEnumerable<SectorResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<SectorResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidSector");
        }

        public async Task<PagedResult<SectorResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<SectorResponse, bool>? predicate = null)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(pageRequest);
                var items = result.Items.AsEnumerable();

                if (predicate != null)
                    items = items.Where(predicate);

                return new PagedResult<SectorResponse>
                {
                    Success = true,
                    Message = "Sectores obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items.ToList(),
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<SectorResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<SectorResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<SectorResponse> CreateAsync(SectorResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Sector son requeridos");

            var dto = response.Adapt<SectorDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un Sector activo con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidSector, idPropertyName: "PkidSector");
        }

        public async Task<SectorResponse> UpdateAsync(int id, SectorResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del Sector son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de Sector inválido", nameof(id));

            var dto = response.Adapt<SectorDto>();
            dto.PkidSector = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro Sector activo con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidSector");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de Sector inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidSector");
            if (entity == null)
                return false;

            var dto = entity.Adapt<SectorDto>();
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
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidSector");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}

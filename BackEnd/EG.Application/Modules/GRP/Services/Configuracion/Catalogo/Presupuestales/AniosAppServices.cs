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
    public class AniosAppServices : IAniosAppServices
    {
        private readonly GenericService<Anio, AniosDto, AniosResponse> _service;

        public AniosAppServices(GenericService<Anio, AniosDto, AniosResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueAnio", async dto =>
                !await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.Clave == dto.Clave && a.Activo));

            _service.AddValidationRuleWithId("UniqueAnioUpdate", async (dto, id) =>
                !id.HasValue ||
                !await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.Clave == dto.Clave && a.PkidAnio != id.Value && a.Activo));
        }

        public async Task<IEnumerable<AniosResponse>> GetAllAsync()
        {
            return await _service.GetQueryWithIncludes()
                .OrderByDescending(x => x.Clave)
                .ProjectToType<AniosResponse>()
                .ToListAsync();
        }

        public async Task<AniosResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
        }

        public async Task<PagedResult<AniosResponse>> GetAllPaginadoAsync(
            PagedRequest pageRequest,
            Func<AniosResponse, bool>? predicate = null)
        {
            try
            {
                pageRequest.Page = pageRequest.Page < 1 ? 1 : pageRequest.Page;
                pageRequest.PageSize = pageRequest.PageSize < 1 ? 100 : pageRequest.PageSize;
                pageRequest.SortLabel = NormalizeSortLabel(pageRequest.SortLabel);

                var result = !string.IsNullOrWhiteSpace(pageRequest.Filtro) &&
                    int.TryParse(pageRequest.Filtro.Trim(), out var clave)
                        ? await _service.GetAllPaginadoAsync(pageRequest, x => x.Clave == clave)
                        : await _service.GetAllPaginadoAsync(pageRequest);

                var items = result.Items.ToList();
                if (predicate != null)
                {
                    items = items.Where(predicate).ToList();
                }

                return new PagedResult<AniosResponse>
                {
                    Success = result.Success,
                    Message = result.Success ? "Anios obtenidos correctamente" : result.Message,
                    Code = result.Success ? "SUCCESS" : result.Code,
                    Items = items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<AniosResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<AniosResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<AniosResponse> CreateAsync(AniosResponse response, int usuarioCreacion)
        {
            ArgumentNullException.ThrowIfNull(response);

            var dto = response.Adapt<AniosDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
            {
                throw new InvalidOperationException("Ya existe un anio activo con esa clave");
            }

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidAnio, idPropertyName: "PkidAnio");
        }

        public async Task<AniosResponse> UpdateAsync(int id, AniosResponse response, int usuarioModificacion)
        {
            ArgumentNullException.ThrowIfNull(response);

            if (id <= 0)
            {
                throw new ArgumentException("ID de anio invalido", nameof(id));
            }

            var dto = response.Adapt<AniosDto>();
            dto.PkidAnio = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                throw new InvalidOperationException("Ya existe otro anio activo con esa clave");
            }

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
            {
                throw new ArgumentException("ID de anio invalido", nameof(id));
            }

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
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
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }

        private static string NormalizeSortLabel(string? sortLabel)
        {
            return sortLabel?.ToLowerInvariant() switch
            {
                "pkidanio" => "PkidAnio",
                "activo" => "Activo",
                "fechacreacion" => "FechaCreacion",
                "descripcion" => "Clave",
                "" or null => "Clave",
                _ => sortLabel
            };
        }
    }
}

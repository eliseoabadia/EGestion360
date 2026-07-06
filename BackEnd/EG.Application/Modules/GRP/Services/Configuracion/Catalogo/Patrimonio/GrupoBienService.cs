using Mapster;
using Microsoft.EntityFrameworkCore;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio
{
    public class GrupoBienService : IGrupoBienService
    {
        private readonly GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> _service;
        private readonly GenericService<VwGrupoBien, GrupoBienDto, GrupoBienResponse> _serviceView;

        public GrupoBienService(
            GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> service,
            GenericService<VwGrupoBien, GrupoBienDto, GrupoBienResponse> serviceView)
        {
            _service = service;
            _serviceView = serviceView;
            _service.AddInclude(entity => entity.FkidFamiliaAlmaNavigation);
            _service.AddRelationFilter(nameof(GrupoBien.FkidFamiliaAlmaNavigation), [nameof(Familium.Descripcion), nameof(Familium.Clave)]);
            ConfigureValidations();
        }

        public async Task<PagedResult<GrupoBienResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return new PagedResult<GrupoBienResponse>
            {
                Items = items,
                TotalCount = items.Count,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }

        public async Task<PagedResult<GrupoBienResponse>> GetByIdAsync(int id)
        {
            var response = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidGrupoBien");
            if (response == null)
            {
                return new PagedResult<GrupoBienResponse>
                {
                    Success = false,
                    Message = "Grupo de bien no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            return new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Data = response,
                Items = new List<GrupoBienResponse> { response },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<GrupoBienResponse>> CreateAsync(GrupoBienResponse request)
        {
            try
            {
                var dto = request.Adapt<GrupoBienDto>();
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Failure<GrupoBienResponse>("Ya existe un grupo de bien con esa descripcion", "DUPLICATE");
                }

                await _service.AddAsync(dto);
                var created = await GetByIdAsync(dto.PkidGrupoBien);
                created.Message = "Grupo de bien creado correctamente";
                return created;
            }
            catch (Exception ex)
            {
                return Failure<GrupoBienResponse>(ex.Message);
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> UpdateAsync(int id, GrupoBienResponse request)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id, idPropertyName: "PkidGrupoBien");
                if (existing == null)
                {
                    return Failure<GrupoBienResponse>("Grupo de bien no encontrado", "NOT_FOUND");
                }

                var dto = request.Adapt<GrupoBienDto>();
                dto.PkidGrupoBien = id;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Failure<GrupoBienResponse>("Ya existe otro grupo de bien con esa descripcion", "DUPLICATE");
                }

                await _service.UpdateAsync(id, dto);
                var updated = await GetByIdAsync(id);
                updated.Message = "Grupo de bien actualizado correctamente";
                return updated;
            }
            catch (Exception ex)
            {
                return Failure<GrupoBienResponse>(ex.Message);
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id, idPropertyName: "PkidGrupoBien");
                if (existing == null)
                {
                    return Failure<bool>("Grupo de bien no encontrado", "NOT_FOUND");
                }

                await _service.DeleteAsync(id);
                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Grupo de bien eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return Failure<bool>(ex.Message);
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            request.SortLabel = request.SortLabel switch
            {
                "GrupoBienDescripcion" => "Descripcion",
                "GrupoBienClave" => "Clave",
                _ => request.SortLabel
            };

            var result = await _serviceView.GetAllPaginadoAsync(request);
            result.Message = result.Success ? "OK" : result.Message;
            result.Code = result.Success ? "SUCCESS" : result.Code;
            return result;
        }

        public async Task<PagedResult<GrupoBienResponse>> GetGrupoBienAsync()
        {
            var items = await _service.GetQueryWithIncludes(g => (g.Clave ?? 0) > 2000)
                .OrderBy(g => g.ClaveCucop)
                .ToListAsync();

            var mapped = items.Adapt<List<GrupoBienResponse>>();
            return new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Items = mapped,
                TotalCount = mapped.Count
            };
        }

        public async Task<List<LookupItem>> GetLookupAsync()
        {
            return await _service.GetQueryWithIncludes(g => (g.Clave ?? 0) > 2000)
                .OrderBy(g => g.ClaveAn)
                .Select(g => new LookupItem
                {
                    Id = g.PkidGrupoBien,
                    Text = (g.ClaveAn ?? string.Empty) + " / " + (g.CabmAct ?? string.Empty) + " / " + (g.Descripcion ?? string.Empty)
                })
                .ToListAsync();
        }

        public async Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page = 1, int pageSize = 25, string? filter = null)
        {
            page = Math.Max(page, 1);
            pageSize = Math.Clamp(pageSize, 1, 100);

            var query = _service.GetQueryWithIncludes(g => (g.Clave ?? 0) > 2000)
                .OrderBy(g => g.ClaveAn)
                .Select(g => new LookupItem
                {
                    Id = g.PkidGrupoBien,
                    Text = (g.ClaveAn ?? string.Empty) + " / " + (g.CabmAct ?? string.Empty) + " / " + (g.Descripcion ?? string.Empty)
                });

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = filter.Trim();
                query = query.Where(x => x.Text.Contains(term));
            }

            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Items = items,
                TotalCount = totalCount
            };
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", dto =>
                Task.FromResult(!_service.GetQueryWithIncludes()
                    .Any(entity => entity.Descripcion.ToLower() == dto.Descripcion.ToLower() && entity.Activo)));

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", (dto, id) =>
                Task.FromResult(!_service.GetQueryWithIncludes()
                    .Any(entity => entity.Descripcion.ToLower() == dto.Descripcion.ToLower() &&
                        entity.PkidGrupoBien != id!.Value &&
                        entity.Activo)));
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };
    }
}

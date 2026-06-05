using System.Text.Json;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class BienDisponibleBajaAppService : IBienDisponibleBajaAppService
    {
        private readonly GenericService<VwBienesDisponiblesBaja, BienDisponibleBajaDto, BienDisponibleBajaResponse> _serviceView;

        public BienDisponibleBajaAppService(
            GenericService<VwBienesDisponiblesBaja, BienDisponibleBajaDto, BienDisponibleBajaResponse> serviceView)
        {
            _serviceView = serviceView;
        }

        public async Task<PagedResult<BienDisponibleBajaResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return Success(items, "Bienes disponibles para baja obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<BienDisponibleBajaResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidBien");
            if (item == null)
            {
                return Failure<BienDisponibleBajaResponse>($"Bien disponible con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<BienDisponibleBajaResponse>
            {
                Success = true,
                Message = "Bien disponible encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<BienDisponibleBajaResponse> { item },
                TotalCount = 1
            };
        }

        public Task<PagedResult<BienDisponibleBajaResponse>> CreateAsync(BienDisponibleBajaResponse response, int usuarioActual)
        {
            return Task.FromResult(Failure<BienDisponibleBajaResponse>("La vista de bienes disponibles es de solo lectura.", "READ_ONLY"));
        }

        public Task<PagedResult<BienDisponibleBajaResponse>> UpdateAsync(int id, BienDisponibleBajaResponse response, int usuarioActual)
        {
            return Task.FromResult(Failure<BienDisponibleBajaResponse>("La vista de bienes disponibles es de solo lectura.", "READ_ONLY"));
        }

        public Task<PagedResult<bool>> DeleteAsync(int id)
        {
            return Task.FromResult(new PagedResult<bool>
            {
                Success = false,
                Message = "La vista de bienes disponibles es de solo lectura.",
                Code = "READ_ONLY",
                Data = false,
                TotalCount = 0
            });
        }

        public async Task<PagedResult<BienDisponibleBajaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (TryGetIntFilter(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Clave != null && x.Clave.Contains(filtro)) ||
                        (x.ClaveAnt != null && x.ClaveAnt.Contains(filtro)) ||
                        (x.Descripcion != null && x.Descripcion.Contains(filtro)) ||
                        (x.Serie != null && x.Serie.Contains(filtro)) ||
                        (x.Factura != null && x.Factura.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<BienDisponibleBajaResponse>>(), "Bienes disponibles para baja obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<BienDisponibleBajaResponse>($"Error al obtener bienes disponibles: {ex.Message}");
            }
        }

        private static IQueryable<VwBienesDisponiblesBaja> ApplySort(IQueryable<VwBienesDisponiblesBaja> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Clave" => ascending ? query.OrderBy(x => x.Clave) : query.OrderByDescending(x => x.Clave),
                "Descripcion" => ascending ? query.OrderBy(x => x.Descripcion) : query.OrderByDescending(x => x.Descripcion),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "ValorActual" => ascending ? query.OrderBy(x => x.ValorActual) : query.OrderByDescending(x => x.ValorActual),
                _ => ascending ? query.OrderByDescending(x => x.PkidBien) : query.OrderBy(x => x.PkidBien)
            };
        }

        private static PagedResult<BienDisponibleBajaResponse> Success(List<BienDisponibleBajaResponse> items, string message, int total)
        {
            return new PagedResult<BienDisponibleBajaResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = items,
                TotalCount = total
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR")
            where T : class
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }

        private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                {
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return int.TryParse(raw.ToString(), out value);
        }
    }
}

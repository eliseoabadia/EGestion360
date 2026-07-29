using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public sealed class CedulaDiferenciasAppService(
        EGestionContext context,
        IUserContextService userContext) : ICedulaDiferenciasAppService
    {
        public async Task<PagedResult<CedulaDiferenciaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var scope = await PatrimonioScopeResolver.RequireAsync(context, userContext);
                if (!PatrimonioPagedFilter.TryGetInt(request, "FkidAreaSis", out var areaId) || areaId <= 0)
                {
                    return Failure("Debe seleccionar un área para consultar la cédula de diferencias.", "AREA_REQUIRED");
                }

                var area = await context.Areas.AsNoTracking()
                    .Where(x => x.PkidArea == areaId && x.Activo)
                    .Select(x => new { x.PkidArea, x.Nombre })
                    .FirstOrDefaultAsync();
                if (area == null)
                {
                    return Failure("El área seleccionada no existe o está inactiva.", "NOT_FOUND");
                }

                var inventarioHistoricoId = await context.InventarioHists.AsNoTracking()
                    .Where(x => x.Activo && x.FkidEmpresaSis == scope.EmpresaId && x.FkidAreaSis == areaId)
                    .OrderByDescending(x => x.FechaHist)
                    .ThenByDescending(x => x.PkidInventarioHist)
                    .Select(x => (int?)x.FkidInventarioAlma)
                    .FirstOrDefaultAsync();
                if (!inventarioHistoricoId.HasValue)
                {
                    return Success([], "No existe un inventario histórico previo para comparar el área seleccionada.");
                }

                var inventariosActuales = context.Inventarios.AsNoTracking()
                    .Where(x => x.Activo && x.FkidEmpresaSis == scope.EmpresaId && x.FkidAreaSis == areaId &&
                        x.FkidCalendarioInventarioAlmaNavigation != null &&
                        x.FkidCalendarioInventarioAlmaNavigation.Anio == scope.Anio)
                    .Select(x => x.PkidInventario);

                var bienesActuales = context.InventarioDetalles.AsNoTracking()
                    .Where(x => x.Activo && inventariosActuales.Contains(x.FkidInventarioAlma))
                    .Select(x => x.FkidBienAlma);
                var bienesHistoricos = context.InventarioDetHists.AsNoTracking()
                    .Where(x => x.Activo && x.FkidInventarioAlma == inventarioHistoricoId.Value)
                    .Select(x => x.FkidBienAlma);

                var query = context.Biens.AsNoTracking()
                    .Where(x => x.FkidEmpresaSis == scope.EmpresaId &&
                        (bienesActuales.Contains(x.PkidBien) || bienesHistoricos.Contains(x.PkidBien)))
                    .Select(x => new CedulaDiferenciaResponse
                    {
                        Tipo = bienesActuales.Contains(x.PkidBien)
                            ? (bienesHistoricos.Contains(x.PkidBien) ? "Inventariados" : "Sobrantes")
                            : "Faltantes",
                        FkidAreaSis = area.PkidArea,
                        AreaNombre = area.Nombre ?? string.Empty,
                        FkidBienAlma = x.PkidBien,
                        Clave = x.Clave ?? string.Empty,
                        Descripcion = x.Descripcion ?? string.Empty,
                        TipoBienClave = x.FkidTipoBienAlmaNavigation.CodigoClave ?? string.Empty,
                        TipoBienDescripcion = x.FkidTipoBienAlmaNavigation.Descripcion ?? string.Empty,
                        TipoPatrimonio = x.FkidTipoPatrimonioAlmaNavigation != null
                            ? x.FkidTipoPatrimonioAlmaNavigation.Descripcion
                            : string.Empty,
                        Resguardante = x.ResguardoDetalle != null && x.ResguardoDetalle.Activo
                            ? x.ResguardoDetalle.FkidResguardoAlmaNavigation.Responsable
                            : "Sin resguardo"
                    });

                var filter = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filter))
                {
                    query = query.Where(x => x.Tipo.Contains(filter) || x.Clave.Contains(filter) ||
                        x.Descripcion.Contains(filter) || x.TipoBienClave.Contains(filter) ||
                        x.TipoBienDescripcion.Contains(filter) || x.Resguardante.Contains(filter));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);
                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 20 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                return Success(items, "Cédula de diferencias obtenida correctamente.", total);
            }
            catch (Exception ex)
            {
                return Failure($"Error al obtener la cédula de diferencias: {ex.Message}");
            }
        }

        private static IQueryable<CedulaDiferenciaResponse> ApplySort(IQueryable<CedulaDiferenciaResponse> query, string? label, string? direction)
        {
            var ascending = string.IsNullOrEmpty(direction) || direction.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return label switch
            {
                "Tipo" => ascending ? query.OrderBy(x => x.Tipo) : query.OrderByDescending(x => x.Tipo),
                "Clave" => ascending ? query.OrderBy(x => x.Clave) : query.OrderByDescending(x => x.Clave),
                "Descripcion" => ascending ? query.OrderBy(x => x.Descripcion) : query.OrderByDescending(x => x.Descripcion),
                "TipoBienDescripcion" => ascending ? query.OrderBy(x => x.TipoBienDescripcion) : query.OrderByDescending(x => x.TipoBienDescripcion),
                "Resguardante" => ascending ? query.OrderBy(x => x.Resguardante) : query.OrderByDescending(x => x.Resguardante),
                _ => ascending ? query.OrderBy(x => x.Tipo).ThenBy(x => x.Clave) : query.OrderByDescending(x => x.Tipo).ThenByDescending(x => x.Clave)
            };
        }

        private static PagedResult<CedulaDiferenciaResponse> Success(IList<CedulaDiferenciaResponse> items, string message, int? total = null) => new()
        {
            Success = true,
            Code = "SUCCESS",
            Message = message,
            Items = items,
            TotalCount = total ?? items.Count
        };

        private static PagedResult<CedulaDiferenciaResponse> Failure(string message, string code = "ERROR") => new()
        {
            Success = false,
            Code = code,
            Message = message,
            TotalCount = 0
        };
    }
}

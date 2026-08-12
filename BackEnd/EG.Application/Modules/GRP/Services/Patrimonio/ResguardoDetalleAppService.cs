using System.Text.Json;
using EG.Application.Interfaces.Patrimonio;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class ResguardoDetalleAppService : IResguardoDetalleAppService
    {
        private readonly GenericService<ResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> _service;
        private readonly GenericService<VwResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public ResguardoDetalleAppService(
            GenericService<ResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> service,
            GenericService<VwResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> GetAllAsync()
        {
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var resguardos = _context.Resguardos.AsNoTracking()
                .Where(x => x.Activo && x.FkidEmpresaSis == scope.EmpresaId && x.Fecha.Year == scope.Anio)
                .Select(x => x.PkidResguardo);
            var entities = await _serviceView.GetQueryWithIncludes()
                .Where(x => resguardos.Contains(x.FkidResguardoAlma))
                .ToListAsync();
            var items = entities.Adapt<List<ResguardoDetalleResponse>>();
            return Success(items, "Detalles de resguardo obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> GetByIdAsync(int id)
        {
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var entity = await _serviceView.GetQueryWithIncludes()
                .Where(x => x.PkidResguardoDetalle == id)
                .Join(_context.Resguardos.AsNoTracking(),
                    detalle => detalle.FkidResguardoAlma,
                    resguardo => resguardo.PkidResguardo,
                    (detalle, resguardo) => new { detalle, resguardo })
                .Where(x => x.resguardo.Activo && x.resguardo.FkidEmpresaSis == scope.EmpresaId && x.resguardo.Fecha.Year == scope.Anio)
                .Select(x => x.detalle)
                .FirstOrDefaultAsync();
            if (entity == null)
            {
                return Failure<ResguardoDetalleResponse>($"Detalle de resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            var item = entity.Adapt<ResguardoDetalleResponse>();

            return new PagedResult<ResguardoDetalleResponse>
            {
                Success = true,
                Message = "Detalle de resguardo encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<ResguardoDetalleResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> CreateAsync(ResguardoDetalleResponse response, int usuarioActual)
        {
            var validation = Validate(response, true);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var resguardo = await _context.Resguardos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidResguardo == response.FkidResguardoAlma && x.Activo);
                if (resguardo == null)
                {
                    return Failure<ResguardoDetalleResponse>("El resguardo no existe o está inactivo.", "NOT_FOUND");
                }

                var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
                if (resguardo.FkidEmpresaSis != scope.EmpresaId || resguardo.Fecha.Year != scope.Anio)
                {
                    return Failure<ResguardoDetalleResponse>("El resguardo no pertenece a la empresa y ejercicio presupuestal seleccionados.");
                }

                var bien = await _context.Biens
                    .FirstOrDefaultAsync(x => x.PkidBien == response.FkidBienAlma && x.Activo && x.FkidEmpresaSis == scope.EmpresaId);
                if (bien == null)
                {
                    return Failure<ResguardoDetalleResponse>("El bien no existe o está inactivo.", "NOT_FOUND");
                }

                var yaAsignado = await _context.ResguardoDetalles
                    .AnyAsync(x => x.FkidBienAlma == response.FkidBienAlma && x.Activo);
                if (yaAsignado)
                {
                    return Failure<ResguardoDetalleResponse>("El bien ya tiene un resguardo activo.");
                }

                var estadoBien = response.FkidEstadoBienAlma ?? bien.FkidEstadoBienAlma;
                var detalle = new ResguardoDetalle
                {
                    FkidResguardoAlma = response.FkidResguardoAlma,
                    FkidBienAlma = response.FkidBienAlma,
                    FkidEstadoBienAlma = estadoBien,
                    FechaAsignacion = DateTime.Now,
                    ImprimeEtiqueta = response.ImprimeEtiqueta,
                    Observaciones = response.Observaciones,
                    Activo = true,
                    FechaCreacion = DateTime.Now,
                    UsuarioCreacion = usuarioActual
                };

                var executionStrategy = _context.Database.CreateExecutionStrategy();
                await executionStrategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync();
                    _context.ResguardoDetalles.Add(detalle);
                    await _context.SaveChangesAsync();

                    var resguardoAnterior = bien.Resguardo;
                    bien.ResguardoAnterior = resguardoAnterior;
                    bien.Resguardo = response.FkidResguardoAlma;
                    bien.EstaResguardado = true;
                    bien.FechaResguardado = DateTime.Now;
                    bien.FkidAreaSis = resguardo.FkidAreaSis ?? bien.FkidAreaSis;
                    bien.FkidEstadoBienAlma = estadoBien ?? bien.FkidEstadoBienAlma;
                    bien.FechaModificacion = DateTime.Now;
                    bien.UsuarioModificacion = usuarioActual;

                    AddMovimiento(detalle.PkidResguardoDetalle, bien.PkidBien, resguardoAnterior, response.FkidResguardoAlma, "ASIGNACION", response.Observaciones, usuarioActual);
                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                });

                var refreshed = await GetByIdAsync(detalle.PkidResguardoDetalle);
                refreshed.Message = "Bien asignado al resguardo correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<ResguardoDetalleResponse>($"Error al asignar resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> UpdateAsync(int id, ResguardoDetalleResponse response, int usuarioActual)
        {
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            if (!await _context.ResguardoDetalles.AsNoTracking().AnyAsync(x => x.PkidResguardoDetalle == id && x.Activo &&
                x.FkidResguardoAlmaNavigation.FkidEmpresaSis == scope.EmpresaId &&
                x.FkidResguardoAlmaNavigation.Fecha.Year == scope.Anio))
            {
                return Failure<ResguardoDetalleResponse>($"Detalle de resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            var validation = Validate(response, false);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var detalle = await _context.ResguardoDetalles
                    .FirstAsync(x => x.PkidResguardoDetalle == id && x.Activo);

                detalle.FkidEstadoBienAlma = response.FkidEstadoBienAlma ?? detalle.FkidEstadoBienAlma;
                detalle.ImprimeEtiqueta = response.ImprimeEtiqueta;
                detalle.Observaciones = response.Observaciones;
                detalle.FechaModificacion = DateTime.Now;
                detalle.UsuarioModificacion = usuarioActual;

                var bien = await _context.Biens.FirstOrDefaultAsync(x => x.PkidBien == detalle.FkidBienAlma && x.Activo);
                if (bien != null && response.FkidEstadoBienAlma.HasValue)
                {
                    bien.FkidEstadoBienAlma = response.FkidEstadoBienAlma;
                    bien.FechaModificacion = DateTime.Now;
                    bien.UsuarioModificacion = usuarioActual;
                }

                await _context.SaveChangesAsync();

                var refreshed = await GetByIdAsync(id);
                refreshed.Message = "Detalle de resguardo actualizado correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<ResguardoDetalleResponse>($"Error al actualizar detalle de resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
                var detalle = await _context.ResguardoDetalles
                    .FirstOrDefaultAsync(x => x.PkidResguardoDetalle == id && x.Activo &&
                        x.FkidResguardoAlmaNavigation.FkidEmpresaSis == scope.EmpresaId &&
                        x.FkidResguardoAlmaNavigation.Fecha.Year == scope.Anio);
                if (detalle == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Detalle de resguardo con ID {id} no encontrado.",
                        Code = "NOT_FOUND",
                        Data = false,
                        TotalCount = 0
                    };
                }

                var usuarioActual = _userContext.GetCurrentUserId();
                var bien = await _context.Biens.FirstOrDefaultAsync(x => x.PkidBien == detalle.FkidBienAlma && x.Activo);
                var resguardoOrigen = detalle.FkidResguardoAlma;
                var executionStrategy = _context.Database.CreateExecutionStrategy();
                await executionStrategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync();
                    detalle.Activo = false;
                    detalle.FechaLiberacion = DateTime.Now;
                    detalle.FechaModificacion = DateTime.Now;
                    detalle.UsuarioModificacion = usuarioActual;

                    if (bien != null)
                    {
                        bien.ResguardoAnterior = bien.Resguardo;
                        bien.Resguardo = null;
                        bien.EstaResguardado = false;
                        bien.FechaResguardado = null;
                        bien.FechaModificacion = DateTime.Now;
                        bien.UsuarioModificacion = usuarioActual;
                    }

                    AddMovimiento(detalle.PkidResguardoDetalle, detalle.FkidBienAlma, resguardoOrigen, null, "LIBERACION", detalle.Observaciones, usuarioActual);
                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                });

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Bien liberado del resguardo correctamente.",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al liberar resguardo: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
                var resguardos = _context.Resguardos.AsNoTracking()
                    .Where(x => x.Activo && x.FkidEmpresaSis == scope.EmpresaId && x.Fecha.Year == scope.Anio)
                    .Select(x => x.PkidResguardo);
                var query = _serviceView.GetQueryWithIncludes()
                    .Where(x => resguardos.Contains(x.FkidResguardoAlma));

                if (TryGetIntFilter(request, "FkidBienAlma", out var bienId))
                {
                    query = query.Where(x => x.FkidBienAlma == bienId);
                }

                if (TryGetIntFilter(request, "FkidResguardoAlma", out var resguardoId))
                {
                    query = query.Where(x => x.FkidResguardoAlma == resguardoId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.PersonaNombre != null && x.PersonaNombre.Contains(filtro)) ||
                        (x.BienClave != null && x.BienClave.Contains(filtro)) ||
                        (x.BienDescripcion != null && x.BienDescripcion.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<ResguardoDetalleResponse>>(), "Detalles de resguardo obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<ResguardoDetalleResponse>($"Error al obtener detalles de resguardo: {ex.Message}");
            }
        }

        private void AddMovimiento(
            int detalleId,
            int bienId,
            int? resguardoOrigenId,
            int? resguardoDestinoId,
            string tipoMovimiento,
            string? observaciones,
            int usuarioActual)
        {
            _context.ResguardoMovimientos.Add(new ResguardoMovimiento
            {
                FkidResguardoDetalleAlma = detalleId,
                FkidBienAlma = bienId,
                FkidResguardoOrigenAlma = resguardoOrigenId,
                FkidResguardoDestinoAlma = resguardoDestinoId,
                TipoMovimiento = tipoMovimiento,
                FechaMovimiento = DateTime.Now,
                Observaciones = observaciones,
                Activo = true,
                FechaCreacion = DateTime.Now,
                UsuarioCreacion = usuarioActual
            });
        }

        private static PagedResult<ResguardoDetalleResponse>? Validate(ResguardoDetalleResponse response, bool isCreate)
        {
            if (isCreate && response.FkidResguardoAlma <= 0)
            {
                return Failure<ResguardoDetalleResponse>("Debe seleccionar el resguardo.");
            }

            if (isCreate && response.FkidBienAlma <= 0)
            {
                return Failure<ResguardoDetalleResponse>("Debe existir un bien seleccionado.");
            }

            response.ImprimeEtiqueta = true;
            response.Observaciones ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private static IQueryable<VwResguardoDetalle> ApplySort(IQueryable<VwResguardoDetalle> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "PersonaNombre" => ascending ? query.OrderBy(x => x.PersonaNombre) : query.OrderByDescending(x => x.PersonaNombre),
                "BienClave" => ascending ? query.OrderBy(x => x.BienClave) : query.OrderByDescending(x => x.BienClave),
                "FechaAsignacion" => ascending ? query.OrderBy(x => x.FechaAsignacion) : query.OrderByDescending(x => x.FechaAsignacion),
                _ => ascending ? query.OrderByDescending(x => x.PkidResguardoDetalle) : query.OrderBy(x => x.PkidResguardoDetalle)
            };
        }

        private static PagedResult<ResguardoDetalleResponse> Success(List<ResguardoDetalleResponse> items, string message, int total)
        {
            return new PagedResult<ResguardoDetalleResponse>
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

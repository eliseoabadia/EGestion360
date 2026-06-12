using EG.Application.Interfaces.Patrimonio;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class InventarioDetalleAppService : IInventarioDetalleAppService
    {
        private readonly GenericService<InventarioDetalle, InventarioDetalleDto, InventarioDetalleResponse> _service;
        private readonly GenericService<VwInventarioDetalle, InventarioDetalleDto, InventarioDetalleResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public InventarioDetalleAppService(
            GenericService<InventarioDetalle, InventarioDetalleDto, InventarioDetalleResponse> service,
            GenericService<VwInventarioDetalle, InventarioDetalleDto, InventarioDetalleResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<InventarioDetalleResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return Success(items, "Detalle de inventario obtenido correctamente", items.Count);
        }

        public async Task<PagedResult<InventarioDetalleResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidInventarioDetalle");
            if (item == null)
            {
                return Failure<InventarioDetalleResponse>($"Detalle de inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<InventarioDetalleResponse>
            {
                Success = true,
                Message = "Detalle de inventario encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<InventarioDetalleResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<InventarioDetalleResponse>> CreateAsync(InventarioDetalleResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                var id = result.GetId();
                if (id.HasValue)
                {
                    var refreshed = await GetByIdAsync(id.Value);
                    refreshed.Message = result.Mensaje;
                    return refreshed;
                }

                return new PagedResult<InventarioDetalleResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return Failure<InventarioDetalleResponse>($"Error al agregar bien al inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<InventarioDetalleResponse>> UpdateAsync(int id, InventarioDetalleResponse response, int usuarioActual)
        {
            var current = await _context.InventarioDetalles
                .AsNoTracking()
                .Include(x => x.FkidInventarioAlmaNavigation)
                .ThenInclude(x => x.FkidEstatusInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventarioDetalle == id && x.Activo);

            if (current == null)
            {
                return Failure<InventarioDetalleResponse>($"Detalle de inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsLocked(current.FkidInventarioAlmaNavigation))
            {
                return Failure<InventarioDetalleResponse>("El inventario ya esta autorizado o en estatus final y no puede modificarse.", "INVALID_STATE");
            }

            response.PkidInventarioDetalle = id;
            response.FkidInventarioAlma = current.FkidInventarioAlma;
            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.UsuarioCreacion = current.UsuarioCreacion;
            response.FechaCreacion = current.FechaCreacion;

            try
            {
                var result = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<InventarioDetalleResponse>($"Error al actualizar detalle de inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.InventarioDetalles
                .AsNoTracking()
                .Include(x => x.FkidInventarioAlmaNavigation)
                .ThenInclude(x => x.FkidEstatusInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventarioDetalle == id && x.Activo);

            if (current == null)
            {
                return BoolFailure($"Detalle de inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsLocked(current.FkidInventarioAlmaNavigation))
            {
                return BoolFailure("El inventario ya esta autorizado o en estatus final y no puede eliminar bienes.", "INVALID_STATE");
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(3, id, new InventarioDetalleResponse
                {
                    PkidInventarioDetalle = id,
                    FkidInventarioAlma = current.FkidInventarioAlma,
                    FkidBienAlma = current.FkidBienAlma,
                    UbicacionSistema = current.UbicacionSistema ?? string.Empty,
                    UbicacionFisica = current.UbicacionFisica ?? string.Empty,
                    Localizado = current.Localizado,
                    TieneDiferencia = current.TieneDiferencia,
                    Observaciones = current.Observaciones ?? string.Empty
                }, _userContext.GetCurrentUserId());

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return BoolFailure($"Error al eliminar detalle de inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<InventarioDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidInventarioAlma", out var inventarioId))
                {
                    query = query.Where(x => x.FkidInventarioAlma == inventarioId);
                }

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidBienAlma", out var bienId))
                {
                    query = query.Where(x => x.FkidBienAlma == bienId);
                }

                if (PatrimonioPagedFilter.TryGetBool(request, "Localizado", out var localizado))
                {
                    query = query.Where(x => x.Localizado == localizado);
                }

                if (PatrimonioPagedFilter.TryGetBool(request, "TieneDiferencia", out var tieneDiferencia))
                {
                    query = query.Where(x => x.TieneDiferencia == tieneDiferencia);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.InventarioFolio != null && x.InventarioFolio.Contains(filtro)) ||
                        (x.BienClave != null && x.BienClave.Contains(filtro)) ||
                        (x.BienDescripcion != null && x.BienDescripcion.Contains(filtro)) ||
                        (x.ClaveBien != null && x.ClaveBien.Contains(filtro)) ||
                        (x.DescripcionBien != null && x.DescripcionBien.Contains(filtro)) ||
                        (x.Modelo != null && x.Modelo.Contains(filtro)) ||
                        (x.Serie != null && x.Serie.Contains(filtro)) ||
                        (x.SerieCapturada != null && x.SerieCapturada.Contains(filtro)) ||
                        (x.UbicacionSistema != null && x.UbicacionSistema.Contains(filtro)) ||
                        (x.UbicacionFisica != null && x.UbicacionFisica.Contains(filtro)) ||
                        (x.Observaciones != null && x.Observaciones.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                var responses = items.Adapt<List<InventarioDetalleResponse>>();

                return Success(responses, "Detalle de inventario obtenido correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<InventarioDetalleResponse>($"Error al obtener detalle de inventario: {ex.Message}");
            }
        }

        private async Task<PagedResult<InventarioDetalleResponse>?> NormalizeAndValidateAsync(InventarioDetalleResponse response, bool isCreate)
        {
            if (response.FkidInventarioAlma <= 0)
            {
                return Failure<InventarioDetalleResponse>("Debe seleccionar un inventario.");
            }

            var inventario = await _context.Inventarios
                .AsNoTracking()
                .Include(x => x.FkidEstatusInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventario == response.FkidInventarioAlma && x.Activo);
            if (inventario == null)
            {
                return Failure<InventarioDetalleResponse>("El inventario seleccionado no existe o esta inactivo.");
            }

            if (IsLocked(inventario))
            {
                return Failure<InventarioDetalleResponse>("El inventario ya esta autorizado o en estatus final.", "INVALID_STATE");
            }

            if (response.FkidBienAlma <= 0)
            {
                return Failure<InventarioDetalleResponse>("Debe seleccionar un bien.");
            }

            var bien = await _context.Biens.AsNoTracking().FirstOrDefaultAsync(x => x.PkidBien == response.FkidBienAlma && x.Activo);
            if (bien == null)
            {
                return Failure<InventarioDetalleResponse>("El bien seleccionado no existe o esta inactivo.");
            }

            var duplicate = await _context.InventarioDetalles.AsNoTracking().AnyAsync(x =>
                x.Activo &&
                x.FkidInventarioAlma == response.FkidInventarioAlma &&
                x.FkidBienAlma == response.FkidBienAlma &&
                (isCreate || x.PkidInventarioDetalle != response.PkidInventarioDetalle));
            if (duplicate)
            {
                return Failure<InventarioDetalleResponse>("El bien ya esta agregado a este inventario.", "DUPLICATE");
            }

            response.ClaveBien = string.IsNullOrWhiteSpace(response.ClaveBien) ? bien.Clave ?? string.Empty : response.ClaveBien;
            response.DescripcionBien = string.IsNullOrWhiteSpace(response.DescripcionBien) ? bien.Descripcion ?? string.Empty : response.DescripcionBien;
            response.SerieCapturada = string.IsNullOrWhiteSpace(response.SerieCapturada) ? bien.Serie ?? string.Empty : response.SerieCapturada;
            response.Serie = response.SerieCapturada;
            response.UbicacionSistema = string.IsNullOrWhiteSpace(response.UbicacionSistema) ? bien.Ubicacion ?? string.Empty : response.UbicacionSistema;
            response.UbicacionFisica = string.IsNullOrWhiteSpace(response.UbicacionFisica) ? response.UbicacionSistema : response.UbicacionFisica;
            response.Observaciones ??= string.Empty;
            response.TieneDiferencia = response.TieneDiferencia ||
                !response.Localizado ||
                !string.Equals(response.UbicacionSistema?.Trim(), response.UbicacionFisica?.Trim(), StringComparison.OrdinalIgnoreCase);
            response.Activo = true;

            return null;
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(int action, int? id, InventarioDetalleResponse response, int usuarioActual)
        {
            var idParameter = new SqlParameter("@Id", id.HasValue ? id.Value : DBNull.Value)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                SqlDbType = System.Data.SqlDbType.Int
            };

            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoInventarioDetalle]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdInventarioDetalle", id),
                StoredProcedureExecutor.Param("@FKIdInventario_ALMA", response.FkidInventarioAlma),
                StoredProcedureExecutor.Param("@FKIdBien_ALMA", response.FkidBienAlma),
                StoredProcedureExecutor.Param("@UbicacionSistema", response.UbicacionSistema),
                StoredProcedureExecutor.Param("@UbicacionFisica", response.UbicacionFisica),
                StoredProcedureExecutor.Param("@Localizado", response.Localizado),
                StoredProcedureExecutor.Param("@TieneDiferencia", response.TieneDiferencia),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                idParameter);
        }

        private static bool IsLocked(Inventario inventario) =>
            inventario.Autorizado || inventario.FkidEstatusInventarioAlmaNavigation?.EsFinal == true;

        private static IQueryable<VwInventarioDetalle> ApplySort(IQueryable<VwInventarioDetalle> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "BienClave" => ascending ? query.OrderBy(x => x.BienClave) : query.OrderByDescending(x => x.BienClave),
                "BienDescripcion" => ascending ? query.OrderBy(x => x.BienDescripcion) : query.OrderByDescending(x => x.BienDescripcion),
                "Serie" => ascending ? query.OrderBy(x => x.Serie) : query.OrderByDescending(x => x.Serie),
                "UbicacionSistema" => ascending ? query.OrderBy(x => x.UbicacionSistema) : query.OrderByDescending(x => x.UbicacionSistema),
                "UbicacionFisica" => ascending ? query.OrderBy(x => x.UbicacionFisica) : query.OrderByDescending(x => x.UbicacionFisica),
                "Localizado" => ascending ? query.OrderBy(x => x.Localizado) : query.OrderByDescending(x => x.Localizado),
                "TieneDiferencia" => ascending ? query.OrderBy(x => x.TieneDiferencia) : query.OrderByDescending(x => x.TieneDiferencia),
                "ValorActual" => ascending ? query.OrderBy(x => x.ValorActual) : query.OrderByDescending(x => x.ValorActual),
                _ => ascending ? query.OrderByDescending(x => x.PkidInventarioDetalle) : query.OrderBy(x => x.PkidInventarioDetalle)
            };
        }

        private static PagedResult<InventarioDetalleResponse> Success(List<InventarioDetalleResponse> items, string message, int total)
        {
            return new PagedResult<InventarioDetalleResponse>
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

        private static PagedResult<bool> BoolFailure(string message, string code = "ERROR")
        {
            return new PagedResult<bool>
            {
                Success = false,
                Message = message,
                Code = code,
                Data = false,
                TotalCount = 0
            };
        }
    }
}

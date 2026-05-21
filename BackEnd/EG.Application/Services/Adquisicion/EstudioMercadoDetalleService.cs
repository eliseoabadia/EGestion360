using System.Text.Json;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class EstudioMercadoDetalleService
        : AdquisicionCrudAppService<EstudioMercadoDetalle, VwEstudioMercadoDetalle, EstudioMercadoDetalleDto, EstudioMercadoDetalleResponse>,
            IEstudioMercadoDetalleService
    {
        private readonly EGestionContext _context;

        public EstudioMercadoDetalleService(
            GenericService<EstudioMercadoDetalle, EstudioMercadoDetalleDto, EstudioMercadoDetalleResponse> service,
            GenericService<VwEstudioMercadoDetalle, EstudioMercadoDetalleDto, EstudioMercadoDetalleResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidEstudioMercadoDetalle",
                "Detalle de estudio de mercado",
                (dto, id) => dto.PkidEstudioMercadoDetalle = id)
        {
            _context = context;
        }

        public override async Task<PagedResult<EstudioMercadoDetalleResponse>> CreateAsync(EstudioMercadoDetalleResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, null);
            return validation ?? await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<EstudioMercadoDetalleResponse>> UpdateAsync(int id, EstudioMercadoDetalleResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, id);
            return validation ?? await base.UpdateAsync(id, response, usuarioActual);
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var detalle = await _context.EstudioMercadoDetalles
                    .FirstOrDefaultAsync(x => x.PkidEstudioMercadoDetalle == id && x.Activo);

                if (detalle == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Detalle de estudio de mercado con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        Data = false,
                        TotalCount = 0
                    };
                }

                detalle.Activo = false;
                detalle.UsuarioModificacion = usuarioActual;
                detalle.FechaModificacion = DateTime.Now;

                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Detalle de estudio de mercado eliminado correctamente",
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
                    Message = $"Error al eliminar detalle de estudio de mercado: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<LookupItem>> GetPaaasLookupAsync(PagedRequest request)
        {
            try
            {
                var page = request.Page < 1 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
                var filtro = request.Filtro?.Trim() ?? string.Empty;

                var query = _context.VwPaaas
                    .AsNoTracking()
                    .Where(x => x.Activo);

                if (TryGetIntFilter(request, "FkidAnioSis", out var anioId))
                {
                    query = query.Where(x => x.FkidAnioSis == anioId);
                }

                if (TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Descripcion != null && x.Descripcion.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.ResponsableCompleto != null && x.ResponsableCompleto.Contains(filtro)) ||
                        (x.ClaveNombre != null && x.ClaveNombre.Contains(filtro)));
                }

                query = query
                    .OrderByDescending(x => x.Fecha)
                    .ThenBy(x => x.AreaNombre);

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(x => new LookupItem
                    {
                        Id = x.PkidPaaas,
                        Text = string.IsNullOrWhiteSpace(x.ClaveNombre)
                            ? $"{x.Descripcion} | {x.AreaNombre}".Trim(' ', '|')
                            : x.ClaveNombre
                    })
                    .ToListAsync();

                return new PagedResult<LookupItem>
                {
                    Success = true,
                    Message = "PAAAS obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = totalItems
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<LookupItem>
                {
                    Success = false,
                    Message = $"Error al obtener PAAAS: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoPaaasDetalleResponse>> GetPaaasDetallesAsync(PagedRequest request)
        {
            try
            {
                if (!TryGetIntFilter(request, "FkidPaaasOrco", out var paaasId) || paaasId <= 0)
                {
                    return new PagedResult<EstudioMercadoPaaasDetalleResponse>
                    {
                        Success = false,
                        Message = "Debe seleccionar un PAAAS.",
                        Code = "VALIDATION",
                        TotalCount = 0
                    };
                }

                var page = request.Page < 1 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 100 : request.PageSize;
                var filtro = request.Filtro?.Trim() ?? string.Empty;

                var query = _context.VwPaaasdetalles
                    .AsNoTracking()
                    .Where(x => x.Activo && x.FkidPaaasOrco == paaasId);

                if (TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.TipoBienCodigoClave != null && x.TipoBienCodigoClave.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.PartidaClave != null && x.PartidaClave.Contains(filtro)) ||
                        (x.PartidaDescripcion != null && x.PartidaDescripcion.Contains(filtro)) ||
                        (x.BienClaveNombre != null && x.BienClaveNombre.Contains(filtro)));
                }

                query = query
                    .OrderBy(x => x.PartidaClave)
                    .ThenBy(x => x.TipoBienCodigoClave)
                    .ThenBy(x => x.TipoBienDescripcion);

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(x => new EstudioMercadoPaaasDetalleResponse
                    {
                        PaaasDetalleId = x.PkidPaaasdetalle,
                        EmpresaId = x.FkidEmpresaSis,
                        PaaasPartidaId = x.FkidPaaaspartidaOrco,
                        PaaasId = x.FkidPaaasOrco,
                        TipoBienId = x.FkidTipoBienAlma,
                        TipoBienClave = x.TipoBienCodigoClave ?? string.Empty,
                        TipoBienDescripcion = x.TipoBienDescripcion ?? string.Empty,
                        BienClaveNombre = x.BienClaveNombre ?? string.Empty,
                        PartidaClave = x.PartidaClave ?? string.Empty,
                        PartidaDescripcion = x.PartidaDescripcion ?? string.Empty,
                        Cantidad = x.Cantidad,
                        UnidadMedida = x.UnidadMedida ?? string.Empty,
                        Observaciones = x.Observaciones ?? string.Empty,
                        LugarEntrega = x.LugarEntrega ?? string.Empty
                    })
                    .ToListAsync();

                return new PagedResult<EstudioMercadoPaaasDetalleResponse>
                {
                    Success = true,
                    Message = "Detalles PAAAS obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = totalItems
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoPaaasDetalleResponse>
                {
                    Success = false,
                    Message = $"Error al obtener detalles PAAAS: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<LookupItem>> GetPaaasDetallesLookupAsync(PagedRequest request)
        {
            try
            {
                var page = request.Page < 1 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
                var filtro = request.Filtro?.Trim() ?? string.Empty;

                var query = _context.VwPaaasdetalles
                    .AsNoTracking()
                    .Where(x => x.Activo);

                if (TryGetIntFilter(request, "FkidAnioSis", out var anioId))
                {
                    query = query.Where(x =>
                        x.FkidPaaasOrco.HasValue &&
                        _context.Paaas.Any(p => p.PkidPaaas == x.FkidPaaasOrco.Value && p.FkidAnioSis == anioId && p.Activo));
                }

                if (TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.TipoBienCodigoClave != null && x.TipoBienCodigoClave.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.PartidaClave != null && x.PartidaClave.Contains(filtro)) ||
                        (x.PartidaDescripcion != null && x.PartidaDescripcion.Contains(filtro)) ||
                        (x.BienClaveNombre != null && x.BienClaveNombre.Contains(filtro)));
                }

                query = query
                    .OrderBy(x => x.PartidaClave)
                    .ThenBy(x => x.TipoBienCodigoClave)
                    .ThenBy(x => x.TipoBienDescripcion);

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(x => new LookupItem
                    {
                        Id = x.PkidPaaasdetalle,
                        Text = ((x.PartidaClave ?? string.Empty) + " | " + (x.BienClaveNombre ?? x.TipoBienDescripcion ?? string.Empty)).Trim(' ', '|')
                    })
                    .ToListAsync();

                return new PagedResult<LookupItem>
                {
                    Success = true,
                    Message = "Bienes de PAAAS obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = totalItems
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<LookupItem>
                {
                    Success = false,
                    Message = $"Error al obtener bienes de PAAAS: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoDetalleSeedResponse>> GetPaaasDetalleSeedAsync(int paaaseDetalleId)
        {
            try
            {
                var detalle = await _context.VwPaaasdetalles
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == paaaseDetalleId && x.Activo);

                if (detalle == null)
                {
                    return new PagedResult<EstudioMercadoDetalleSeedResponse>
                    {
                        Success = false,
                        Message = "Detalle PAAAS no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };
                }

                var seed = new EstudioMercadoDetalleSeedResponse
                {
                    PaaasDetalleId = detalle.PkidPaaasdetalle,
                    EmpresaId = detalle.FkidEmpresaSis,
                    TipoBienId = detalle.FkidTipoBienAlma,
                    TipoBienTexto = string.IsNullOrWhiteSpace(detalle.BienClaveNombre)
                        ? $"{detalle.TipoBienCodigoClave} - {detalle.TipoBienDescripcion}".Trim(' ', '-')
                        : detalle.BienClaveNombre,
                    Cantidad = detalle.Cantidad,
                    Observaciones = detalle.Observaciones ?? string.Empty
                };

                return new PagedResult<EstudioMercadoDetalleSeedResponse>
                {
                    Success = true,
                    Message = "Detalle PAAAS encontrado",
                    Code = "SUCCESS",
                    Data = seed,
                    Items = new List<EstudioMercadoDetalleSeedResponse> { seed },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoDetalleSeedResponse>
                {
                    Success = false,
                    Message = $"Error al obtener detalle PAAAS: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoDetalleResponse>> CreateBatchAsync(EstudioMercadoDetalleBatchRequest request, int usuarioActual)
        {
            try
            {
                if (request == null || request.FkidEstudioMercadoOrco <= 0)
                {
                    return ValidationFailure("Debe existir un estudio de mercado seleccionado.");
                }

                var validItems = request.Items?
                    .Where(x => x.FkidPaaasdetalleOrco > 0)
                    .ToList() ?? new List<EstudioMercadoDetalleBatchItemRequest>();

                if (!validItems.Any())
                {
                    return ValidationFailure("Debe seleccionar al menos un detalle PAAAS.");
                }

                var estudio = await _context.EstudioMercados
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidEstudioMercado == request.FkidEstudioMercadoOrco && x.Activo);

                if (estudio == null)
                {
                    return ValidationFailure("El estudio de mercado no existe o esta inactivo.");
                }

                var detalleIds = validItems.Select(x => x.FkidPaaasdetalleOrco).Distinct().ToList();
                var detalles = await _context.VwPaaasdetalles
                    .AsNoTracking()
                    .Where(x => detalleIds.Contains(x.PkidPaaasdetalle) && x.Activo)
                    .ToDictionaryAsync(x => x.PkidPaaasdetalle);

                if (detalles.Count != detalleIds.Count)
                {
                    return ValidationFailure("Uno o mas detalles PAAAS no existen o estan inactivos.");
                }

                var paaasIds = detalles.Values
                    .Where(x => x.FkidPaaasOrco.HasValue)
                    .Select(x => x.FkidPaaasOrco!.Value)
                    .Distinct()
                    .ToList();

                var validPaaasIds = await _context.Paaas
                    .AsNoTracking()
                    .Where(x => paaasIds.Contains(x.PkidPaaas) && x.FkidAnioSis == estudio.FkidAnioSis && x.Activo)
                    .Select(x => x.PkidPaaas)
                    .ToListAsync();

                if (validPaaasIds.Count != paaasIds.Count)
                {
                    return ValidationFailure("Los detalles seleccionados no pertenecen al anio presupuestal del estudio.");
                }

                if (validItems.Any(x => x.FkidProveedorSis.GetValueOrDefault() <= 0))
                {
                    return ValidationFailure("Debe seleccionar proveedor para todos los detalles.");
                }

                var providerIds = validItems
                    .Where(x => x.FkidProveedorSis.GetValueOrDefault() > 0)
                    .Select(x => x.FkidProveedorSis!.Value)
                    .Distinct()
                    .ToList();

                if (validItems.Any(x => !x.CostoUnitario.HasValue || x.CostoUnitario.Value <= 0m))
                {
                    return ValidationFailure("Todos los costos unitarios deben ser mayores a cero.");
                }

                var existingProviders = await _context.Proveedors
                    .AsNoTracking()
                    .Where(x => providerIds.Contains(x.PkidProveedor) && x.Activo)
                    .Select(x => x.PkidProveedor)
                    .ToListAsync();

                if (existingProviders.Count != providerIds.Count)
                {
                    return ValidationFailure("Uno o mas proveedores no existen o estan inactivos.");
                }

                var tipoBienIds = detalles.Values.Select(x => x.FkidTipoBienAlma).Distinct().ToList();
                var existingPairs = await _context.EstudioMercadoDetalles
                    .AsNoTracking()
                    .Where(x =>
                        x.Activo &&
                        x.FkidEstudioMercadoOrco == request.FkidEstudioMercadoOrco &&
                        x.FkidProveedorSis.HasValue &&
                        providerIds.Contains(x.FkidProveedorSis.Value) &&
                        tipoBienIds.Contains(x.FkidTipoBienAlma))
                    .Select(x => new { x.FkidTipoBienAlma, x.FkidProveedorSis })
                    .ToListAsync();

                var existingKeys = existingPairs
                    .Select(x => PairKey(x.FkidTipoBienAlma, x.FkidProveedorSis!.Value))
                    .ToHashSet();
                var batchKeys = new HashSet<string>();
                var now = DateTime.Now;
                var entities = new List<EstudioMercadoDetalle>();

                foreach (var item in validItems)
                {
                    var detalle = detalles[item.FkidPaaasdetalleOrco];
                    var providerId = item.FkidProveedorSis!.Value;

                    if (detalle.FkidEmpresaSis != estudio.FkidEmpresaSis)
                    {
                        return ValidationFailure("Los detalles seleccionados no pertenecen a la empresa del estudio.");
                    }

                    var key = PairKey(detalle.FkidTipoBienAlma, providerId);
                    if (existingKeys.Contains(key) || !batchKeys.Add(key))
                    {
                        return ValidationFailure("No se puede repetir el mismo tipo de bien con el mismo proveedor.");
                    }

                    entities.Add(new EstudioMercadoDetalle
                    {
                        FkidEmpresaSis = estudio.FkidEmpresaSis,
                        FkidEstudioMercadoOrco = request.FkidEstudioMercadoOrco,
                        FkidPaaasdetalleOrco = detalle.PkidPaaasdetalle,
                        FkidTipoBienAlma = detalle.FkidTipoBienAlma,
                        FkidProveedorSis = providerId,
                        CostoUnitario = item.CostoUnitario,
                        Cantidad = detalle.Cantidad,
                        Observaciones = string.IsNullOrWhiteSpace(item.Observaciones)
                            ? detalle.Observaciones
                            : item.Observaciones.Trim(),
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual
                    });
                }

                await using var transaction = await _context.Database.BeginTransactionAsync();
                await _context.EstudioMercadoDetalles.AddRangeAsync(entities);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var createdIds = entities.Select(x => x.PkidEstudioMercadoDetalle).ToList();
                var created = await _context.VwEstudioMercadoDetalles
                    .AsNoTracking()
                    .Where(x => createdIds.Contains(x.PkidEstudioMercadoDetalle))
                    .OrderBy(x => x.TipoBienClave)
                    .ToListAsync();

                return new PagedResult<EstudioMercadoDetalleResponse>
                {
                    Success = true,
                    Message = "Detalles de estudio de mercado creados correctamente",
                    Code = "SUCCESS",
                    Items = created.Adapt<List<EstudioMercadoDetalleResponse>>(),
                    TotalCount = created.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoDetalleResponse>
                {
                    Success = false,
                    Message = $"Error al crear detalles de estudio de mercado: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        private async Task<PagedResult<EstudioMercadoDetalleResponse>?> NormalizeAndValidateAsync(EstudioMercadoDetalleResponse response, int? id)
        {
            response.Observaciones = string.IsNullOrWhiteSpace(response.Observaciones)
                ? null
                : response.Observaciones.Trim();

            if (response.FkidEstudioMercadoOrco <= 0)
            {
                return ValidationFailure("Debe existir un estudio de mercado seleccionado.");
            }

            if (response.FkidPaaasdetalleOrco <= 0)
            {
                return ValidationFailure("Debe seleccionar un bien del PAAAS.");
            }

            var estudio = await _context.EstudioMercados
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidEstudioMercado == response.FkidEstudioMercadoOrco && x.Activo);

            if (estudio == null)
            {
                return ValidationFailure("El estudio de mercado no existe o esta inactivo.");
            }

            var paaasDetalle = await _context.Paaasdetalles
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == response.FkidPaaasdetalleOrco && x.Activo);

            if (paaasDetalle == null)
            {
                return ValidationFailure("El bien del PAAAS no existe o esta inactivo.");
            }

            response.FkidEmpresaSis = response.FkidEmpresaSis > 0 ? response.FkidEmpresaSis : estudio.FkidEmpresaSis;
            response.FkidTipoBienAlma = response.FkidTipoBienAlma > 0 ? response.FkidTipoBienAlma : paaasDetalle.FkidTipoBienAlma;
            response.Cantidad = response.Cantidad > 0m ? response.Cantidad : paaasDetalle.Cantidad;
            response.FkidProveedorSis = response.FkidProveedorSis.GetValueOrDefault() > 0
                ? response.FkidProveedorSis
                : null;

            if (response.FkidTipoBienAlma != paaasDetalle.FkidTipoBienAlma)
            {
                return ValidationFailure("El tipo de bien debe coincidir con el detalle PAAAS seleccionado.");
            }

            if (response.Cantidad <= 0m)
            {
                return ValidationFailure("La cantidad debe ser mayor a cero.");
            }

            if (!response.FkidProveedorSis.HasValue)
            {
                return ValidationFailure("Debe seleccionar un proveedor para el precio de mercado.");
            }

            if (!response.CostoUnitario.HasValue || response.CostoUnitario.Value <= 0m)
            {
                return ValidationFailure("El costo unitario debe ser mayor a cero.");
            }

            var proveedorExists = await _context.Proveedors
                .AsNoTracking()
                .AnyAsync(x => x.PkidProveedor == response.FkidProveedorSis.Value && x.Activo);

            if (!proveedorExists)
            {
                return ValidationFailure("El proveedor seleccionado no existe o esta inactivo.");
            }

            var duplicated = await _context.EstudioMercadoDetalles
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidEstudioMercadoOrco == response.FkidEstudioMercadoOrco &&
                    x.FkidTipoBienAlma == response.FkidTipoBienAlma &&
                    x.FkidProveedorSis == response.FkidProveedorSis.Value &&
                    (!id.HasValue || x.PkidEstudioMercadoDetalle != id.Value));

            if (duplicated)
            {
                return ValidationFailure("Ya existe un precio de mercado para este tipo de bien con el mismo proveedor.");
            }

            return null;
        }

        private static string PairKey(int tipoBienId, int proveedorId) => $"{tipoBienId}:{proveedorId}";

        private static PagedResult<EstudioMercadoDetalleResponse> ValidationFailure(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "VALIDATION",
            TotalCount = 0
        };

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

using System.Globalization;
using System.Net;
using System.Text.Json;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Requests.General;
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
        private readonly IEmailService _emailService;

        public EstudioMercadoDetalleService(
            GenericService<EstudioMercadoDetalle, EstudioMercadoDetalleDto, EstudioMercadoDetalleResponse> service,
            GenericService<VwEstudioMercadoDetalle, EstudioMercadoDetalleDto, EstudioMercadoDetalleResponse> serviceView,
            EGestionContext context,
            IEmailService emailService)
            : base(
                service,
                serviceView,
                "PkidEstudioMercadoDetalle",
                "Detalle de estudio de mercado",
                (dto, id) => dto.PkidEstudioMercadoDetalle = id)
        {
            _context = context;
            _emailService = emailService;
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

        public override async Task<PagedResult<EstudioMercadoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            if (result.Success && result.Items.Any())
            {
                await PopulateCotizacionSummaryAsync(result.Items);
            }

            return result;
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

        public async Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> CreateSolicitudesCotizacionAsync(EstudioMercadoCotizacionRequest request, int usuarioActual)
        {
            try
            {
                if (request == null || request.FkidEstudioMercadoOrco <= 0)
                {
                    return CotizacionSolicitudValidationFailure("Debe existir un estudio de mercado seleccionado.");
                }

                var validItems = request.Items?
                    .Where(x => x.FkidPaaasdetalleOrco > 0)
                    .GroupBy(x => x.FkidPaaasdetalleOrco)
                    .Select(x => x.First())
                    .ToList() ?? new List<EstudioMercadoCotizacionItemRequest>();

                if (!validItems.Any())
                {
                    return CotizacionSolicitudValidationFailure("Debe seleccionar al menos un bien del PAAAS.");
                }

                var proveedorIds = request.ProveedorIds?
                    .Where(x => x > 0)
                    .Distinct()
                    .ToList() ?? new List<int>();

                if (!proveedorIds.Any())
                {
                    return CotizacionSolicitudValidationFailure("Debe seleccionar al menos un proveedor para cotizar.");
                }

                var estudio = await _context.EstudioMercados
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidEstudioMercado == request.FkidEstudioMercadoOrco && x.Activo);

                if (estudio == null)
                {
                    return CotizacionSolicitudValidationFailure("El estudio de mercado no existe o esta inactivo.");
                }

                var paaasDetalleIds = validItems.Select(x => x.FkidPaaasdetalleOrco).ToList();
                var detalles = await _context.VwPaaasdetalles
                    .AsNoTracking()
                    .Where(x => paaasDetalleIds.Contains(x.PkidPaaasdetalle) && x.Activo)
                    .ToDictionaryAsync(x => x.PkidPaaasdetalle);

                if (detalles.Count != paaasDetalleIds.Count)
                {
                    return CotizacionSolicitudValidationFailure("Uno o mas bienes del PAAAS no existen o estan inactivos.");
                }

                if (detalles.Values.Any(x => x.FkidEmpresaSis != estudio.FkidEmpresaSis))
                {
                    return CotizacionSolicitudValidationFailure("Los bienes seleccionados no pertenecen a la empresa del estudio.");
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
                    return CotizacionSolicitudValidationFailure("Los bienes seleccionados no pertenecen al anio presupuestal del estudio.");
                }

                var existingProviders = await _context.Proveedors
                    .AsNoTracking()
                    .Where(x => proveedorIds.Contains(x.PkidProveedor) && x.Activo)
                    .Select(x => x.PkidProveedor)
                    .ToListAsync();

                if (existingProviders.Count != proveedorIds.Count)
                {
                    return CotizacionSolicitudValidationFailure("Uno o mas proveedores no existen o estan inactivos.");
                }

                var now = DateTime.Now;
                await using var transaction = await _context.Database.BeginTransactionAsync();

                var existingDetalles = await _context.EstudioMercadoDetalles
                    .Where(x =>
                        x.Activo &&
                        x.FkidEstudioMercadoOrco == estudio.PkidEstudioMercado &&
                        paaasDetalleIds.Contains(x.FkidPaaasdetalleOrco))
                    .ToListAsync();

                var detalleByPaaas = existingDetalles
                    .GroupBy(x => x.FkidPaaasdetalleOrco)
                    .ToDictionary(x => x.Key, x => x.First());
                foreach (var item in validItems)
                {
                    if (detalleByPaaas.ContainsKey(item.FkidPaaasdetalleOrco))
                    {
                        continue;
                    }

                    var detalle = detalles[item.FkidPaaasdetalleOrco];
                    var entity = new EstudioMercadoDetalle
                    {
                        FkidEmpresaSis = estudio.FkidEmpresaSis,
                        FkidEstudioMercadoOrco = estudio.PkidEstudioMercado,
                        FkidPaaasdetalleOrco = detalle.PkidPaaasdetalle,
                        FkidTipoBienAlma = detalle.FkidTipoBienAlma,
                        Cantidad = detalle.Cantidad,
                        Observaciones = string.IsNullOrWhiteSpace(item.Observaciones)
                            ? detalle.Observaciones
                            : item.Observaciones.Trim(),
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual
                    };

                    await _context.EstudioMercadoDetalles.AddAsync(entity);
                    detalleByPaaas[item.FkidPaaasdetalleOrco] = entity;
                }

                await _context.SaveChangesAsync();

                var existingSolicitudes = await _context.SolicitudCotizacions
                    .Where(x =>
                        x.Activo &&
                        x.FkidEstudioMercadoOrco == estudio.PkidEstudioMercado &&
                        proveedorIds.Contains(x.FkidProveedorSis))
                    .ToListAsync();

                var solicitudByProvider = existingSolicitudes
                    .GroupBy(x => x.FkidProveedorSis)
                    .ToDictionary(x => x.Key, x => x.First());
                foreach (var proveedorId in proveedorIds)
                {
                    if (solicitudByProvider.ContainsKey(proveedorId))
                    {
                        continue;
                    }

                    var solicitud = new SolicitudCotizacion
                    {
                        FkidEmpresaSis = estudio.FkidEmpresaSis,
                        FkidEstudioMercadoOrco = estudio.PkidEstudioMercado,
                        FkidProveedorSis = proveedorId,
                        FechaSolicitud = now,
                        FechaCompromisoEntrega = request.FechaCompromisoEntrega,
                        Comentarios = string.IsNullOrWhiteSpace(request.Comentarios) ? null : request.Comentarios.Trim(),
                        Estatus = 1,
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual
                    };

                    await _context.SolicitudCotizacions.AddAsync(solicitud);
                    solicitudByProvider[proveedorId] = solicitud;
                }

                await _context.SaveChangesAsync();

                var solicitudIds = solicitudByProvider.Values.Select(x => x.PkidSolicitudCotizacion).ToList();
                var estudioDetalleIds = detalleByPaaas.Values.Select(x => x.PkidEstudioMercadoDetalle).ToList();
                var existingCotizaciones = await _context.EstudioMercadoDetalleCostos
                    .Where(x =>
                        x.Activo &&
                        solicitudIds.Contains(x.FkidSolicitudCotizacionOrco) &&
                        estudioDetalleIds.Contains(x.FkidEstudioMercadoDetalleOrco))
                    .Select(x => new { x.FkidSolicitudCotizacionOrco, x.FkidEstudioMercadoDetalleOrco })
                    .ToListAsync();

                var existingKeys = existingCotizaciones
                    .Select(x => CotizacionKey(x.FkidSolicitudCotizacionOrco, x.FkidEstudioMercadoDetalleOrco))
                    .ToHashSet();

                foreach (var solicitud in solicitudByProvider.Values)
                {
                    foreach (var detalle in detalleByPaaas.Values)
                    {
                        var key = CotizacionKey(solicitud.PkidSolicitudCotizacion, detalle.PkidEstudioMercadoDetalle);
                        if (existingKeys.Contains(key))
                        {
                            continue;
                        }

                        await _context.EstudioMercadoDetalleCostos.AddAsync(new EstudioMercadoDetalleCosto
                        {
                            FkidEmpresaSis = estudio.FkidEmpresaSis,
                            FkidSolicitudCotizacionOrco = solicitud.PkidSolicitudCotizacion,
                            FkidEstudioMercadoDetalleOrco = detalle.PkidEstudioMercadoDetalle,
                            Activo = true,
                            FechaCreacion = now,
                            UsuarioCreacion = usuarioActual
                        });
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var result = await GetSolicitudesCotizacionAsync(estudio.PkidEstudioMercado);
                if (request.EnviarCorreo)
                {
                    var emailSummary = await SendSolicitudCotizacionEmailsAsync(
                        estudio,
                        solicitudByProvider.Values.ToList(),
                        detalleByPaaas.Values.ToList());

                    result.Message = BuildEmailSummaryMessage(emailSummary, "Solicitudes de cotizacion generadas");
                }

                return result;
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoCotizacionSolicitudResponse>
                {
                    Success = false,
                    Message = $"Error al generar solicitudes de cotizacion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> GetSolicitudesCotizacionAsync(int estudioMercadoId)
        {
            try
            {
                var solicitudes = await (
                    from solicitud in _context.SolicitudCotizacions.AsNoTracking()
                    join proveedor in _context.Proveedors.AsNoTracking()
                        on solicitud.FkidProveedorSis equals proveedor.PkidProveedor
                    where solicitud.Activo &&
                          proveedor.Activo &&
                          solicitud.FkidEstudioMercadoOrco == estudioMercadoId
                    orderby proveedor.Nombre
                    select new EstudioMercadoCotizacionSolicitudResponse
                    {
                        PkidSolicitudCotizacion = solicitud.PkidSolicitudCotizacion,
                        FkidEstudioMercadoOrco = solicitud.FkidEstudioMercadoOrco,
                        FkidProveedorSis = proveedor.PkidProveedor,
                        ProveedorNombre = proveedor.Nombre ?? string.Empty,
                        ProveedorClave = proveedor.Clave ?? string.Empty,
                        ProveedorRfc = proveedor.Rfc ?? string.Empty,
                        FechaSolicitud = solicitud.FechaSolicitud,
                        FechaCompromisoEntrega = solicitud.FechaCompromisoEntrega,
                        Comentarios = solicitud.Comentarios,
                        Estatus = solicitud.Estatus
                    })
                    .ToListAsync();

                if (!solicitudes.Any())
                {
                    return new PagedResult<EstudioMercadoCotizacionSolicitudResponse>
                    {
                        Success = true,
                        Message = "Solicitudes de cotizacion obtenidas correctamente",
                        Code = "SUCCESS",
                        Items = solicitudes,
                        TotalCount = 0
                    };
                }

                var solicitudIds = solicitudes.Select(x => x.PkidSolicitudCotizacion).ToList();
                var detalles = await (
                    from cotizacion in _context.EstudioMercadoDetalleCostos.AsNoTracking()
                    join detalle in _context.EstudioMercadoDetalles.AsNoTracking()
                        on cotizacion.FkidEstudioMercadoDetalleOrco equals detalle.PkidEstudioMercadoDetalle
                    where cotizacion.Activo && detalle.Activo && solicitudIds.Contains(cotizacion.FkidSolicitudCotizacionOrco)
                    select new
                    {
                        cotizacion.FkidSolicitudCotizacionOrco,
                        cotizacion.PrecioUnitario,
                        detalle.Cantidad
                    })
                    .ToListAsync();

                var summaryBySolicitud = detalles
                    .GroupBy(x => x.FkidSolicitudCotizacionOrco)
                    .ToDictionary(
                        x => x.Key,
                        x => new
                        {
                            TotalBienes = x.Count(),
                            Recibidas = x.Count(y => y.PrecioUnitario.HasValue),
                            TotalCotizado = x.Sum(y => y.PrecioUnitario.HasValue ? y.PrecioUnitario.Value * y.Cantidad : 0m)
                        });

                foreach (var solicitud in solicitudes)
                {
                    if (!summaryBySolicitud.TryGetValue(solicitud.PkidSolicitudCotizacion, out var summary))
                    {
                        continue;
                    }

                    solicitud.TotalBienes = summary.TotalBienes;
                    solicitud.CotizacionesRecibidas = summary.Recibidas;
                    solicitud.TotalCotizado = summary.TotalCotizado;
                }

                return new PagedResult<EstudioMercadoCotizacionSolicitudResponse>
                {
                    Success = true,
                    Message = "Solicitudes de cotizacion obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = solicitudes,
                    TotalCount = solicitudes.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoCotizacionSolicitudResponse>
                {
                    Success = false,
                    Message = $"Error al obtener solicitudes de cotizacion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoCotizacionSolicitudResponse>> SendSolicitudesCotizacionEmailAsync(int estudioMercadoId, int? estudioMercadoDetalleId)
        {
            try
            {
                if (estudioMercadoId <= 0)
                {
                    return CotizacionSolicitudValidationFailure("Debe existir un estudio de mercado seleccionado.");
                }

                var estudio = await _context.EstudioMercados
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidEstudioMercado == estudioMercadoId && x.Activo);

                if (estudio == null)
                {
                    return CotizacionSolicitudValidationFailure("El estudio de mercado no existe o esta inactivo.");
                }

                var detallesQuery = _context.EstudioMercadoDetalles
                    .AsNoTracking()
                    .Where(x => x.Activo && x.FkidEstudioMercadoOrco == estudioMercadoId);

                if (estudioMercadoDetalleId.HasValue && estudioMercadoDetalleId.Value > 0)
                {
                    detallesQuery = detallesQuery.Where(x => x.PkidEstudioMercadoDetalle == estudioMercadoDetalleId.Value);
                }

                var detalles = await detallesQuery.ToListAsync();
                if (!detalles.Any())
                {
                    return CotizacionSolicitudValidationFailure("No hay bienes para enviar en la solicitud de cotizacion.");
                }

                var solicitudes = await _context.SolicitudCotizacions
                    .AsNoTracking()
                    .Where(x => x.Activo && x.FkidEstudioMercadoOrco == estudioMercadoId)
                    .ToListAsync();

                if (!solicitudes.Any())
                {
                    return CotizacionSolicitudValidationFailure("Primero genera las solicitudes de cotizacion.");
                }

                var detalleIds = detalles.Select(x => x.PkidEstudioMercadoDetalle).ToList();
                var solicitudIds = solicitudes.Select(x => x.PkidSolicitudCotizacion).ToList();
                var linkedSolicitudIds = await _context.EstudioMercadoDetalleCostos
                    .AsNoTracking()
                    .Where(x =>
                        x.Activo &&
                        detalleIds.Contains(x.FkidEstudioMercadoDetalleOrco) &&
                        solicitudIds.Contains(x.FkidSolicitudCotizacionOrco))
                    .Select(x => x.FkidSolicitudCotizacionOrco)
                    .Distinct()
                    .ToListAsync();

                solicitudes = solicitudes
                    .Where(x => linkedSolicitudIds.Contains(x.PkidSolicitudCotizacion))
                    .ToList();

                if (!solicitudes.Any())
                {
                    return CotizacionSolicitudValidationFailure("No hay solicitudes de cotizacion para el bien seleccionado.");
                }

                var emailSummary = await SendSolicitudCotizacionEmailsAsync(estudio, solicitudes, detalles);
                var result = await GetSolicitudesCotizacionAsync(estudioMercadoId);
                result.Message = BuildEmailSummaryMessage(emailSummary, "Envio de solicitudes procesado");
                return result;
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoCotizacionSolicitudResponse>
                {
                    Success = false,
                    Message = $"Error al enviar solicitudes de cotizacion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoCotizacionRecepcionResponse>> GetRecepcionCotizacionesAsync(int estudioMercadoId, int? proveedorId)
        {
            try
            {
                var query =
                    from cotizacion in _context.EstudioMercadoDetalleCostos.AsNoTracking()
                    join solicitud in _context.SolicitudCotizacions.AsNoTracking()
                        on cotizacion.FkidSolicitudCotizacionOrco equals solicitud.PkidSolicitudCotizacion
                    join proveedor in _context.Proveedors.AsNoTracking()
                        on solicitud.FkidProveedorSis equals proveedor.PkidProveedor
                    join detalle in _context.EstudioMercadoDetalles.AsNoTracking()
                        on cotizacion.FkidEstudioMercadoDetalleOrco equals detalle.PkidEstudioMercadoDetalle
                    join tipoBien in _context.TipoBiens.AsNoTracking()
                        on detalle.FkidTipoBienAlma equals tipoBien.PkidTipoBien
                    where cotizacion.Activo &&
                          solicitud.Activo &&
                          proveedor.Activo &&
                          detalle.Activo &&
                          tipoBien.Activo &&
                          solicitud.FkidEstudioMercadoOrco == estudioMercadoId
                    select new
                    {
                        cotizacion,
                        solicitud,
                        proveedor,
                        detalle,
                        tipoBien
                    };

                if (proveedorId.HasValue && proveedorId.Value > 0)
                {
                    query = query.Where(x => x.solicitud.FkidProveedorSis == proveedorId.Value);
                }

                var items = await query
                    .OrderBy(x => x.proveedor.Nombre)
                    .ThenBy(x => x.tipoBien.CodigoClave)
                    .ThenBy(x => x.tipoBien.Descripcion)
                    .Select(x => new EstudioMercadoCotizacionRecepcionResponse
                    {
                        PkidEstudioMercadoDetalleCosto = x.cotizacion.PkidEstudioMercadoDetalleCosto,
                        PkidSolicitudCotizacion = x.solicitud.PkidSolicitudCotizacion,
                        FkidProveedorSis = x.proveedor.PkidProveedor,
                        ProveedorNombre = x.proveedor.Nombre ?? string.Empty,
                        ProveedorClave = x.proveedor.Clave ?? string.Empty,
                        ProveedorRfc = x.proveedor.Rfc ?? string.Empty,
                        FkidEstudioMercadoDetalleOrco = x.detalle.PkidEstudioMercadoDetalle,
                        FkidPaaasdetalleOrco = x.detalle.FkidPaaasdetalleOrco,
                        FkidTipoBienAlma = x.detalle.FkidTipoBienAlma,
                        TipoBienClave = x.tipoBien.CodigoClave ?? string.Empty,
                        TipoBienDescripcion = x.tipoBien.Descripcion ?? string.Empty,
                        Cantidad = x.detalle.Cantidad,
                        PrecioUnitario = x.cotizacion.PrecioUnitario,
                        Importe = x.cotizacion.PrecioUnitario.HasValue
                            ? x.cotizacion.PrecioUnitario.Value * x.detalle.Cantidad
                            : null,
                        TiempoEntregaDias = x.cotizacion.TiempoEntregaDias,
                        Condiciones = x.cotizacion.Condiciones,
                        FechaRespuesta = x.cotizacion.FechaRespuesta,
                        EstatusSolicitud = x.solicitud.Estatus
                    })
                    .ToListAsync();

                return new PagedResult<EstudioMercadoCotizacionRecepcionResponse>
                {
                    Success = true,
                    Message = "Cotizaciones obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoCotizacionRecepcionResponse>
                {
                    Success = false,
                    Message = $"Error al obtener cotizaciones: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstudioMercadoCotizacionRecepcionResponse>> SaveRecepcionCotizacionesAsync(EstudioMercadoCotizacionRecepcionRequest request, int usuarioActual)
        {
            try
            {
                if (request == null || request.FkidEstudioMercadoOrco <= 0)
                {
                    return CotizacionRecepcionValidationFailure("Debe existir un estudio de mercado seleccionado.");
                }

                var validItems = request.Items?
                    .Where(x => x.PkidEstudioMercadoDetalleCosto > 0)
                    .GroupBy(x => x.PkidEstudioMercadoDetalleCosto)
                    .Select(x => x.First())
                    .ToList() ?? new List<EstudioMercadoCotizacionRecepcionItemRequest>();

                if (!validItems.Any())
                {
                    return CotizacionRecepcionValidationFailure("No hay cotizaciones para guardar.");
                }

                if (validItems.Any(x => x.PrecioUnitario.HasValue && x.PrecioUnitario.Value <= 0m))
                {
                    return CotizacionRecepcionValidationFailure("Los precios capturados deben ser mayores a cero.");
                }

                if (validItems.Any(x => x.TiempoEntregaDias.HasValue && x.TiempoEntregaDias.Value < 0))
                {
                    return CotizacionRecepcionValidationFailure("El tiempo de entrega no puede ser negativo.");
                }

                var ids = validItems.Select(x => x.PkidEstudioMercadoDetalleCosto).ToList();
                var cotizaciones = await _context.EstudioMercadoDetalleCostos
                    .Include(x => x.FkidSolicitudCotizacionOrcoNavigation)
                    .Where(x =>
                        x.Activo &&
                        ids.Contains(x.PkidEstudioMercadoDetalleCosto) &&
                        x.FkidSolicitudCotizacionOrcoNavigation.Activo &&
                        x.FkidSolicitudCotizacionOrcoNavigation.FkidEstudioMercadoOrco == request.FkidEstudioMercadoOrco)
                    .ToDictionaryAsync(x => x.PkidEstudioMercadoDetalleCosto);

                if (cotizaciones.Count != ids.Count)
                {
                    return CotizacionRecepcionValidationFailure("Una o mas cotizaciones no existen o no pertenecen al estudio seleccionado.");
                }

                var now = DateTime.Now;
                await using var transaction = await _context.Database.BeginTransactionAsync();

                foreach (var item in validItems)
                {
                    var cotizacion = cotizaciones[item.PkidEstudioMercadoDetalleCosto];
                    cotizacion.PrecioUnitario = item.PrecioUnitario;
                    cotizacion.TiempoEntregaDias = item.PrecioUnitario.HasValue ? item.TiempoEntregaDias : null;
                    cotizacion.Condiciones = item.PrecioUnitario.HasValue && !string.IsNullOrWhiteSpace(item.Condiciones)
                        ? item.Condiciones.Trim()
                        : null;
                    cotizacion.FechaRespuesta = item.PrecioUnitario.HasValue
                        ? cotizacion.FechaRespuesta ?? now
                        : null;
                    cotizacion.UsuarioModificacion = usuarioActual;
                    cotizacion.FechaModificacion = now;
                }

                await UpdateSolicitudStatusesAsync(
                    cotizaciones.Values
                        .Select(x => x.FkidSolicitudCotizacionOrco)
                        .Distinct()
                        .ToList(),
                    usuarioActual,
                    now);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return await GetRecepcionCotizacionesAsync(request.FkidEstudioMercadoOrco, null);
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoCotizacionRecepcionResponse>
                {
                    Success = false,
                    Message = $"Error al guardar cotizaciones: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        private async Task<EmailSendSummary> SendSolicitudCotizacionEmailsAsync(
            EstudioMercado estudio,
            List<SolicitudCotizacion> solicitudes,
            List<EstudioMercadoDetalle> detalles)
        {
            var summary = new EmailSendSummary();
            if (!solicitudes.Any() || !detalles.Any())
            {
                return summary;
            }

            var proveedorIds = solicitudes.Select(x => x.FkidProveedorSis).Distinct().ToList();
            var proveedores = await _context.Proveedors
                .AsNoTracking()
                .Where(x => proveedorIds.Contains(x.PkidProveedor) && x.Activo)
                .ToDictionaryAsync(x => x.PkidProveedor);

            var tipoBienIds = detalles.Select(x => x.FkidTipoBienAlma).Distinct().ToList();
            var tipoBienes = await _context.TipoBiens
                .AsNoTracking()
                .Where(x => tipoBienIds.Contains(x.PkidTipoBien) && x.Activo)
                .ToDictionaryAsync(x => x.PkidTipoBien);

            foreach (var solicitud in solicitudes)
            {
                if (!proveedores.TryGetValue(solicitud.FkidProveedorSis, out var proveedor) ||
                    string.IsNullOrWhiteSpace(proveedor.Email))
                {
                    summary.SinEmail++;
                    continue;
                }

                summary.Intentados++;
                var email = new EmailMessageRequest
                {
                    To = new List<string> { proveedor.Email },
                    Subject = $"Solicitud de cotizacion - {estudio.Nombre}",
                    Body = BuildSolicitudCotizacionBody(estudio, proveedor, solicitud, detalles, tipoBienes),
                    IsHtml = true
                };

                var result = await _emailService.SendAsync(email);
                if (result.Success)
                {
                    summary.Enviados++;
                }
                else
                {
                    summary.Errores++;
                }
            }

            return summary;
        }

        private static string BuildEmailSummaryMessage(EmailSendSummary summary, string baseMessage)
        {
            if (summary.Enviados > 0 && summary.Errores == 0 && summary.SinEmail == 0)
            {
                return $"{baseMessage}. Correos enviados: {summary.Enviados:N0}.";
            }

            if (summary.Enviados > 0)
            {
                return $"{baseMessage}. Correos enviados: {summary.Enviados:N0}; sin email: {summary.SinEmail:N0}; con error: {summary.Errores:N0}.";
            }

            if (summary.Errores > 0)
            {
                return $"{baseMessage}, pero no se pudo enviar correo. Errores: {summary.Errores:N0}; sin email: {summary.SinEmail:N0}.";
            }

            return $"{baseMessage}. No se enviaron correos porque los proveedores no tienen email capturado.";
        }

        private static string BuildSolicitudCotizacionBody(
            EstudioMercado estudio,
            Proveedor proveedor,
            SolicitudCotizacion solicitud,
            List<EstudioMercadoDetalle> detalles,
            Dictionary<int, TipoBien> tipoBienes)
        {
            var rows = string.Join(string.Empty, detalles.Select(detalle =>
            {
                tipoBienes.TryGetValue(detalle.FkidTipoBienAlma, out var tipoBien);
                var clave = WebUtility.HtmlEncode(tipoBien?.CodigoClave ?? detalle.FkidTipoBienAlma.ToString());
                var descripcion = WebUtility.HtmlEncode(tipoBien?.Descripcion ?? "Bien / Servicio");
                var observaciones = WebUtility.HtmlEncode(detalle.Observaciones ?? string.Empty);

                return $@"
                    <tr>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{clave}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{descripcion}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;text-align:right;"">{FormatQuantity(detalle.Cantidad)}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{observaciones}</td>
                    </tr>";
            }));

            var compromiso = solicitud.FechaCompromisoEntrega.HasValue
                ? solicitud.FechaCompromisoEntrega.Value.ToString("dd/MM/yyyy")
                : "Por definir";

            return $@"
                <div style=""font-family:Segoe UI,Arial,sans-serif;color:#111827;font-size:14px;"">
                    <p>Estimado proveedor {WebUtility.HtmlEncode(proveedor.Nombre ?? string.Empty)},</p>
                    <p>Se solicita su cotizacion para el estudio de mercado <strong>{WebUtility.HtmlEncode(estudio.Nombre)}</strong>.</p>
                    <p><strong>Fecha de solicitud:</strong> {solicitud.FechaSolicitud:dd/MM/yyyy}<br />
                    <strong>Fecha compromiso:</strong> {compromiso}</p>
                    <table style=""border-collapse:collapse;width:100%;margin-top:12px;"">
                        <thead>
                            <tr style=""background:#f3f4f6;"">
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Clave</th>
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Bien / Servicio</th>
                                <th style=""padding:8px;text-align:right;border-bottom:1px solid #d1d5db;"">Cantidad</th>
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Observaciones</th>
                            </tr>
                        </thead>
                        <tbody>{rows}</tbody>
                    </table>
                    <p style=""margin-top:14px;"">Favor de responder con precio unitario, tiempo de entrega y condiciones comerciales.</p>
                </div>";
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
            response.CostoUnitario = response.CostoUnitario.HasValue && response.CostoUnitario.Value > 0m
                ? response.CostoUnitario
                : null;

            if (response.FkidTipoBienAlma != paaasDetalle.FkidTipoBienAlma)
            {
                return ValidationFailure("El tipo de bien debe coincidir con el detalle PAAAS seleccionado.");
            }

            if (response.Cantidad <= 0m)
            {
                return ValidationFailure("La cantidad debe ser mayor a cero.");
            }

            if (response.CostoUnitario.HasValue && response.CostoUnitario.Value <= 0m)
            {
                return ValidationFailure("El costo unitario debe ser mayor a cero.");
            }

            if (response.FkidProveedorSis.HasValue)
            {
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
            }

            return null;
        }

        private async Task PopulateCotizacionSummaryAsync(IList<EstudioMercadoDetalleResponse> items)
        {
            var ids = items.Select(x => x.PkidEstudioMercadoDetalle).Distinct().ToList();
            if (!ids.Any())
            {
                return;
            }

            var cotizaciones = await (
                from cotizacion in _context.EstudioMercadoDetalleCostos.AsNoTracking()
                join solicitud in _context.SolicitudCotizacions.AsNoTracking()
                    on cotizacion.FkidSolicitudCotizacionOrco equals solicitud.PkidSolicitudCotizacion
                join proveedor in _context.Proveedors.AsNoTracking()
                    on solicitud.FkidProveedorSis equals proveedor.PkidProveedor
                where cotizacion.Activo &&
                      solicitud.Activo &&
                      proveedor.Activo &&
                      ids.Contains(cotizacion.FkidEstudioMercadoDetalleOrco)
                select new
                {
                    cotizacion.FkidEstudioMercadoDetalleOrco,
                    cotizacion.FkidSolicitudCotizacionOrco,
                    cotizacion.PrecioUnitario,
                    cotizacion.FechaRespuesta,
                    PkidProveedor = proveedor.PkidProveedor,
                    ProveedorNombre = proveedor.Nombre ?? string.Empty,
                    ProveedorClave = proveedor.Clave ?? string.Empty,
                    ProveedorRfc = proveedor.Rfc ?? string.Empty
                })
                .ToListAsync();

            var summaryByDetalle = cotizaciones
                .GroupBy(x => x.FkidEstudioMercadoDetalleOrco)
                .ToDictionary(
                    x => x.Key,
                    x => new
                    {
                        Solicitudes = x.Select(y => y.FkidSolicitudCotizacionOrco).Distinct().Count(),
                        Recibidas = x.Count(y => y.PrecioUnitario.HasValue),
                        MenorPrecio = x.Where(y => y.PrecioUnitario.HasValue).Select(y => y.PrecioUnitario).DefaultIfEmpty().Min(),
                        UltimaCotizacion = x.Where(y => y.FechaRespuesta.HasValue).Select(y => y.FechaRespuesta).DefaultIfEmpty().Max(),
                        Proveedores = x
                            .GroupBy(y => y.PkidProveedor)
                            .Select(y => new EstudioMercadoDetalleProveedorResponse
                            {
                                PkidProveedor = y.Key,
                                ProveedorNombre = y.First().ProveedorNombre,
                                ProveedorClave = y.First().ProveedorClave,
                                ProveedorRfc = y.First().ProveedorRfc
                            })
                            .OrderBy(y => y.ProveedorNombre)
                            .ToList()
                    });

            foreach (var item in items)
            {
                if (!summaryByDetalle.TryGetValue(item.PkidEstudioMercadoDetalle, out var summary))
                {
                    continue;
                }

                item.SolicitudesCotizacion = summary.Solicitudes;
                item.CotizacionesRecibidas = summary.Recibidas;
                item.MenorPrecioUnitario = summary.MenorPrecio;
                item.ImporteMenorCotizacion = summary.MenorPrecio.HasValue
                    ? summary.MenorPrecio.Value * item.Cantidad
                    : null;
                item.UltimaCotizacion = summary.UltimaCotizacion;
                item.ProveedoresCotizacion = summary.Proveedores;
            }
        }

        private async Task UpdateSolicitudStatusesAsync(List<int> solicitudIds, int usuarioActual, DateTime now)
        {
            if (!solicitudIds.Any())
            {
                return;
            }

            var solicitudes = await _context.SolicitudCotizacions
                .Where(x => solicitudIds.Contains(x.PkidSolicitudCotizacion) && x.Activo)
                .ToListAsync();

            var cotizaciones = await _context.EstudioMercadoDetalleCostos
                .AsNoTracking()
                .Where(x => solicitudIds.Contains(x.FkidSolicitudCotizacionOrco) && x.Activo)
                .Select(x => new { x.FkidSolicitudCotizacionOrco, x.PrecioUnitario })
                .ToListAsync();

            var counts = cotizaciones
                .GroupBy(x => x.FkidSolicitudCotizacionOrco)
                .ToDictionary(
                    x => x.Key,
                    x => new
                    {
                        Total = x.Count(),
                        Recibidas = x.Count(y => y.PrecioUnitario.HasValue)
                    });

            foreach (var solicitud in solicitudes)
            {
                if (!counts.TryGetValue(solicitud.PkidSolicitudCotizacion, out var count))
                {
                    continue;
                }

                solicitud.Estatus = count.Recibidas == 0
                    ? 1
                    : count.Recibidas < count.Total ? 2 : 3;
                solicitud.UsuarioModificacion = usuarioActual;
                solicitud.FechaModificacion = now;
            }
        }

        private static readonly CultureInfo NumberCulture = CultureInfo.InvariantCulture;

        private static string FormatQuantity(decimal value) => value.ToString("0.00", NumberCulture);

        private static string CotizacionKey(int solicitudId, int detalleId) => $"{solicitudId}:{detalleId}";

        private sealed class EmailSendSummary
        {
            public int Intentados { get; set; }
            public int Enviados { get; set; }
            public int SinEmail { get; set; }
            public int Errores { get; set; }
        }

        private static string PairKey(int tipoBienId, int proveedorId) => $"{tipoBienId}:{proveedorId}";

        private static PagedResult<EstudioMercadoCotizacionSolicitudResponse> CotizacionSolicitudValidationFailure(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "VALIDATION",
            TotalCount = 0
        };

        private static PagedResult<EstudioMercadoCotizacionRecepcionResponse> CotizacionRecepcionValidationFailure(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "VALIDATION",
            TotalCount = 0
        };

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

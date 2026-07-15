using Mapster;
using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Adquisicion
{
    public class ProveedorAppService : IProveedorAppService
    {
        private readonly ILogger<ProveedorAppService> _logger;
        private readonly IRepository<Proveedor> _repository;
        private readonly EGestionContext _context;

        public ProveedorAppService(
            ILogger<ProveedorAppService> logger,
            IRepository<Proveedor> repository,
            EGestionContext context)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
        }

        public async Task<PagedResult<ProveedorResponse>> GetAllAsync()
        {
            try
            {
                var items = await _context.VwProveedors
                    .AsNoTracking()
                    .Where(item => item.Activo)
                    .ToListAsync();
                return new PagedResult<ProveedorResponse>
                {
                    Items = items.Adapt<List<ProveedorResponse>>(),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de Proveedor");
                return new PagedResult<ProveedorResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _context.Proveedors
                    .AsNoTracking()
                    .Include(e => e.FkIdTipoProveedorSisNavigation)
                    .Include(e => e.FkidEstatusProveedorSisNavigation)
                    .Include(e => e.FkidCuentaContableSisNavigation)
                    .Include(e => e.FkidMunicipioSisNavigation)
                    .Include(e => e.FkidEstadoSisNavigation)
                    .Include(e => e.FkidPaisSisNavigation)
                    .FirstOrDefaultAsync(e => e.PkidProveedor == id && e.Activo);
                if (entity == null)
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Proveedor no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var response = entity.Adapt<ProveedorResponse>();
                return new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<ProveedorResponse> { response },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de Proveedor para ID {Id}", id);
                return new PagedResult<ProveedorResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> CreateAsync(ProveedorResponse response, int usuarioActual)
        {
            try
            {
                var dto = await NormalizeForSaveAsync(response);
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.UtcNow;
                dto.FechaAlta = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe un proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                var entity = dto.Adapt<Proveedor>();
                _context.Proveedors.Add(entity);
                await _context.SaveChangesAsync();

                var created = await GetByIdAsync(entity.PkidProveedor);

                return new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "Proveedor creado correctamente",
                    Code = "SUCCESS",
                    Data = created.Data,
                    Items = created.Data != null ? new List<ProveedorResponse> { created.Data } : new List<ProveedorResponse>(),
                    TotalCount = 1
                };
            }
            catch (ArgumentException ex)
            {
                return new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "VALIDATION",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = $"Error al crear proveedor: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> UpdateAsync(int id, ProveedorResponse response, int usuarioActual)
        {
            try
            {
                var entity = await _context.Proveedors.FirstOrDefaultAsync(item => item.PkidProveedor == id && item.Activo);
                if (entity == null)
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = $"Proveedor con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var dto = await NormalizeForSaveAsync(response);
                dto.PkidProveedor = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.UtcNow;
                dto.Activo = true;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.PkidProveedor != id && e.Activo);
                if (duplicate.Any())
                {
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                ApplyValues(entity, dto);
                await _context.SaveChangesAsync();

                var updated = await GetByIdAsync(id);

                return new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "Proveedor actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated.Data,
                    Items = updated.Data != null ? new List<ProveedorResponse> { updated.Data } : new List<ProveedorResponse>(),
                    TotalCount = 1
                };
            }
            catch (ArgumentException ex)
            {
                return new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "VALIDATION",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var entity = await _context.Proveedors.FirstOrDefaultAsync(item => item.PkidProveedor == id);
                if (entity == null)
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Proveedor con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                if (!entity.Activo)
                {
                    return new PagedResult<bool>
                    {
                        Success = true,
                        Message = "Proveedor ya se encuentra inactivo",
                        Code = "SUCCESS",
                        Data = true,
                        Items = new List<bool> { true },
                        TotalCount = 1
                    };
                }

                entity.Activo = false;
                entity.FechaModificacion = DateTime.UtcNow;
                entity.UsuarioModificacion = usuarioActual;
                await _context.SaveChangesAsync();

                var stillActive = await _context.Proveedors
                    .AsNoTracking()
                    .AnyAsync(item => item.PkidProveedor == id && item.Activo);
                if (stillActive)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"No fue posible dar de baja Proveedor con ID {id}; el registro sigue activo en la base de datos.",
                        Code = "ERROR",
                        TotalCount = 0
                    };
                }

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Proveedor eliminado correctamente",
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
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _context.VwProveedors
                    .AsNoTracking()
                    .Where(item => item.Activo)
                    .AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Nombre.Contains(f) || e.Rfc.Contains(f) || e.Clave.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidProveedor" => isAscending ? query.OrderBy(e => e.PkidProveedor) : query.OrderByDescending(e => e.PkidProveedor),
                        "Nombre" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                        "Rfc" => isAscending ? query.OrderBy(e => e.Rfc) : query.OrderByDescending(e => e.Rfc),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "TipoProveedorNombre" => isAscending ? query.OrderBy(e => e.TipoProveedorDesc) : query.OrderByDescending(e => e.TipoProveedorDesc),
                        "EstatusProveedorNombre" => isAscending ? query.OrderBy(e => e.EstatusProveedorDesc) : query.OrderByDescending(e => e.EstatusProveedorDesc),
                        "MunicipioNombre" => isAscending ? query.OrderBy(e => e.MunicipioNombre) : query.OrderByDescending(e => e.MunicipioNombre),
                        "EstadoNombre" => isAscending ? query.OrderBy(e => e.EstadoNombre) : query.OrderByDescending(e => e.EstadoNombre),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Nombre)
                    };
                }
                else
                {
                    query = query.OrderBy(e => e.Nombre);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<ProveedorResponse>
                {
                    Items = items.Adapt<List<ProveedorResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de Proveedor");
                return new PagedResult<ProveedorResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        private async Task<ProveedorDto> NormalizeForSaveAsync(ProveedorResponse response)
        {
            if (response == null)
                throw new ArgumentException("Los datos del proveedor son requeridos.");

            var nombre = Required(response.Nombre, "Nombre", 500);
            var rfc = Required(response.Rfc, "RFC", 50).ToUpperInvariant();
            var email = Required(response.Email, "Email", 50);
            var clave = Trim(response.Clave, 10);
            if (string.IsNullOrWhiteSpace(clave))
                clave = GenerateClave(rfc, nombre);

            var location = await ResolveLocationAsync(response);
            var tipoProveedorId = await RequireActiveIdAsync(
                response.FkIdTipoProveedorSis,
                _context.TipoProveedors.AsNoTracking().Where(item => item.Activo).Select(item => item.PkIdTipoProveedor),
                "Tipo de proveedor");
            var estatusProveedorId = await RequireActiveIdAsync(
                response.FkidEstatusProveedorSis,
                _context.EstatusProveedors.AsNoTracking().Where(item => item.Activo).Select(item => item.PkidEstatusProveedor),
                "Estatus del proveedor");
            var cuentaAuxiliarId = await ValidateCuentaAuxiliarAsync(response.FkidCuentaContableSis);

            return new ProveedorDto
            {
                PkidProveedor = response.PkidProveedor,
                FkIdTipoProveedorSis = tipoProveedorId,
                FkidEstatusProveedorSis = estatusProveedorId,
                FkidCuentaContableSis = cuentaAuxiliarId,
                FkidPaisSis = location.PaisId,
                FkidEstadoSis = location.EstadoId,
                FkidMunicipioSis = location.MunicipioId,
                FkidResponsableSis = response.FkidResponsableSis > 0 ? response.FkidResponsableSis : null,
                FkidAesectorSis = response.FkidAesectorSis > 0 ? response.FkidAesectorSis : null,
                FkidAedivisionSis = response.FkidAedivisionSis > 0 ? response.FkidAedivisionSis : null,
                FkidAegrupoSis = response.FkidAegrupoSis > 0 ? response.FkidAegrupoSis : null,
                FkidAeclaseSis = response.FkidAeclaseSis > 0 ? response.FkidAeclaseSis : null,
                Nombre = nombre,
                Rfc = rfc,
                Email = email,
                Clave = clave,
                Calle = Trim(response.Calle, 50),
                Numero = Trim(response.Numero, 10),
                NumeroInt = Trim(response.NumeroInt, 10),
                Colonia = Trim(response.Colonia, 50),
                Cp = Trim(response.Cp, 50),
                Ciudad = Trim(response.Ciudad, 50),
                TelefonoInstitucional = Trim(response.TelefonoInstitucional, 20),
                PaginaWeb = Trim(response.PaginaWeb, 100),
                Notas = Trim(response.Notas, 500),
                Curp = Trim(response.Curp, 18),
                Activo = true
            };
        }

        private static void ApplyValues(Proveedor entity, ProveedorDto dto)
        {
            entity.FkIdTipoProveedorSis = dto.FkIdTipoProveedorSis;
            entity.FkidEstatusProveedorSis = dto.FkidEstatusProveedorSis;
            entity.FkidCuentaContableSis = dto.FkidCuentaContableSis;
            entity.FkidPaisSis = dto.FkidPaisSis;
            entity.FkidEstadoSis = dto.FkidEstadoSis;
            entity.FkidMunicipioSis = dto.FkidMunicipioSis;
            entity.FkidResponsableSis = dto.FkidResponsableSis;
            entity.FkidAesectorSis = dto.FkidAesectorSis;
            entity.FkidAedivisionSis = dto.FkidAedivisionSis;
            entity.FkidAegrupoSis = dto.FkidAegrupoSis;
            entity.FkidAeclaseSis = dto.FkidAeclaseSis;
            entity.Nombre = dto.Nombre;
            entity.Rfc = dto.Rfc;
            entity.Email = dto.Email;
            entity.Clave = dto.Clave;
            entity.Calle = dto.Calle;
            entity.Numero = dto.Numero;
            entity.NumeroInt = dto.NumeroInt;
            entity.Colonia = dto.Colonia;
            entity.Cp = dto.Cp;
            entity.Ciudad = dto.Ciudad;
            entity.TelefonoInstitucional = dto.TelefonoInstitucional;
            entity.PaginaWeb = dto.PaginaWeb;
            entity.Notas = dto.Notas;
            entity.Curp = dto.Curp;
            entity.Activo = dto.Activo;
            entity.FechaModificacion = dto.FechaModificacion;
            entity.UsuarioModificacion = dto.UsuarioModificacion;
        }

        private async Task<ProviderLocation> ResolveLocationAsync(ProveedorResponse response)
        {
            if (response.FkidMunicipioSis <= 0)
                throw new ArgumentException("Municipio es requerido.");

            var location = await FindLocationAsync(municipioId: response.FkidMunicipioSis)
                ?? throw new ArgumentException("El municipio seleccionado no existe o no esta activo.");

            // El municipio es la referencia geografica mas especifica. Algunos
            // proveedores heredados tienen pais/estado desactualizados; al editar
            // cualquier otro dato se bloqueaban aunque el municipio fuera valido.
            // ResolveLocationAsync devuelve la jerarquia canonica y el guardado
            // corrige esos identificadores automaticamente.
            return location;
        }

        private async Task<ProviderLocation?> FindLocationAsync(int? municipioId = null, int? estadoId = null, int? paisId = null)
        {
            var query =
                from municipio in _context.Municipios.AsNoTracking()
                join estado in _context.Estados.AsNoTracking() on municipio.FkidEstadoSis equals estado.PkidEstado
                join pais in _context.Paises.AsNoTracking() on estado.FkidPaisSis equals pais.PkidPais
                where municipio.Activo && estado.Activo && pais.Activo
                select new
                {
                    PaisId = pais.PkidPais,
                    EstadoId = estado.PkidEstado,
                    MunicipioId = municipio.PkidMunicipio
                };

            if (municipioId.GetValueOrDefault() > 0)
                query = query.Where(item => item.MunicipioId == municipioId!.Value);

            if (estadoId.GetValueOrDefault() > 0)
                query = query.Where(item => item.EstadoId == estadoId!.Value);

            if (paisId.GetValueOrDefault() > 0)
                query = query.Where(item => item.PaisId == paisId!.Value);

            var row = await query
                .OrderBy(item => item.PaisId)
                .ThenBy(item => item.EstadoId)
                .ThenBy(item => item.MunicipioId)
                .FirstOrDefaultAsync();

            return row == null
                ? null
                : new ProviderLocation(row.PaisId, row.EstadoId, row.MunicipioId);
        }

        private static async Task<int> RequireActiveIdAsync(int? requestedId, IQueryable<int> activeIds, string label)
        {
            if (requestedId.HasValue && requestedId.Value > 0 && await activeIds.AnyAsync(id => id == requestedId.Value))
                return requestedId.Value;

            throw new ArgumentException($"{label} es requerido y debe estar activo.");
        }

        private async Task<int?> ValidateCuentaAuxiliarAsync(int? cuentaId)
        {
            if (!cuentaId.HasValue || cuentaId.Value <= 0)
                return null;

            var valid = await _context.CuentaContables.AsNoTracking().AnyAsync(cuenta =>
                cuenta.PkidCuentaContable == cuentaId.Value &&
                cuenta.Activo &&
                cuenta.IsCuentaDetalle == 1 &&
                cuenta.ClaveOrd.Replace(" ", "").StartsWith("2112"));

            if (!valid)
                throw new ArgumentException("La cuenta seleccionada debe ser una cuenta activa de detalle bajo 2.1.1.2 Proveedores por pagar a corto plazo.");

            return cuentaId.Value;
        }

        private static string Required(string? value, string label, int maxLength)
        {
            var trimmed = Trim(value, maxLength);
            if (string.IsNullOrWhiteSpace(trimmed))
                throw new ArgumentException($"{label} es requerido.");

            return trimmed;
        }

        private static string Trim(string? value, int maxLength)
        {
            var trimmed = (value ?? string.Empty).Trim();
            return trimmed.Length <= maxLength ? trimmed : trimmed.Substring(0, maxLength);
        }

        private static string GenerateClave(string rfc, string nombre)
        {
            var source = string.IsNullOrWhiteSpace(rfc) ? nombre : rfc;
            var cleaned = new string(source.Where(char.IsLetterOrDigit).ToArray()).ToUpperInvariant();
            if (string.IsNullOrWhiteSpace(cleaned))
                cleaned = "PROV";

            return cleaned.Length <= 10 ? cleaned : cleaned.Substring(0, 10);
        }

        private sealed record ProviderLocation(int PaisId, int EstadoId, int MunicipioId);
    }
}

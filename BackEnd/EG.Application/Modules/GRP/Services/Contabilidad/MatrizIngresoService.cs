using Mapster;
using Microsoft.Extensions.Logging;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class MatrizIngresoService : IMatrizIngresoService
    {
        private readonly GenericService<MatrizIngreso, MatrizIngresoDto, MatrizIngresoResponse> _service;
        private readonly EGestionContext _context;

        public MatrizIngresoService(
            GenericService<MatrizIngreso, MatrizIngresoDto, MatrizIngresoResponse> service,
            EGestionContext context)
        {
            _service = service;
            _context = context;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.FkIdProgramaNavigation);
            _service.AddInclude(e => e.FkIdOrigenNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableAutorizadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContablePorEjercerNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableModificadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableDevengadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableRecaudadoNavigation);
            _service.AddInclude(e => e.FkIdCuentaContableDepositoNavigation);
            _service.AddInclude(e => e.FkIdAnioSisNavigation);
            _service.AddInclude(e => e.UsuarioCreacionNavigation);
        }

        public async Task<IEnumerable<MatrizIngresoResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<MatrizIngresoResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<MatrizIngresoResponse> CreateAsync(MatrizIngresoResponse request, int usuarioId)
        {
            await ValidateAsync(request, null);
            var dto = request.Adapt<MatrizIngresoDto>();
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            dto.Activo = true;

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidMatrizIngreso);
        }

        public async Task<MatrizIngresoResponse?> UpdateAsync(int id, MatrizIngresoResponse request, int usuarioId)
        {
            await ValidateAsync(request, id);
            var dto = request.Adapt<MatrizIngresoDto>();
            dto.PkidMatrizIngreso = id;
            dto.UsuarioModificacion = usuarioId;
            dto.FechaModificacion = DateTime.UtcNow;

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await _context.Set<MatrizIngreso>().FirstOrDefaultAsync(e => e.PkIdMatrizIngreso == id);
            if (existing == null) throw new KeyNotFoundException($"No se encontró el registro con ID {id}");

            existing.Activo = false;
            await _context.SaveChangesAsync();
        }

        public async Task<PagedResult<MatrizIngresoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            return await GetAllPaginadoAsync(request, 0);
        }

        public async Task<PagedResult<MatrizIngresoResponse>> GetAllPaginadoAsync(PagedRequest request, int usuarioId)
        {
            var query = _service.GetQueryWithIncludes();

            if (TryGetIntFilter(request, "FkIdAnioSis", out var anioId) ||
                TryGetIntFilter(request, "FkidAnioSis", out anioId))
            {
                query = query.Where(e => e.FkIdAnioSis == anioId);
            }

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e =>
                    e.FkIdProgramaNavigation.Clave.Contains(request.Filtro) ||
                    e.FkIdOrigenNavigation.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = request.SortDirection?.ToString().ToLower() == "ascending";
                query = request.SortLabel switch
                {
                    "PkidMatrizIngreso" => isAscending ? query.OrderBy(e => e.PkIdMatrizIngreso) : query.OrderByDescending(e => e.PkIdMatrizIngreso),
                    "ProgramaClave" => isAscending ? query.OrderBy(e => e.FkIdProgramaNavigation.Clave) : query.OrderByDescending(e => e.FkIdProgramaNavigation.Clave),
                    "OrigenDescripcion" => isAscending ? query.OrderBy(e => e.FkIdOrigenNavigation.Descripcion) : query.OrderByDescending(e => e.FkIdOrigenNavigation.Descripcion),
                    _ => query.OrderBy(e => e.PkIdMatrizIngreso)
                };
            }
            else
            {
                query = query.OrderBy(e => e.PkIdMatrizIngreso);
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var responseItems = items.Select(e => new MatrizIngresoResponse
            {
                PkidMatrizIngreso = e.PkIdMatrizIngreso,
                FkIdPrograma = e.FkIdPrograma,
                FkIdOrigen = e.FkIdOrigen,
                FkIdCuentaContableAutorizado = e.FkIdCuentaContableAutorizado,
                FkIdCuentaContablePorEjercer = e.FkIdCuentaContablePorEjercer,
                FkIdCuentaContableModificado = e.FkIdCuentaContableModificado,
                FkIdCuentaContableDevengado = e.FkIdCuentaContableDevengado,
                FkIdCuentaContableRecaudado = e.FkIdCuentaContableRecaudado,
                FkIdCuentaContableDeposito = e.FkIdCuentaContableDeposito,
                FkIdAnioSis = e.FkIdAnioSis,
                ProgramaClave = e.FkIdProgramaNavigation?.Clave ?? string.Empty,
                ProgramaDescripcion = e.FkIdProgramaNavigation?.Descripcion ?? string.Empty,
                OrigenDescripcion = e.FkIdOrigenNavigation?.Descripcion ?? string.Empty,
                CuentaAutorizadoNombre = e.FkIdCuentaContableAutorizadoNavigation != null ? e.FkIdCuentaContableAutorizadoNavigation.Cuenta + " - " + e.FkIdCuentaContableAutorizadoNavigation.Descripcion : null,
                CuentaPorEjecutarNombre = e.FkIdCuentaContablePorEjercerNavigation != null ? e.FkIdCuentaContablePorEjercerNavigation.Cuenta + " - " + e.FkIdCuentaContablePorEjercerNavigation.Descripcion : null,
                CuentaModificadoNombre = e.FkIdCuentaContableModificadoNavigation != null ? e.FkIdCuentaContableModificadoNavigation.Cuenta + " - " + e.FkIdCuentaContableModificadoNavigation.Descripcion : null,
                CuentaDevengadoNombre = e.FkIdCuentaContableDevengadoNavigation != null ? e.FkIdCuentaContableDevengadoNavigation.Cuenta + " - " + e.FkIdCuentaContableDevengadoNavigation.Descripcion : null,
                CuentaRecaudadoNombre = e.FkIdCuentaContableRecaudadoNavigation != null ? e.FkIdCuentaContableRecaudadoNavigation.Cuenta + " - " + e.FkIdCuentaContableRecaudadoNavigation.Descripcion : null,
                CuentaDepositoNombre = e.FkIdCuentaContableDepositoNavigation != null ? e.FkIdCuentaContableDepositoNavigation.Cuenta + " - " + e.FkIdCuentaContableDepositoNavigation.Descripcion : null,
                Activo = e.Activo,
                FechaCreacion = e.FechaCreacion,
                UsuarioCreacion = e.UsuarioCreacion
            }).ToList();

            return new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = responseItems,
                TotalCount = totalItems
            };
        }

        public async Task<IEnumerable<object>> GetProgramasAsync()
        {
            return await _context.Set<Programa>()
                .Select(p => new { PkidCuenta = p.PkidPrograma, ClaveNombre = p.Clave + " - " + p.Descripcion })
                .Distinct()
                .ToListAsync();
        }

        public async Task<IEnumerable<object>> GetOrigenAsync()
        {
            return await _context.Set<Origen>()
                .Where(o => o.Activo)
                .Select(o => new { PkidCuenta = o.PkidOrigen, ClaveNombre = o.Descripcion })
                .Distinct()
                .ToListAsync();
        }

        public async Task<IEnumerable<object>> GetCuentaContableAsync()
        {
            return await _context.VwCuentas
                .Where(c => c.Activo && c.NivelCuenta == 7)
                .Select(c => new { PkidCuenta = c.PkIdCuenta, ClaveNombre = c.ClaveNombre })
                .Distinct()
                .ToListAsync();
        }

        public async Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(int page, int pageSize, string? filter, int? idAnio)
        {
            var query = _context.Set<Programa>()
                .Where(p => p.Activo && (!idAnio.HasValue || p.FkidAnioSis == idAnio.Value))
                .OrderBy(p => p.Clave)
                .Select(p => new LookupItem
                {
                    Id = p.PkidPrograma,
                    Text = (p.Clave ?? "") + " - " + (p.Descripcion ?? "")
                });

            if (!string.IsNullOrWhiteSpace(filter))
            {
                query = query.Where(p => p.Text.Contains(filter));
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

        public async Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.Set<Origen>().AsNoTracking().Where(o => o.Activo);
            var normalizedFilter = filter?.Trim();

            if (!string.IsNullOrWhiteSpace(normalizedFilter))
            {
                query = query.Where(o => o.Descripcion != null && o.Descripcion.Contains(normalizedFilter));
            }

            var lookupQuery = query
                .OrderBy(o => o.Descripcion)
                .Select(o => new LookupItem
                {
                    Id = o.PkidOrigen,
                    Text = o.Descripcion ?? ""
                });

            var totalCount = await lookupQuery.CountAsync();
            var items = await lookupQuery
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

        public async Task<PagedResult<LookupItem>> GetCuentaContableLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.VwCuentas
                .AsNoTracking()
                .Where(c => c.Activo && c.NivelCuenta == 7);
            var normalizedFilter = filter?.Trim();

            if (!string.IsNullOrWhiteSpace(normalizedFilter))
            {
                query = query.Where(c => c.ClaveNombre != null && c.ClaveNombre.Contains(normalizedFilter));
            }

            var lookupQuery = query
                .OrderBy(c => c.ClaveNombre)
                .Select(c => new LookupItem
                {
                    Id = c.PkIdCuenta,
                    Text = c.ClaveNombre ?? ""
                });

            var totalCount = await lookupQuery.CountAsync();
            var items = await lookupQuery
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

        private async Task ValidateAsync(MatrizIngresoResponse request, int? currentId)
        {
            if (!request.FkIdAnioSis.HasValue || !request.FkIdPrograma.HasValue || !request.FkIdOrigen.HasValue)
                throw new InvalidOperationException("El ejercicio, programa y origen son obligatorios.");

            var programaValido = await _context.Set<Programa>().AsNoTracking().AnyAsync(p =>
                p.PkidPrograma == request.FkIdPrograma.Value &&
                p.FkidAnioSis == request.FkIdAnioSis.Value &&
                p.Activo);
            if (!programaValido)
                throw new InvalidOperationException("El programa no pertenece al ejercicio seleccionado o esta inactivo.");

            if (!await _context.Set<Origen>().AsNoTracking().AnyAsync(o => o.PkidOrigen == request.FkIdOrigen.Value && o.Activo))
                throw new InvalidOperationException("El origen seleccionado no existe o esta inactivo.");

            if (!request.FkIdCuentaContableAutorizado.HasValue)
                throw new InvalidOperationException("La cuenta de presupuesto autorizado es obligatoria.");

            var presupuestales = new[]
            {
                request.FkIdCuentaContableAutorizado,
                request.FkIdCuentaContablePorEjercer,
                request.FkIdCuentaContableModificado,
                request.FkIdCuentaContableDevengado,
                request.FkIdCuentaContableRecaudado
            }.Where(x => x.HasValue).Select(x => x!.Value).Distinct().ToList();

            var cuentasPresupuestalesValidas = await _context.VwCuentas.AsNoTracking().CountAsync(c =>
                presupuestales.Contains(c.PkIdCuenta) && c.Activo && c.NivelCuenta == 7 && c.ClaveOrd.StartsWith("8 1"));
            if (cuentasPresupuestalesValidas != presupuestales.Count)
                throw new InvalidOperationException("Las cuentas presupuestales de ingreso deben iniciar con 8 1 y ser de nivel 7.");

            if (request.FkIdCuentaContableDeposito.HasValue &&
                !await _context.VwCuentas.AsNoTracking().AnyAsync(c =>
                    c.PkIdCuenta == request.FkIdCuentaContableDeposito.Value &&
                    c.Activo && c.NivelCuenta == 7 && c.ClaveOrd.StartsWith("1")))
            {
                throw new InvalidOperationException("La cuenta de deposito debe iniciar con 1 y ser de nivel 7.");
            }

            var duplicate = await _context.Set<MatrizIngreso>().AsNoTracking().AnyAsync(x =>
                x.Activo &&
                x.PkIdMatrizIngreso != (currentId ?? 0) &&
                x.FkIdAnioSis == request.FkIdAnioSis &&
                x.FkIdPrograma == request.FkIdPrograma &&
                x.FkIdOrigen == request.FkIdOrigen &&
                x.FkIdCuentaContableAutorizado == request.FkIdCuentaContableAutorizado &&
                x.FkIdCuentaContablePorEjercer == request.FkIdCuentaContablePorEjercer &&
                x.FkIdCuentaContableModificado == request.FkIdCuentaContableModificado &&
                x.FkIdCuentaContableDevengado == request.FkIdCuentaContableDevengado &&
                x.FkIdCuentaContableRecaudado == request.FkIdCuentaContableRecaudado &&
                x.FkIdCuentaContableDeposito == request.FkIdCuentaContableDeposito);

            if (duplicate)
                throw new InvalidOperationException("La matriz de ingreso ya existe para el ejercicio y cuentas seleccionadas.");
        }
    }
}

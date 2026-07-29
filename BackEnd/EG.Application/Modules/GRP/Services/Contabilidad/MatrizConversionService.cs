using Mapster;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class MatrizConversionService : IMatrizConversionService
    {
        private readonly GenericService<MatrizConversion, MatrizConversionDto, MatrizConversionResponse> _service;
        private readonly IRepository<MatrizConversion> _repository;
        private readonly EGestionContext _context;

        public MatrizConversionService(
            GenericService<MatrizConversion, MatrizConversionDto, MatrizConversionResponse> service,
            IRepository<MatrizConversion> repository,
            EGestionContext context)
        {
            _service = service;
            _repository = repository;
            _context = context;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(mc => mc.FkidProgramaPresNavigation);
            _service.AddInclude(mc => mc.FkidPartidaSisNavigation);
            _service.AddInclude(mc => mc.FkidTipoGastoPresNavigation);
            _service.AddInclude(mc => mc.UsuarioCreacionNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContableAprobadoNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContablePorEjercerNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContableModificadoNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContableComprometidoNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContableDevengadoNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContableEjercidoNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContablePagadoNavigation);
            _service.AddInclude(mc => mc.FkidCuentaContableGastoNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueProgramaPartidaAnio", async (dto) =>
            {
                var mcDto = dto as MatrizConversionDto;
                if (mcDto == null) return true;

                return !_service.GetQueryWithIncludes()
                .Any(e => e.FkidAnioSis == mcDto.FkidAnioSis &&
                e.FkidProgramaPres == mcDto.FkidProgramaPres &&
                e.FkidPartidaSis == mcDto.FkidPartidaSis &&
                e.FkidTipoGastoPres == mcDto.FkidTipoGastoPres &&
                e.Activo);
            });

            _service.AddValidationRuleWithId("UniqueProgramaPartidaAnioUpdate", async (dto, id) =>
            {
                var mcDto = dto as MatrizConversionDto;
                if (mcDto == null || !id.HasValue) return true;

                return !_service.GetQueryWithIncludes()
                .Any(e => e.FkidAnioSis == mcDto.FkidAnioSis &&
                e.FkidProgramaPres == mcDto.FkidProgramaPres &&
                e.FkidPartidaSis == mcDto.FkidPartidaSis &&
                e.FkidTipoGastoPres == mcDto.FkidTipoGastoPres &&
                e.PkidMatrizConversion != id.Value &&
                e.Activo);
            });
        }

        public async Task<IEnumerable<MatrizConversionResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<MatrizConversionResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<MatrizConversionResponse> AddAsync(MatrizConversionDto dto, int usuarioId)
        {
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            dto.Activo = true;

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidMatrizConversion)
                ?? throw new InvalidOperationException("No fue posible recuperar la matriz de conversion creada.");
        }

        public async Task UpdateAsync(int id, MatrizConversionDto dto, int usuarioId)
        {
            dto.UsuarioModificacion = usuarioId;
            dto.FechaModificacion = DateTime.UtcNow;

            await _service.UpdateAsync(id, dto);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await GetByIdAsync(id);
            if (existing == null) throw new KeyNotFoundException($"MatrizConversion con ID {id} no encontrado");

            var usadaPorPresupuesto = await _context.VwEgresoAutorizados.AsNoTracking().AnyAsync(e =>
                e.FkidAnioSis == existing.FkidAnioSis &&
                e.FkidProgramaPres == existing.FkidProgramaPres &&
                e.FkidPartidaConta == existing.FkidPartidaSis);

            if (usadaPorPresupuesto)
            {
                throw new InvalidOperationException(
                    "No puede eliminar la matriz porque esta relacionada con presupuesto autorizado.");
            }

            var dto = new MatrizConversionDto
            {
                PkidMatrizConversion = existing.PkidMatrizConversion,
                FkidAnioSis = existing.FkidAnioSis,
                FkidProgramaPres = existing.FkidProgramaPres,
                FkidPartidaSis = existing.FkidPartidaSis,
                FkidTipoGastoPres = existing.FkidTipoGastoPres,
                FkidCuentaContableAprobado = existing.FkidCuentaContableAprobado,
                FkidCuentaContablePorEjercer = existing.FkidCuentaContablePorEjercer,
                FkidCuentaContableModificado = existing.FkidCuentaContableModificado,
                FkidCuentaContableComprometido = existing.FkidCuentaContableComprometido,
                FkidCuentaContableDevengado = existing.FkidCuentaContableDevengado,
                FkidCuentaContableEjercido = existing.FkidCuentaContableEjercido,
                FkidCuentaContablePagado = existing.FkidCuentaContablePagado,
                FkidCuentaContableGasto = existing.FkidCuentaContableGasto,
                Activo = false
            };

            await _service.UpdateAsync(id, dto);
        }

public async Task<PagedResult<MatrizConversionResponse>> GetAllPaginadoAsync(PagedRequest request, Dictionary<string, object>? additionalFilters = null)
{
    var query = _context.VwMatrizConversionColumnas.AsQueryable();

    if (additionalFilters != null)
    {
        if (additionalFilters.ContainsKey("FkidAnioSis") && additionalFilters["FkidAnioSis"] != null)
        {
            var anioId = Convert.ToInt32(additionalFilters["FkidAnioSis"]);
            query = query.Where(e => e.AnioClave == anioId);
        }
    }

    // Filtro de búsqueda
    if (!string.IsNullOrWhiteSpace(request.Filtro))
    {
        query = query.Where(e =>
        e.ProgramaClave.Contains(request.Filtro) ||
        e.PartidaDescripcion.Contains(request.Filtro));
    }

    // Ordenamiento
    if (!string.IsNullOrEmpty(request.SortLabel))
    {
        var isAscending = request.SortDirection?.ToString().ToLower() == "asc";
        query = request.SortLabel switch
        {
            "PkidMatrizConversion" => isAscending ? query.OrderBy(e => e.PkidMatrizConversion) : query.OrderByDescending(e => e.PkidMatrizConversion),
            "ProgramaClave" => isAscending ? query.OrderBy(e => e.ProgramaClave) : query.OrderByDescending(e => e.ProgramaClave),
            "PartidaDescripcion" => isAscending ? query.OrderBy(e => e.PartidaDescripcion) : query.OrderByDescending(e => e.PartidaDescripcion),
            _ => query.OrderBy(e => e.ProgramaClave)
        };
    }

    var totalItems = await query.CountAsync();
    var items = await query
        .Skip((request.Page - 1) * request.PageSize)
        .Take(request.PageSize)
        .ToListAsync();

    var ids = items.Select(e => e.PkidMatrizConversion).ToList();
    var tiposGasto = await _context.MatrizConversions.AsNoTracking()
        .Where(e => ids.Contains(e.PkidMatrizConversion))
        .Select(e => new
        {
            e.PkidMatrizConversion,
            e.FkidTipoGastoPres,
            e.FkidTipoGastoPresNavigation.Clave,
            e.FkidTipoGastoPresNavigation.Descripcion
        })
        .ToDictionaryAsync(e => e.PkidMatrizConversion);

    // Mapear a MatrizConversionResponse
    var responseItems = items.Select(e => new MatrizConversionResponse
    {
        PkidMatrizConversion = e.PkidMatrizConversion,
        FkidAnioSis = e.AnioClave,
        FkidTipoGastoPres = tiposGasto.TryGetValue(e.PkidMatrizConversion, out var tipo) ? tipo.FkidTipoGastoPres : 0,
        TipoGastoClave = tiposGasto.TryGetValue(e.PkidMatrizConversion, out var tipoClave) ? tipoClave.Clave : 0,
        TipoGastoDescripcion = tiposGasto.TryGetValue(e.PkidMatrizConversion, out var tipoDescripcion) ? tipoDescripcion.Descripcion : string.Empty,
        ProgramaClave = e.ProgramaClave,
        PartidaDescripcion = e.PartidaDescripcion,
        CuentaAprobadoNombre = e.CuentaAprobado,
        CuentaPorEjercerNombre = e.CuentaPorEjercer,
        CuentaModificadoNombre = e.CuentaModificado,
        CuentaComprometidoNombre = e.CuentaComprometido,
        CuentaDevengadoNombre = e.CuentaDevengado,
        CuentaEjercidoNombre = e.CuentaEjercido,
        CuentaPagadoNombre = e.CuentaPagado,
        CuentaGastoNombre = e.CuentaGasto,
        Activo = e.Activo,
        FechaCreacion = e.FechaCreacion,
        UsuarioCreacion = e.UsuarioCreacion
    }).ToList();

    return new PagedResult<MatrizConversionResponse>
    {
        Items = responseItems,
        TotalCount = totalItems,
        Success = true,
        Message = "OK",
        Code = "SUCCESS"
    };
}

        public async Task<bool> CanAddAsync(MatrizConversionDto dto)
        {
            return await _service.CanAddAsync(dto);
        }

        public async Task<bool> CanUpdateAsync(int id, MatrizConversionDto dto)
        {
            return await _service.CanUpdateAsync(id, dto);
        }

        public async Task<bool> ExisteRegistroAsync(int anioSis, int programaPres, int partidaSis, int tipoGastoPres)
        {
            return await _service.GetQueryWithIncludes()
            .AnyAsync(e => e.FkidAnioSis == anioSis &&
            e.FkidProgramaPres == programaPres &&
            e.FkidPartidaSis == partidaSis &&
            e.FkidTipoGastoPres == tipoGastoPres &&
            e.Activo);
        }

        public async Task<bool> ExisteRegistroUpdateAsync(int id, int anioSis, int programaPres, int partidaSis, int tipoGastoPres)
        {
            return await _service.GetQueryWithIncludes()
            .AnyAsync(e => e.FkidAnioSis == anioSis &&
            e.FkidProgramaPres == programaPres &&
            e.FkidPartidaSis == partidaSis &&
            e.FkidTipoGastoPres == tipoGastoPres &&
            e.PkidMatrizConversion != id &&
            e.Activo);
        }

        public async Task<IEnumerable<dynamic>> GetProgramasAsync(int? idAnio = null)
        {
            var query = _context.Set<Programa>().AsQueryable();
            if (idAnio.HasValue)
            {
                query = query.Where(p => p.MatrizConversions.Any(mc => mc.FkidAnioSis == idAnio.Value && mc.Activo));
            }
            return await query.Select(p => new { p.PkidPrograma, p.Clave }).Distinct().ToListAsync();
        }
    }
}

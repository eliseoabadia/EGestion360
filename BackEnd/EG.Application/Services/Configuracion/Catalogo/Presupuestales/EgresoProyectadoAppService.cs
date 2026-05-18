using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class EgresoProyectadoAppService
        : AdquisicionCrudAppService<EgresoProyectado, VwEgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse>,
            IEgresoProyectadoAppService
    {
        public EgresoProyectadoAppService(
            GenericService<EgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse> service,
            GenericService<VwEgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidEgresoProyectado",
                "Anteproyecto de egresos",
                (dto, id) => dto.PkidEgresoProyectado = id)
        {
            _context = context;
        }

        private readonly EGestionContext _context;

        public override Task<PagedResult<EgresoProyectadoResponse>> CreateAsync(EgresoProyectadoResponse response, int usuarioActual)
        {
            ClearMonthsBeforeStartDate(response);
            return base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<EgresoProyectadoResponse>> UpdateAsync(int id, EgresoProyectadoResponse response, int usuarioActual)
        {
            if (await IsAuthorizedAsync(id))
            {
                return Locked(id, "El anteproyecto ya fue autorizado y no puede editarse.");
            }

            ClearMonthsBeforeStartDate(response);
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            if (await IsAuthorizedAsync(id))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "El anteproyecto ya fue autorizado y no puede eliminarse.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            return await base.DeleteAsync(id);
        }

        public async Task<PagedResult<bool>> EstaAutorizadoAsync(int id)
        {
            var isAuthorized = await IsAuthorizedAsync(id);
            return new PagedResult<bool>
            {
                Success = true,
                Message = isAuthorized ? "El anteproyecto esta autorizado." : "El anteproyecto no esta autorizado.",
                Code = "SUCCESS",
                Data = isAuthorized,
                Items = new List<bool> { isAuthorized },
                TotalCount = 1
            };
        }

        public Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.FuenteFinanciamientos
                .AsNoTracking()
                .Where(x => x.Activo && (x.Clave ?? string.Empty).Trim() != "6");

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidFuenteFinanciamiento, Text = BuildText(x.Clave, x.Descripcion) },
                "Fuentes de financiamiento obtenidas correctamente");
        }

        public Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.TipoGastos
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x => EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidTipoGasto, Text = BuildText(x.Clave, x.Descripcion) },
                "Tipos de gasto obtenidos correctamente");
        }

        public Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.DigitoIdentificadors
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidDigitoIdentificador, Text = BuildText(x.Clave, x.Descripcion) },
                "Digitos identificadores obtenidos correctamente");
        }

        public Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.DestinoGastos
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidDestinoGasto, Text = BuildText(x.Clave, x.Descripcion) },
                "Destinos de gasto obtenidos correctamente");
        }

        public Task<PagedResult<LookupItem>> GetPyLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.Pies
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term) ||
                    EF.Functions.Like(x.NombreProyecto ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidPy, Text = BuildText(x.Clave, x.Descripcion) },
                "Proyectos PY obtenidos correctamente");
        }

        private async Task<bool> IsAuthorizedAsync(int id)
        {
            return await _context.EgresoAutorizados
                .AnyAsync(x => x.FkidEgresoProyectadoPres == id && x.Activo);
        }

        private static PagedResult<EgresoProyectadoResponse> Locked(int id, string message)
        {
            return new PagedResult<EgresoProyectadoResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static void ClearMonthsBeforeStartDate(EgresoProyectadoResponse response)
        {
            var startMonth = response.Fecha.Month;

            if (startMonth > 1) response.Enero = 0m;
            if (startMonth > 2) response.Febrero = 0m;
            if (startMonth > 3) response.Marzo = 0m;
            if (startMonth > 4) response.Abril = 0m;
            if (startMonth > 5) response.Mayo = 0m;
            if (startMonth > 6) response.Junio = 0m;
            if (startMonth > 7) response.Julio = 0m;
            if (startMonth > 8) response.Agosto = 0m;
            if (startMonth > 9) response.Septiembre = 0m;
            if (startMonth > 10) response.Octubre = 0m;
            if (startMonth > 11) response.Noviembre = 0m;

            response.Total = response.Enero + response.Febrero + response.Marzo + response.Abril +
                response.Mayo + response.Junio + response.Julio + response.Agosto +
                response.Septiembre + response.Octubre + response.Noviembre + response.Diciembre;
        }

        private static async Task<PagedResult<LookupItem>> ToLookupResultAsync<T>(
            IQueryable<T> query,
            int page,
            int pageSize,
            Func<T, LookupItem> map,
            string message)
        {
            var currentPage = Math.Max(1, page);
            var currentPageSize = pageSize <= 0 ? 25 : pageSize;
            var totalCount = await query.CountAsync();
            var rows = await query
                .Skip((currentPage - 1) * currentPageSize)
                .Take(currentPageSize)
                .ToListAsync();

            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = rows.Select(map).Where(x => !string.IsNullOrWhiteSpace(x.Text)).ToList(),
                TotalCount = totalCount
            };
        }

        private static string BuildText(string? clave, string? descripcion)
        {
            if (string.IsNullOrWhiteSpace(clave))
            {
                return descripcion ?? string.Empty;
            }

            return string.IsNullOrWhiteSpace(descripcion)
                ? clave
                : $"{clave} - {descripcion}";
        }

        private static string BuildText(int clave, string? descripcion)
        {
            return string.IsNullOrWhiteSpace(descripcion)
                ? clave.ToString()
                : $"{clave} - {descripcion}";
        }
    }
}

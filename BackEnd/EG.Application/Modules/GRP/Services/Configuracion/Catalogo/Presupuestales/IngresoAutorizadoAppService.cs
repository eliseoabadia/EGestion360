using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class IngresoAutorizadoAppService
        : StoredProcedureCrudAppService<IngresoAutorizado, VwIngresoAutorizado, IngresoAutorizadoDto, IngresoAutorizadoResponse>,
            IIngresoAutorizadoAppService
    {
        private const string StoredProcedure = "PRES.sp_MantenimientoIngresoAutorizado";
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public IngresoAutorizadoAppService(
            GenericService<IngresoAutorizado, IngresoAutorizadoDto, IngresoAutorizadoResponse> service,
            GenericService<VwIngresoAutorizado, IngresoAutorizadoDto, IngresoAutorizadoResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                context,
                "PkidIngresoAutorizado",
                "Ingreso autorizado",
                (dto, id) => dto.PkidIngresoAutorizado = id,
                StoredProcedure,
                response => response.PkidIngresoAutorizado,
                BuildParameters)
        {
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<IngresoAutorizadoResponse>> CreateAsync(
            IngresoAutorizadoResponse response,
            int usuarioActual)
        {
            var contextFailure = ValidateEmpresaContext<IngresoAutorizadoResponse>();
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);
            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<IngresoAutorizadoResponse>> UpdateAsync(
            int id,
            IngresoAutorizadoResponse response,
            int usuarioActual)
        {
            var contextFailure = ValidateEmpresaContext<IngresoAutorizadoResponse>();
            if (contextFailure != null)
                return contextFailure;

            Normalize(response);
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var contextFailure = ValidateEmpresaContext<bool>();
            if (contextFailure != null)
                return contextFailure;

            var existing = await GetByIdAsync(id);
            if (!existing.Success)
                return Failure<bool>(existing.Message, existing.Code ?? "NOT_FOUND");

            try
            {
                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(3, id, null, _userContext.GetCurrentUserId()));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = [true],
                    TotalCount = 1
                };
            }
            catch (UserVisibleException ex)
            {
                return Failure<bool>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("eliminar", ex);
                return Failure<bool>("No fue posible eliminar el ingreso autorizado.");
            }
        }

        public async Task<PagedResult<IngresoAutorizadoResponse>> AutorizarAsync(int id)
        {
            var contextFailure = ValidateEmpresaContext<IngresoAutorizadoResponse>();
            if (contextFailure != null)
                return contextFailure;

            try
            {
                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(4, id, null, _userContext.GetCurrentUserId()));

                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (UserVisibleException ex)
            {
                return Failure<IngresoAutorizadoResponse>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("autorizar", ex);
                return Failure<IngresoAutorizadoResponse>("No fue posible autorizar el ingreso y su poliza.");
            }
        }

        public async Task<PagedResult<IngresoAutorizadoPolizaResponse>> GetPolizaAsync(int id)
        {
            var header = await (
                from ia in _context.IngresoAutorizados.AsNoTracking()
                join p in _context.Polizas.AsNoTracking() on ia.FkidPolizaConta equals p.PkidPoliza
                where ia.PkidIngresoAutorizado == id && ia.Activo && p.Activo
                select new IngresoAutorizadoPolizaResponse
                {
                    PkidIngresoAutorizado = ia.PkidIngresoAutorizado,
                    PkidPoliza = p.PkidPoliza,
                    ClavePoliza = p.ClavePoliza,
                    NombrePoliza = p.NombrePoliza,
                    FechaPoliza = p.FechaPoliza,
                    EstaBalanceado = p.EstaBalanceado,
                    Autorizado = p.Autorizado,
                    PermitirModificar = p.PermitirModificar
                }).FirstOrDefaultAsync();

            if (header == null)
                return Failure<IngresoAutorizadoPolizaResponse>("No se encontro la poliza del ingreso.", "NOT_FOUND");

            header.Detalles = await (
                from pd in _context.PolizaDetalles.AsNoTracking()
                join cc in _context.CuentaContables.AsNoTracking()
                    on pd.FkidCuentaContableConta equals cc.PkidCuentaContable
                where pd.FkidPolizaConta == header.PkidPoliza
                   && pd.FkidReferencia == id
                   && pd.Activo
                orderby pd.FkidTipoDetallePolizaSis, pd.PkidPolizaDetalle
                select new IngresoAutorizadoPolizaDetalleResponse
                {
                    PkidPolizaDetalle = pd.PkidPolizaDetalle,
                    FkidCuentaContableConta = pd.FkidCuentaContableConta,
                    Cuenta = cc.Cuenta,
                    CuentaDescripcion = cc.Descripcion,
                    Descripcion = pd.Descripcion,
                    ImporteDebe = pd.ImporteDebe ?? 0m,
                    ImporteHaber = pd.ImporteHaber ?? 0m,
                    FkidTipoDetallePolizaSis = pd.FkidTipoDetallePolizaSis
                }).ToListAsync();

            header.TotalDebe = header.Detalles.Sum(x => x.ImporteDebe);
            header.TotalHaber = header.Detalles.Sum(x => x.ImporteHaber);

            return new PagedResult<IngresoAutorizadoPolizaResponse>
            {
                Success = true,
                Message = "Poliza obtenida correctamente.",
                Code = "SUCCESS",
                Data = header,
                Items = [header],
                TotalCount = 1
            };
        }

        public Task<PagedResult<LookupItem>> GetProgramaLookupPaginadoAsync(
            int page,
            int pageSize,
            string? filter,
            int? idAnio)
        {
            var query = _context.Programas.AsNoTracking().Where(x => x.Activo);

            if (idAnio.HasValue && idAnio.Value > 0)
                query = query.Where(x => x.FkidAnioSis == idAnio.Value);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave, term) ||
                    EF.Functions.Like(x.Descripcion, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Clave),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidPrograma, Text = BuildText(x.Clave, x.Descripcion) });
        }

        public Task<PagedResult<LookupItem>> GetOrigenLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.Origens.AsNoTracking().Where(x => x.Activo);
            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x => EF.Functions.Like(x.Descripcion, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Clave),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidOrigen, Text = BuildText(x.Clave, x.Descripcion) });
        }

        public Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.FuenteFinanciamientos.AsNoTracking().Where(x => x.Activo);
            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Clave),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidFuenteFinanciamiento, Text = BuildText(x.Clave, x.Descripcion) });
        }

        public Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.TipoGastos.AsNoTracking().Where(x => x.Activo);
            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x => EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Clave),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidTipoGasto, Text = BuildText(x.Clave, x.Descripcion) });
        }

        public Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.DigitoIdentificadors.AsNoTracking().Where(x => x.Activo);
            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave, term) ||
                    EF.Functions.Like(x.Descripcion, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Clave),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidDigitoIdentificador, Text = BuildText(x.Clave, x.Descripcion) });
        }

        public Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.DestinoGastos.AsNoTracking().Where(x => x.Activo);
            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave, term) ||
                    EF.Functions.Like(x.Descripcion, term));
            }

            return ToLookupResultAsync(
                query.OrderBy(x => x.Clave),
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidDestinoGasto, Text = BuildText(x.Clave, x.Descripcion) });
        }

        private PagedResult<T>? ValidateEmpresaContext<T>()
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            return empresaId.HasValue && empresaId.Value > 0
                ? null
                : Failure<T>("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");
        }

        private static void Normalize(IngresoAutorizadoResponse response)
        {
            response.Descripcion = response.Descripcion?.Trim();
            response.Total = response.Enero + response.Febrero + response.Marzo + response.Abril +
                response.Mayo + response.Junio + response.Julio + response.Agosto +
                response.Septiembre + response.Octubre + response.Noviembre + response.Diciembre;
        }

        private static SqlParameter[] BuildParameters(
            int action,
            int? id,
            IngresoAutorizadoResponse? response,
            int? usuarioActual)
        {
            DateTime? fecha = response == null
                ? null
                : response.Fecha.ToDateTime(TimeOnly.MinValue);

            return
            [
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdIngresoAutorizado", id ?? response?.PkidIngresoAutorizado),
                StoredProcedureExecutor.Param("@FKIdPrograma_PRES", response?.FkidProgramaPres),
                StoredProcedureExecutor.Param("@FKIdOrigen_PRES", response?.FkidOrigenPres),
                StoredProcedureExecutor.Param("@Descripcion", response?.Descripcion),
                StoredProcedureExecutor.Param("@Fecha", fecha),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@Enero", response?.Enero),
                StoredProcedureExecutor.Param("@Febrero", response?.Febrero),
                StoredProcedureExecutor.Param("@Marzo", response?.Marzo),
                StoredProcedureExecutor.Param("@Abril", response?.Abril),
                StoredProcedureExecutor.Param("@Mayo", response?.Mayo),
                StoredProcedureExecutor.Param("@Junio", response?.Junio),
                StoredProcedureExecutor.Param("@Julio", response?.Julio),
                StoredProcedureExecutor.Param("@Agosto", response?.Agosto),
                StoredProcedureExecutor.Param("@Septiembre", response?.Septiembre),
                StoredProcedureExecutor.Param("@Octubre", response?.Octubre),
                StoredProcedureExecutor.Param("@Noviembre", response?.Noviembre),
                StoredProcedureExecutor.Param("@Diciembre", response?.Diciembre),
                StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", response?.FkidFuenteFinanciamientoPres),
                StoredProcedureExecutor.Param("@FKIdTipoGasto_PRES", response?.FkidTipoGastoPres),
                StoredProcedureExecutor.Param("@FKIdDigitoIdentificador_PRES", response?.FkidDigitoIdentificadorPres),
                StoredProcedureExecutor.Param("@FKIdDestinoGasto_PRES", response?.FkidDestinoGastoPres),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@Id", id)
            ];
        }

        private static async Task<PagedResult<LookupItem>> ToLookupResultAsync<T>(
            IQueryable<T> query,
            int page,
            int pageSize,
            Func<T, LookupItem> map)
        {
            var currentPage = Math.Max(1, page);
            var currentPageSize = pageSize <= 0 ? 25 : pageSize;
            var totalCount = await query.CountAsync();
            var rows = await query.Skip((currentPage - 1) * currentPageSize).Take(currentPageSize).ToListAsync();

            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = "Catalogo obtenido correctamente.",
                Code = "SUCCESS",
                Items = rows.Select(map).ToList(),
                TotalCount = totalCount
            };
        }

        private static string BuildText(string? clave, string? descripcion)
            => string.IsNullOrWhiteSpace(clave)
                ? descripcion ?? string.Empty
                : string.IsNullOrWhiteSpace(descripcion) ? clave : $"{clave} - {descripcion}";

        private static string BuildText(int clave, string? descripcion)
            => BuildText(clave.ToString(), descripcion);

    }
}

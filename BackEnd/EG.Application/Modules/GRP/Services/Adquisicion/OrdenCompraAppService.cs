using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class OrdenCompraAppService
        : AdquisicionCrudAppService<OrdenCompra, VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse>,
            IOrdenCompraAppService
    {
        private const int EstatusInicial = 1;
        private const int EstatusPorSurtir = 2;

        private readonly EGestionContext _context;

        public OrdenCompraAppService(
            GenericService<OrdenCompra, OrdenCompraDto, OrdenCompraResponse> service,
            GenericService<VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidOrdenCompra",
                "Orden de compra",
                (dto, id) => dto.PkidOrdenCompra = id)
        {
            _context = context;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            await ApplyChildCountsAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success)
            {
                await ApplyChildCountsAsync(result.Items);
                if (result.Data != null)
                {
                    await ApplyChildCountsAsync(new List<OrdenCompraResponse> { result.Data });
                }
            }

            return result;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            await ApplyChildCountsAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<OrdenCompraResponse>> CreateAsync(
            OrdenCompraResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidOrdenCompra = spResult.GetId() ?? 0;

                var result = await GetByIdAsync(response.PkidOrdenCompra);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<OrdenCompraResponse>($"Error al crear orden de compra: {ex.Message}");
            }
        }

        public override async Task<PagedResult<OrdenCompraResponse>> UpdateAsync(
            int id,
            OrdenCompraResponse response,
            int usuarioActual)
        {
            var current = await GetActiveOrdenAsync(id);
            if (current == null)
            {
                return Failure<OrdenCompraResponse>($"Orden de compra con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (IsLocked(current.FkidEstatusOrdenCompraOrco))
            {
                return Failure<OrdenCompraResponse>("La orden de compra ya fue autorizada. No se puede editar.", "LOCKED");
            }

            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.FkidEstatusOrdenCompraOrco = current.FkidEstatusOrdenCompraOrco;

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<OrdenCompraResponse>($"Error al actualizar orden de compra: {ex.Message}");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await GetActiveOrdenAsync(id);
            if (current == null)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Orden de compra con ID {id} no encontrada.",
                    Code = "NOT_FOUND",
                    Data = false,
                    TotalCount = 0
                };
            }

            if (IsLocked(current.FkidEstatusOrdenCompraOrco))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La orden de compra ya fue autorizada. No se puede eliminar.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoOrdenCompra]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdOrdenCompra", id));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
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
                    Message = $"Error al eliminar orden de compra: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<OrdenCompraResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var result = await GetByIdAsync(id);
            if (!result.Success || result.Data == null)
            {
                return Failure<OrdenCompraResponse>($"Orden de compra con ID {id} no encontrada.", "NOT_FOUND");
            }

            var orden = result.Data;
            if (orden.FkidEstatusOrdenCompraOrco != EstatusInicial)
            {
                return Failure<OrdenCompraResponse>("Solo se pueden autorizar ordenes de compra en estatus INICIAL.", "LOCKED");
            }

            var tieneDetalles = await _context.OrdenCompraDetalles
                .AnyAsync(x => x.FkidOrdenCompraOrco == id && x.Activo);

            if (!tieneDetalles)
            {
                return Failure<OrdenCompraResponse>("Agrega al menos un detalle antes de autorizar la orden de compra.");
            }

            orden.FkidEstatusOrdenCompraOrco = EstatusPorSurtir;

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, orden, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = string.IsNullOrWhiteSpace(spResult.Mensaje)
                    ? "Orden de compra autorizada correctamente."
                    : "Orden de compra autorizada correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<OrdenCompraResponse>($"Error al autorizar orden de compra: {ex.Message}");
            }
        }

        private async Task<PagedResult<OrdenCompraResponse>?> NormalizeAndValidateAsync(
            OrdenCompraResponse response,
            bool isCreate)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<OrdenCompraResponse>("Debe existir una empresa seleccionada.");
            }

            if (response.FkidRequisicionOrco <= 0)
            {
                return Failure<OrdenCompraResponse>("Debe seleccionar una requisicion.");
            }

            if (response.FkidProveedorSis <= 0)
            {
                return Failure<OrdenCompraResponse>("Debe seleccionar un proveedor.");
            }

            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<OrdenCompraResponse>("La descripcion es requerida.");
            }

            if (response.FechaOrdenCompra == default)
            {
                response.FechaOrdenCompra = DateTime.Today;
            }

            if (isCreate || response.FkidEstatusOrdenCompraOrco <= 0)
            {
                response.FkidEstatusOrdenCompraOrco = EstatusInicial;
            }

            response.NumeroOrdenCompra ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.MotivoCancelacion ??= string.Empty;
            response.FlDocumento ??= string.Empty;
            response.TipoCambio ??= 1m;

            var requisicion = await _context.Requisicions
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidRequisicion == response.FkidRequisicionOrco && x.Activo);

            if (requisicion == null)
            {
                return Failure<OrdenCompraResponse>("La requisicion seleccionada no existe o esta inactiva.");
            }

            if (response.FechaOrdenCompra.Date < requisicion.FechaRequisicion.Date)
            {
                return Failure<OrdenCompraResponse>("La fecha de la orden de compra debe ser igual o mayor a la fecha de requisicion.");
            }

            return null;
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            OrdenCompraResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoOrdenCompra]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdOrdenCompra", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdRequisicion_ORCO", response.FkidRequisicionOrco),
                StoredProcedureExecutor.Param("@FKIdProveedor_SIS", response.FkidProveedorSis),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response.FkidPolizaConta),
                StoredProcedureExecutor.Param("@FKIdEstatusOrdenCompra_ORCO", response.FkidEstatusOrdenCompraOrco),
                StoredProcedureExecutor.Param("@NumeroOrdenCompra", response.NumeroOrdenCompra),
                StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                StoredProcedureExecutor.Param("@FechaOrdenCompra", response.FechaOrdenCompra.Date),
                StoredProcedureExecutor.Param("@FechaRequerida", response.FechaRequerida?.Date),
                StoredProcedureExecutor.Param("@FechaEntrega", response.FechaEntrega?.Date),
                StoredProcedureExecutor.Param("@FechaVigencia", response.FechaVigencia?.Date),
                StoredProcedureExecutor.Param("@FechaCancelacion", response.FechaCancelacion?.Date),
                StoredProcedureExecutor.Param("@MotivoCancelacion", response.MotivoCancelacion),
                StoredProcedureExecutor.Param("@Subtotal", response.Subtotal),
                StoredProcedureExecutor.Param("@Iva", response.Iva),
                StoredProcedureExecutor.Param("@Total", response.Total),
                StoredProcedureExecutor.Param("@MonedaId", response.MonedaId),
                StoredProcedureExecutor.Param("@TipoCambio", response.TipoCambio),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@CompraDirecta", response.CompraDirecta),
                StoredProcedureExecutor.Param("@FL_Documento", response.FlDocumento),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@IdAnio", response.FechaOrdenCompra.Year));
        }

        private async Task ApplyChildCountsAsync(IList<OrdenCompraResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var ids = items.Select(x => x.PkidOrdenCompra).Distinct().ToList();
            var detalles = await _context.OrdenCompraDetalles
                .Where(x => ids.Contains(x.FkidOrdenCompraOrco) && x.Activo)
                .GroupBy(x => x.FkidOrdenCompraOrco)
                .Select(x => new { Id = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.Id, x => x.Count);

            var partidas = await _context.OrdenCompraPartida
                .Where(x => ids.Contains(x.FkidOrdenCompraOrco) && x.Activo)
                .GroupBy(x => x.FkidOrdenCompraOrco)
                .Select(x => new { Id = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.Id, x => x.Count);

            foreach (var item in items)
            {
                item.TotalDetalles = detalles.TryGetValue(item.PkidOrdenCompra, out var totalDetalles) ? totalDetalles : 0;
                item.TotalPartidas = partidas.TryGetValue(item.PkidOrdenCompra, out var totalPartidas) ? totalPartidas : 0;
            }
        }

        private Task<OrdenCompra?> GetActiveOrdenAsync(int id)
        {
            return _context.OrdenCompras
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidOrdenCompra == id && x.Activo);
        }

        private static bool IsLocked(int estatusId) => estatusId > EstatusInicial;

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
    }
}

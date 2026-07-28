using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class RequisicionDetalleAppService
        : AdquisicionCrudAppService<RequisicionDetalle, VwRequisicionDetalle, RequisicionDetalleDto, RequisicionDetalleResponse>,
            IRequisicionDetalleAppService
    {
        private readonly GenericService<Cotizacion, CotizacionDto, CotizacionResponse> _cotizacionService;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public RequisicionDetalleAppService(
            GenericService<RequisicionDetalle, RequisicionDetalleDto, RequisicionDetalleResponse> service,
            GenericService<VwRequisicionDetalle, RequisicionDetalleDto, RequisicionDetalleResponse> serviceView,
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> cotizacionService,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidRequisicionDetalle",
                "Detalle de requisicion",
                (dto, id) => dto.PkidRequisicionDetalle = id)
        {
            _cotizacionService = cotizacionService;
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<RequisicionDetalleResponse>> CreateAsync(
            RequisicionDetalleResponse response,
            int usuarioActual)
        {
            var requisicion = await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(
                _context, _userContext, response.FkidRequisicionOrco);
            if (requisicion == null)
                return NotFoundResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, response.FkidRequisicionOrco))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para agregar bienes.");
            }

            if (ExistsDuplicate(response.FkidRequisicionOrco, response.FkidTipoBienAlma))
            {
                return DuplicateResult("El bien seleccionado ya existe en el detalle de la requisicion.");
            }

            try
            {
                await ApplyTipoBienDefaultsAsync(response);
                await ValidatePartidaAndStockAsync(response, null);
                var spResult = await ExecuteDetalleAsync(4, null, response, usuarioActual);
                var id = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return DuplicateResult($"Error al crear detalle de requisicion: {ex.Message}");
            }
        }

        public override async Task<PagedResult<RequisicionDetalleResponse>> UpdateAsync(
            int id,
            RequisicionDetalleResponse response,
            int usuarioActual)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var detalleActual = await _context.RequisicionDetalles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidRequisicionDetalle == id &&
                x.FkidRequisicionOrco == response.FkidRequisicionOrco &&
                x.FkidEmpresaSis == empresaId &&
                x.Activo);
            if (detalleActual == null ||
                await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(
                    _context, _userContext, response.FkidRequisicionOrco) == null)
                return NotFoundResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, response.FkidRequisicionOrco))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para editar bienes.");
            }

            if (ExistsDuplicate(response.FkidRequisicionOrco, response.FkidTipoBienAlma, id))
            {
                return DuplicateResult("Ya existe otro renglon activo con el mismo bien en esta requisicion.");
            }

            try
            {
                await ApplyTipoBienDefaultsAsync(response);
                await ValidatePartidaAndStockAsync(response, id);
                var spResult = await ExecuteDetalleAsync(5, id, response, usuarioActual);
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return DuplicateResult($"Error al actualizar detalle de requisicion: {ex.Message}");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var detalle = await _context.RequisicionDetalles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidRequisicionDetalle == id &&
                x.FkidEmpresaSis == empresaId &&
                x.Activo);
            if (detalle == null ||
                await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(
                    _context, _userContext, detalle.FkidRequisicionOrco) == null)
                return NotFoundDeleteResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, detalle.FkidRequisicionOrco))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La requisicion ya esta vinculada a una cotizacion activa. Liberala para eliminar bienes.",
                    Code = "LOCKED",
                    Data = false,
                    Items = new List<bool> { false },
                    TotalCount = 0
                };
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoRequisicion]",
                    StoredProcedureExecutor.Param("@Action", 6),
                    StoredProcedureExecutor.Param("@PKIdRequisicion", detalle.FkidRequisicionOrco),
                    StoredProcedureExecutor.Param("@PKIdRequisicionDetalle", id),
                    StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));

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
                    Message = $"Error al eliminar detalle de requisicion: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        private Task<StoredProcedureResult> ExecuteDetalleAsync(
            int action,
            int? id,
            RequisicionDetalleResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoRequisicion]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdRequisicion", response.FkidRequisicionOrco),
                StoredProcedureExecutor.Param("@PKIdRequisicionDetalle", id),
                StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", response.FkidTipoBienAlma),
                StoredProcedureExecutor.Param("@FKIdUnidades_ALMA", response.FkidUnidadesAlma),
                StoredProcedureExecutor.Param("@Cantidad", response.Cantidad),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private bool ExistsDuplicate(int requisicionId, int tipoBienId, int? excludeId = null)
        {
            return _service.GetQueryWithIncludes()
                .Any(x =>
                    x.FkidRequisicionOrco == requisicionId &&
                    x.FkidTipoBienAlma == tipoBienId &&
                    (!excludeId.HasValue || x.PkidRequisicionDetalle != excludeId.Value));
        }

        private async Task ApplyTipoBienDefaultsAsync(RequisicionDetalleResponse response)
        {
            if (response.FkidUnidadesAlma is > 0 || response.FkidTipoBienAlma <= 0)
            {
                return;
            }

            response.FkidUnidadesAlma = await _context.TipoBiens
                .AsNoTracking()
                .Where(x => x.PkidTipoBien == response.FkidTipoBienAlma && x.Activo)
                .Select(x => x.FkidUnidadesAlma)
                .FirstOrDefaultAsync();
        }

        private async Task ValidatePartidaAndStockAsync(
            RequisicionDetalleResponse response,
            int? currentDetalleId)
        {
            var tipoBien = await _context.TipoBiens.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidTipoBien == response.FkidTipoBienAlma && x.Activo);
            if (tipoBien == null || !tipoBien.FkidPartidaConta.HasValue)
                throw new ArgumentException("El bien no existe, esta inactivo o no tiene partida presupuestal.");

            var partidaAsignada = await _context.RequisicionPartida.AsNoTracking().AnyAsync(x =>
                x.FkidRequisicionOrco == response.FkidRequisicionOrco &&
                x.FkidPartidaConta == tipoBien.FkidPartidaConta.Value &&
                x.Activo);
            if (!partidaAsignada)
                throw new ArgumentException("El bien no pertenece a una partida activa de la requisicion.");

            var existencia = await _context.VwExistencias.AsNoTracking()
                .Where(x => x.PkidTipoBien == response.FkidTipoBienAlma)
                .Select(x => (decimal?)x.Existencias)
                .FirstOrDefaultAsync();
            if (!existencia.HasValue)
                return;

            var yaCapturado = await _context.RequisicionDetalles.AsNoTracking()
                .Where(x =>
                    x.FkidRequisicionOrco == response.FkidRequisicionOrco &&
                    x.FkidTipoBienAlma == response.FkidTipoBienAlma &&
                    x.Activo &&
                    (!currentDetalleId.HasValue || x.PkidRequisicionDetalle != currentDetalleId.Value))
                .SumAsync(x => (decimal?)x.Cantidad) ?? 0m;
            if (yaCapturado + response.Cantidad > existencia.Value)
                throw new ArgumentException(
                    $"La cantidad solicitada excede la existencia disponible ({existencia.Value:0.##}).");
        }

        private static PagedResult<RequisicionDetalleResponse> NotFoundResult() => new()
        {
            Success = false,
            Message = "El detalle o la requisicion no existe, esta inactiva o no pertenece a la empresa actual.",
            Code = "NOT_FOUND",
            TotalCount = 0
        };

        private static PagedResult<bool> NotFoundDeleteResult() => new()
        {
            Success = false,
            Message = "El detalle no existe, esta inactivo o no pertenece a la empresa actual.",
            Code = "NOT_FOUND",
            Data = false,
            TotalCount = 0
        };

        private static PagedResult<RequisicionDetalleResponse> LockedResult(string message)
        {
            return new PagedResult<RequisicionDetalleResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static PagedResult<RequisicionDetalleResponse> DuplicateResult(string message)
        {
            return new PagedResult<RequisicionDetalleResponse>
            {
                Success = false,
                Message = message,
                Code = "DUPLICATE",
                TotalCount = 0
            };
        }
    }
}

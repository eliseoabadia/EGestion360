using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class OrdenCompraPartidaAppService
        : AdquisicionCrudAppService<OrdenCompraPartidum, VwOrdenCompraPartidum, OrdenCompraPartidaDto, OrdenCompraPartidaResponse>,
            IOrdenCompraPartidaAppService
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public OrdenCompraPartidaAppService(
            GenericService<OrdenCompraPartidum, OrdenCompraPartidaDto, OrdenCompraPartidaResponse> service,
            GenericService<VwOrdenCompraPartidum, OrdenCompraPartidaDto, OrdenCompraPartidaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidOrdenCompraPartida",
                "Partida de orden de compra",
                (dto, id) => dto.PkidOrdenCompraPartida = id)
        {
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<OrdenCompraPartidaResponse>> CreateAsync(
            OrdenCompraPartidaResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, null);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidOrdenCompraPartida = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(response.PkidOrdenCompraPartida);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("crear", userVisibleException);
                    return Failure(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("crear", ex);
                return Failure(
                    UserFacingMessages.OperationFailed("crear partida de orden de compra"),
                    "ERROR");
            }
        }

        public override async Task<PagedResult<OrdenCompraPartidaResponse>> UpdateAsync(
            int id,
            OrdenCompraPartidaResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, id);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("actualizar", userVisibleException);
                    return Failure(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("actualizar", ex);
                return Failure(
                    UserFacingMessages.OperationFailed("actualizar partida de orden de compra"),
                    "ERROR");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var partida = await _context.OrdenCompraPartida
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidOrdenCompraPartida == id && x.Activo);

            if (partida == null)
            {
                return BoolFailure($"Partida de orden de compra con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (!await IsCurrentCompanyOrderAsync(partida.FkidOrdenCompraOrco))
            {
                return BoolFailure("La orden de compra no pertenece a la empresa activa.", "FORBIDDEN");
            }

            if (await IsOrdenLockedAsync(partida.FkidOrdenCompraOrco))
            {
                return BoolFailure("La orden de compra ya fue autorizada. No se pueden eliminar partidas.", "LOCKED");
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoOrdenCompraPartida]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdOrdenCompraPartida", id));

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
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("eliminar", userVisibleException);
                    return BoolFailure(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("eliminar", ex);
                return BoolFailure(
                    UserFacingMessages.OperationFailed("eliminar partida de orden de compra"),
                    "ERROR");
            }
        }

        private async Task<PagedResult<OrdenCompraPartidaResponse>?> NormalizeAndValidateAsync(
            OrdenCompraPartidaResponse response,
            int? currentId)
        {
            if (response.FkidOrdenCompraOrco <= 0)
            {
                return Failure("Debe existir una orden de compra seleccionada.");
            }

            if (await IsOrdenLockedAsync(response.FkidOrdenCompraOrco))
            {
                return Failure("La orden de compra ya fue autorizada. No se pueden modificar partidas.", "LOCKED");
            }

            if (response.FkidPartidaConta <= 0)
            {
                return Failure("Debe seleccionar una partida.");
            }

            if (response.Importe < 0)
            {
                return Failure("El importe de la partida no puede ser negativo.");
            }

            var orden = await _context.OrdenCompras
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidOrdenCompra == response.FkidOrdenCompraOrco && x.Activo);

            if (orden == null)
            {
                return Failure("La orden de compra no existe o esta inactiva.");
            }

            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (empresaId.HasValue && empresaId.Value > 0 && orden.FkidEmpresaSis != empresaId.Value)
            {
                return Failure("La orden de compra no pertenece a la empresa activa.", "FORBIDDEN");
            }

            var partidaPertenece = await _context.RequisicionPartida
                .AsNoTracking()
                .AnyAsync(x =>
                    x.FkidRequisicionOrco == orden.FkidRequisicionOrco &&
                    x.FkidEmpresaSis == orden.FkidEmpresaSis &&
                    x.FkidPartidaConta == response.FkidPartidaConta &&
                    x.Activo);

            if (!partidaPertenece)
            {
                return Failure("La partida seleccionada no pertenece a la requisicion de la orden.");
            }

            var importePartidas = await _context.OrdenCompraPartida
                .Where(x =>
                    x.FkidOrdenCompraOrco == response.FkidOrdenCompraOrco &&
                    x.Activo &&
                    x.PkidOrdenCompraPartida != (currentId ?? 0))
                .SumAsync(x => x.Importe);

            if (orden.Total > 0 && importePartidas + response.Importe > orden.Total)
            {
                return Failure("El importe de las partidas excede el total de la orden de compra.");
            }

            response.Observaciones ??= string.Empty;
            return null;
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            OrdenCompraPartidaResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoOrdenCompraPartida]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdOrdenCompraPartida", id),
                StoredProcedureExecutor.Param("@FKIdOrdenCompra_ORCO", response.FkidOrdenCompraOrco),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response.FkidPartidaConta),
                StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", response.FkidFuenteFinanciamientoPres),
                StoredProcedureExecutor.Param("@Importe", response.Importe),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private async Task<bool> IsOrdenLockedAsync(int ordenCompraId)
        {
            return await _context.OrdenCompras
                .AnyAsync(x => x.PkidOrdenCompra == ordenCompraId && x.Activo && x.FkidEstatusOrdenCompraOrco > 1);
        }

        private async Task<bool> IsCurrentCompanyOrderAsync(int ordenCompraId)
        {
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
            {
                return true;
            }

            return await _context.OrdenCompras
                .AsNoTracking()
                .AnyAsync(x =>
                    x.PkidOrdenCompra == ordenCompraId &&
                    x.Activo &&
                    x.FkidEmpresaSis == empresaId.Value);
        }

        private static PagedResult<OrdenCompraPartidaResponse> Failure(string message, string code = "ERROR")
        {
            return new PagedResult<OrdenCompraPartidaResponse>
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

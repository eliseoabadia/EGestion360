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
    public class RequisicionPartidaAppService
        : AdquisicionCrudAppService<RequisicionPartidum, VwRequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse>,
            IRequisicionPartidaAppService
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public RequisicionPartidaAppService(
            GenericService<RequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse> service,
            GenericService<VwRequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidRequisicionPartida",
                "Partida de requisicion",
                (dto, id) => dto.PkidRequisicionPartida = id)
        {
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<RequisicionPartidaResponse>> CreateAsync(
            RequisicionPartidaResponse response,
            int usuarioActual)
        {
            var requisicion = await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(
                _context, _userContext, response.FkidRequisicionOrco);
            if (requisicion == null)
                return NotFoundResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, requisicion.PkidRequisicion))
                return LockedResult("La requisicion ya avanzo a cotizacion o suficiencia y sus partidas no pueden modificarse.");

            response.FkidEmpresaSis = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var validation = await ValidateAsync(response, requisicion, null);
            if (validation != null)
                return validation;

            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<RequisicionPartidaResponse>> UpdateAsync(
            int id,
            RequisicionPartidaResponse response,
            int usuarioActual)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var existing = await _context.RequisicionPartida.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidRequisicionPartida == id &&
                x.FkidRequisicionOrco == response.FkidRequisicionOrco &&
                x.FkidEmpresaSis == empresaId &&
                x.Activo);
            if (existing == null)
                return NotFoundResult();

            var requisicion = await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(
                _context, _userContext, existing.FkidRequisicionOrco);
            if (requisicion == null)
                return NotFoundResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, requisicion.PkidRequisicion))
                return LockedResult("La requisicion ya avanzo a cotizacion o suficiencia y sus partidas no pueden modificarse.");

            response.FkidEmpresaSis = empresaId;
            var validation = await ValidateAsync(response, requisicion, id);
            if (validation != null)
                return validation;

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var partida = await _context.RequisicionPartida.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidRequisicionPartida == id &&
                x.FkidEmpresaSis == empresaId &&
                x.Activo);
            if (partida == null)
                return NotFoundDeleteResult();

            if (await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(
                    _context, _userContext, partida.FkidRequisicionOrco) == null)
                return NotFoundDeleteResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, partida.FkidRequisicionOrco))
                return LockedDeleteResult();

            return await base.DeleteAsync(id);
        }

        private async Task<PagedResult<RequisicionPartidaResponse>?> ValidateAsync(
            RequisicionPartidaResponse response,
            Requisicion requisicion,
            int? currentId)
        {
            if (!response.Monto.HasValue || response.Monto.Value <= 0)
                return ValidationResult("El monto de la partida debe ser mayor a cero.");
            if (!response.FkidEgresoAutorizadoPres.HasValue)
                return ValidationResult("Debe seleccionar una posicion presupuestal disponible para la partida.");

            var posicion = await _context.VwEgresoDisponibles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidEgresoAutorizado == response.FkidEgresoAutorizadoPres.Value &&
                x.FkidAnioSis == requisicion.FkidAnioSis &&
                x.FkidAreaSis == requisicion.FkidAreaSis);
            if (posicion == null)
                return ValidationResult("La posicion presupuestal no corresponde al anio y area de la requisicion.");
            if (posicion.Total.GetValueOrDefault() <= 0 || response.Monto.Value > posicion.Total.GetValueOrDefault())
                return ValidationResult("El monto excede el presupuesto disponible de la posicion seleccionada.");
            if (posicion.FkidPartidaConta != response.FkidPartidaConta)
                return ValidationResult("La partida no corresponde a la posicion presupuestal seleccionada.");
            if (posicion.FkidProgramaPres != requisicion.FkidProgramaPres ||
                posicion.FkidFuenteFinanciamientoPres != requisicion.FkidFuenteFinanciamientoPres ||
                posicion.FkidTipoGastoPres != requisicion.FkidTipoGastoPres ||
                posicion.FkidDigitoIdentificadorPres != requisicion.FkidDigitoIdentificadorPres ||
                posicion.FkidDestinoGastoPres != requisicion.FkidDestinoGastoPres ||
                posicion.FkidPyPres != requisicion.FkidProyectoOrco)
                return ValidationResult("La posicion no pertenece a la clasificacion presupuestal de la requisicion.");

            var duplicate = await _context.RequisicionPartida.AsNoTracking().AnyAsync(x =>
                x.Activo &&
                x.FkidRequisicionOrco == requisicion.PkidRequisicion &&
                x.FkidPartidaConta == response.FkidPartidaConta &&
                (!currentId.HasValue || x.PkidRequisicionPartida != currentId.Value));
            if (duplicate)
                return ValidationResult("La partida ya se encuentra registrada en la requisicion.");

            var assigned = await _context.RequisicionPartida.AsNoTracking()
                .Where(x =>
                    x.Activo &&
                    x.FkidRequisicionOrco == requisicion.PkidRequisicion &&
                    (!currentId.HasValue || x.PkidRequisicionPartida != currentId.Value))
                .SumAsync(x => x.Monto ?? 0m);
            if (assigned + response.Monto.Value > requisicion.Importe.GetValueOrDefault())
                return ValidationResult("La suma de partidas no puede exceder el importe de la requisicion.");

            return null;
        }

        private static PagedResult<RequisicionPartidaResponse> ValidationResult(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "VALIDATION",
            TotalCount = 0
        };

        private static PagedResult<RequisicionPartidaResponse> NotFoundResult() => new()
        {
            Success = false,
            Message = "La partida o su requisicion no existe, esta inactiva o no pertenece a la empresa actual.",
            Code = "NOT_FOUND",
            TotalCount = 0
        };

        private static PagedResult<bool> NotFoundDeleteResult() => new()
        {
            Success = false,
            Message = "La partida o su requisicion no existe, esta inactiva o no pertenece a la empresa actual.",
            Code = "NOT_FOUND",
            Data = false,
            TotalCount = 0
        };

        private static PagedResult<RequisicionPartidaResponse> LockedResult(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "LOCKED",
            TotalCount = 0
        };

        private static PagedResult<bool> LockedDeleteResult() => new()
        {
            Success = false,
            Message = "La requisicion ya avanzo a cotizacion o suficiencia y sus partidas no pueden eliminarse.",
            Code = "LOCKED",
            Data = false,
            TotalCount = 0
        };
    }
}

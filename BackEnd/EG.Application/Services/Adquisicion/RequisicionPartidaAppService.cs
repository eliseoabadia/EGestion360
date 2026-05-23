using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class RequisicionPartidaAppService
        : AdquisicionCrudAppService<RequisicionPartidum, VwRequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse>,
            IRequisicionPartidaAppService
    {
        private readonly GenericService<Cotizacion, CotizacionDto, CotizacionResponse> _cotizacionService;

        public RequisicionPartidaAppService(
            GenericService<RequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse> service,
            GenericService<VwRequisicionPartidum, RequisicionPartidaDto, RequisicionPartidaResponse> serviceView,
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> cotizacionService)
            : base(
                service,
                serviceView,
                "PkidRequisicionPartida",
                "Partida de requisicion",
                (dto, id) => dto.PkidRequisicionPartida = id)
        {
            _cotizacionService = cotizacionService;
        }

        public override async Task<PagedResult<RequisicionPartidaResponse>> CreateAsync(
            RequisicionPartidaResponse response,
            int usuarioActual)
        {
            if (IsRequisicionLocked(response.FkidRequisicionOrco))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para agregar partidas.");
            }

            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<RequisicionPartidaResponse>> UpdateAsync(
            int id,
            RequisicionPartidaResponse response,
            int usuarioActual)
        {
            if (IsRequisicionLocked(response.FkidRequisicionOrco))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para editar partidas.");
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var partida = _service.GetQueryWithIncludes()
                .FirstOrDefault(x => x.PkidRequisicionPartida == id);

            if (partida != null && IsRequisicionLocked(partida.FkidRequisicionOrco))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La requisicion ya esta vinculada a una cotizacion activa. Liberala para eliminar partidas.",
                    Code = "LOCKED",
                    Data = false,
                    Items = new List<bool> { false },
                    TotalCount = 0
                };
            }

            return await base.DeleteAsync(id);
        }

        private bool IsRequisicionLocked(int requisicionId)
        {
            return _cotizacionService.GetQueryWithIncludes()
                .Any(x => x.FkidRequisicionOrco == requisicionId);
        }

        private static PagedResult<RequisicionPartidaResponse> LockedResult(string message)
        {
            return new PagedResult<RequisicionPartidaResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }
    }
}

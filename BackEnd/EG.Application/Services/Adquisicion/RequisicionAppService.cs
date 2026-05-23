using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class RequisicionAppService
        : AdquisicionCrudAppService<Requisicion, VwRequisicion, RequisicionDto, RequisicionResponse>,
            IRequisicionAppService
    {
        private readonly GenericService<Cotizacion, CotizacionDto, CotizacionResponse> _cotizacionService;

        public RequisicionAppService(
            GenericService<Requisicion, RequisicionDto, RequisicionResponse> service,
            GenericService<VwRequisicion, RequisicionDto, RequisicionResponse> serviceView,
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> cotizacionService)
            : base(
                service,
                serviceView,
                "PkidRequisicion",
                "Requisicion",
                (dto, id) => dto.PkidRequisicion = id)
        {
            _cotizacionService = cotizacionService;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            ApplyCotizacionLocks(result.Items);
            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success)
            {
                ApplyCotizacionLocks(result.Items);
                if (result.Data != null)
                {
                    result.Data.CotizacionesActivas = CountActiveCotizaciones(id);
                }
            }

            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            ApplyCotizacionLocks(result.Items);
            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> UpdateAsync(
            int id,
            RequisicionResponse response,
            int usuarioActual)
        {
            if (IsLocked(id))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder editarla.");
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            if (IsLocked(id))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder eliminarla.",
                    Code = "LOCKED",
                    Data = false,
                    Items = new List<bool> { false },
                    TotalCount = 0
                };
            }

            return await base.DeleteAsync(id);
        }

        private bool IsLocked(int requisicionId) => CountActiveCotizaciones(requisicionId) > 0;

        private int CountActiveCotizaciones(int requisicionId)
        {
            return _cotizacionService.GetQueryWithIncludes()
                .Count(x => x.FkidRequisicionOrco == requisicionId);
        }

        private void ApplyCotizacionLocks(IList<RequisicionResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var requisicionIds = items.Select(x => x.PkidRequisicion).Distinct().ToList();
            var counts = _cotizacionService.GetQueryWithIncludes()
                .Where(x => requisicionIds.Contains(x.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionOrco)
                .ToDictionary(x => x.Key, x => x.Count());

            foreach (var item in items)
            {
                item.CotizacionesActivas = counts.TryGetValue(item.PkidRequisicion, out var count) ? count : 0;
            }
        }

        private static PagedResult<RequisicionResponse> LockedResult(string message)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }
    }
}

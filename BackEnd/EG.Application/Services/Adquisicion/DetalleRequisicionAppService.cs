using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class DetalleRequisicionAppService
        : AdquisicionCrudAppService<DetalleRequisicion, VwDetalleRequisicion, DetalleRequisicionDto, DetalleRequisicionResponse>,
            IDetalleRequisicionAppService
    {
        private readonly GenericService<Cotizacion, CotizacionDto, CotizacionResponse> _cotizacionService;

        public DetalleRequisicionAppService(
            GenericService<DetalleRequisicion, DetalleRequisicionDto, DetalleRequisicionResponse> service,
            GenericService<VwDetalleRequisicion, DetalleRequisicionDto, DetalleRequisicionResponse> serviceView,
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> cotizacionService)
            : base(
                service,
                serviceView,
                "PkidDetalleRequisicion",
                "Detalle de requisicion",
                (dto, id) => dto.PkidDetalleRequisicion = id)
        {
            _cotizacionService = cotizacionService;
        }

        public override async Task<PagedResult<DetalleRequisicionResponse>> CreateAsync(
            DetalleRequisicionResponse response,
            int usuarioActual)
        {
            if (IsRequisicionLocked(response.FkidRequisicionOrco))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para agregar bienes.");
            }

            if (ExistsDuplicate(response.FkidRequisicionOrco, response.FkidTipoBienAlma))
            {
                return DuplicateResult("El bien seleccionado ya existe en el detalle de la requisicion.");
            }

            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<DetalleRequisicionResponse>> UpdateAsync(
            int id,
            DetalleRequisicionResponse response,
            int usuarioActual)
        {
            if (IsRequisicionLocked(response.FkidRequisicionOrco))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para editar bienes.");
            }

            if (ExistsDuplicate(response.FkidRequisicionOrco, response.FkidTipoBienAlma, id))
            {
                return DuplicateResult("Ya existe otro renglon activo con el mismo bien en esta requisicion.");
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var detalle = _service.GetQueryWithIncludes()
                .FirstOrDefault(x => x.PkidDetalleRequisicion == id);

            if (detalle != null && IsRequisicionLocked(detalle.FkidRequisicionOrco))
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

            return await base.DeleteAsync(id);
        }

        private bool ExistsDuplicate(int requisicionId, int tipoBienId, int? excludeId = null)
        {
            return _service.GetQueryWithIncludes()
                .Any(x =>
                    x.FkidRequisicionOrco == requisicionId &&
                    x.FkidTipoBienAlma == tipoBienId &&
                    (!excludeId.HasValue || x.PkidDetalleRequisicion != excludeId.Value));
        }

        private bool IsRequisicionLocked(int requisicionId)
        {
            return _cotizacionService.GetQueryWithIncludes()
                .Any(x => x.FkidRequisicionOrco == requisicionId);
        }

        private static PagedResult<DetalleRequisicionResponse> LockedResult(string message)
        {
            return new PagedResult<DetalleRequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static PagedResult<DetalleRequisicionResponse> DuplicateResult(string message)
        {
            return new PagedResult<DetalleRequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "DUPLICATE",
                TotalCount = 0
            };
        }
    }
}

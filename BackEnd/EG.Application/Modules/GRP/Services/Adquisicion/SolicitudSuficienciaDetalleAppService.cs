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
    public class SolicitudSuficienciaDetalleAppService
        : AdquisicionCrudAppService<SolicitudSuficienciaDetalle, VwSolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalleResponse>,
            ISolicitudSuficienciaDetalleAppService
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public SolicitudSuficienciaDetalleAppService(
            GenericService<SolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalleResponse> service,
            GenericService<VwSolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalleResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidSolicitudSuficienciaDetalle",
                "Detalle de solicitud de suficiencia",
                (dto, id) => dto.PkidSolicitudSuficienciaDetalle = id)
        {
            _context = context;
            _userContext = userContext;
        }

        public override Task<PagedResult<SolicitudSuficienciaDetalleResponse>> CreateAsync(
            SolicitudSuficienciaDetalleResponse response,
            int usuarioActual) =>
            Task.FromResult(Failure<SolicitudSuficienciaDetalleResponse>(
                "Los detalles se generan desde la requisicion; no pueden agregarse manualmente.", "LOCKED"));

        public override Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            request.AdditionalFilters["FkidEmpresaSis"] = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            return base.GetAllPaginadoAsync(request);
        }

        public override async Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success && result.Data?.FkidEmpresaSis != RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext))
                return Failure<SolicitudSuficienciaDetalleResponse>("Detalle de suficiencia no encontrado.", "NOT_FOUND");
            return result;
        }

        public override async Task<PagedResult<SolicitudSuficienciaDetalleResponse>> UpdateAsync(
            int id,
            SolicitudSuficienciaDetalleResponse response,
            int usuarioActual)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var existing = await _context.SolicitudSuficienciaDetalles.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidSolicitudSuficienciaDetalle == id && x.FkidEmpresaSis == empresaId && x.Activo);
            if (existing == null)
                return Failure<SolicitudSuficienciaDetalleResponse>("Detalle de suficiencia no encontrado.", "NOT_FOUND");

            var header = await _context.SolicitudSuficiencia.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidSolicitudSuficiencia == existing.FkidSolicitudSuficienciaPres && x.Activo);
            if (header == null || header.Estatus != 1)
                return Failure<SolicitudSuficienciaDetalleResponse>("Solo se pueden modificar detalles de solicitudes en borrador.", "LOCKED");

            response.FkidEmpresaSis = existing.FkidEmpresaSis;
            response.FkidSolicitudSuficienciaPres = existing.FkidSolicitudSuficienciaPres;
            response.FkidRequisicionDetalleOrco = existing.FkidRequisicionDetalleOrco;
            response.FkidPartidaConta = existing.FkidPartidaConta;

            var importes = new[] { response.Enero, response.Febrero, response.Marzo, response.Abril, response.Mayo, response.Junio,
                response.Julio, response.Agosto, response.Septiembre, response.Octubre, response.Noviembre, response.Diciembre }
                .Select(x => x.GetValueOrDefault()).ToArray();
            if (importes.Any(x => x < 0m) || importes.Sum() <= 0m)
                return Failure<SolicitudSuficienciaDetalleResponse>("Debe capturar un importe mayor a cero y sin valores negativos.");
            if (importes.Take(header.FechaSolicitud.Month - 1).Any(x => x != 0m))
                return Failure<SolicitudSuficienciaDetalleResponse>("Los meses anteriores a la fecha de solicitud no deben tener importe.");

            response.Total = importes.Sum();
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var detail = await _context.SolicitudSuficienciaDetalles.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidSolicitudSuficienciaDetalle == id && x.FkidEmpresaSis == empresaId && x.Activo);
            if (detail == null)
                return Failure<bool>("Detalle de suficiencia no encontrado.", "NOT_FOUND");
            var isDraft = await _context.SolicitudSuficiencia.AsNoTracking().AnyAsync(x =>
                x.PkidSolicitudSuficiencia == detail.FkidSolicitudSuficienciaPres && x.Activo && x.Estatus == 1);
            if (!isDraft)
                return Failure<bool>("Solo se pueden eliminar detalles de solicitudes en borrador.", "LOCKED");
            return await base.DeleteAsync(id);
        }
    }
}

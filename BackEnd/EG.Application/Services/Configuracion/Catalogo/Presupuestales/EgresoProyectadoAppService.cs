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
    }
}

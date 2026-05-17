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
    public class EgresoAutorizadoAppService
        : AdquisicionCrudAppService<EgresoAutorizado, VwEgresoAutorizado, EgresoAutorizadoDto, EgresoAutorizadoResponse>,
            IEgresoAutorizadoAppService
    {
        private readonly EGestionContext _context;

        public EgresoAutorizadoAppService(
            GenericService<EgresoAutorizado, EgresoAutorizadoDto, EgresoAutorizadoResponse> service,
            GenericService<VwEgresoAutorizado, EgresoAutorizadoDto, EgresoAutorizadoResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidEgresoAutorizado",
                "Presupuesto autorizado",
                (dto, id) => dto.PkidEgresoAutorizado = id)
        {
            _context = context;
        }

        public override Task<PagedResult<EgresoAutorizadoResponse>> CreateAsync(EgresoAutorizadoResponse response, int usuarioActual)
        {
            if (response.FkidEgresoProyectadoPres.HasValue && response.FkidEgresoProyectadoPres.Value > 0)
            {
                return AutorizarProyectadoAsync(
                    response.FkidEgresoProyectadoPres.Value,
                    usuarioActual,
                    response.FkidPolizaConta,
                    response.Descripcion);
            }

            response.FechaAutorizacion ??= DateTime.Now;
            response.UsuarioAutorizacion ??= usuarioActual;

            return base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<EgresoAutorizadoResponse>> UpdateAsync(
            int id,
            EgresoAutorizadoResponse response,
            int usuarioActual)
        {
            var existing = await _context.EgresoAutorizados
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidEgresoAutorizado == id && x.Activo);

            if (existing == null)
            {
                return await base.UpdateAsync(id, response, usuarioActual);
            }

            if (!existing.FkidEgresoProyectadoPres.HasValue && response.FkidEgresoProyectadoPres.HasValue)
            {
                return Locked("Para autorizar un egreso proyectado usa la accion de autorizar desde egreso proyectado.");
            }

            PreserveAmounts(response, existing);

            if (existing.FkidEgresoProyectadoPres.HasValue)
            {
                response.FkidEgresoProyectadoPres = existing.FkidEgresoProyectadoPres;
                response.FkidProgramaPres = existing.FkidProgramaPres;
                response.FkidPartidaConta = existing.FkidPartidaConta;
                response.FkidAreaSis = existing.FkidAreaSis;
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var isLinkedToProyectado = await _context.EgresoAutorizados
                .AsNoTracking()
                .AnyAsync(x => x.PkidEgresoAutorizado == id && x.Activo && x.FkidEgresoProyectadoPres.HasValue);

            var result = await base.DeleteAsync(id);
            if (result.Success && isLinkedToProyectado)
            {
                result.Message = "Egreso proyectado desautorizado correctamente.";
            }

            return result;
        }

        public async Task<PagedResult<EgresoAutorizadoResponse>> AutorizarProyectadoAsync(
            int pkidEgresoProyectado,
            int usuarioActual,
            int? fkidPolizaConta,
            string? descripcion)
        {
            try
            {
                var result = await _context.Procedures.spAutorizarEgresoProyectadoAsync(
                    pkidEgresoProyectado,
                    usuarioActual,
                    fkidPolizaConta,
                    descripcion ?? string.Empty);

                var autorizadoId = result.FirstOrDefault()?.PKIdEgresoAutorizado ?? 0;
                if (autorizadoId <= 0)
                {
                    return new PagedResult<EgresoAutorizadoResponse>
                    {
                        Success = false,
                        Message = "No se pudo autorizar el anteproyecto.",
                        Code = "ERROR",
                        TotalCount = 0
                    };
                }

                return await GetByIdAsync(autorizadoId);
            }
            catch (Exception ex)
            {
                return new PagedResult<EgresoAutorizadoResponse>
                {
                    Success = false,
                    Message = $"Error al autorizar el anteproyecto: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        private static PagedResult<EgresoAutorizadoResponse> Locked(string message)
        {
            return new PagedResult<EgresoAutorizadoResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static void PreserveAmounts(EgresoAutorizadoResponse response, EgresoAutorizado existing)
        {
            response.Enero = existing.Enero;
            response.Febrero = existing.Febrero;
            response.Marzo = existing.Marzo;
            response.Abril = existing.Abril;
            response.Mayo = existing.Mayo;
            response.Junio = existing.Junio;
            response.Julio = existing.Julio;
            response.Agosto = existing.Agosto;
            response.Septiembre = existing.Septiembre;
            response.Octubre = existing.Octubre;
            response.Noviembre = existing.Noviembre;
            response.Diciembre = existing.Diciembre;
            response.Total = existing.Total;
        }
    }
}

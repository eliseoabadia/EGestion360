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
                return CrearAutorizacionCapturadaAsync(response, usuarioActual);
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
                response.FkidFuenteFinanciamientoPres = existing.FkidFuenteFinanciamientoPres;
                response.FkidTipoGastoPres = existing.FkidTipoGastoPres;
                response.FkidDigitoIdentificadorPres = existing.FkidDigitoIdentificadorPres;
                response.FkidDestinoGastoPres = existing.FkidDestinoGastoPres;
                response.FkidPyPres = existing.FkidPyPres;
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var isLinkedToProyectado = await _context.EgresoAutorizados
                .AsNoTracking()
                .AnyAsync(x => x.PkidEgresoAutorizado == id && x.Activo && x.FkidEgresoProyectadoPres.HasValue);

            if (isLinkedToProyectado)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "Para regresar un presupuesto autorizado a proyectado usa el proceso de regresar a proyectado.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            var result = await base.DeleteAsync(id);

            return result;
        }

        public async Task<PagedResult<bool>> RegresarAProyectadoAsync(int pkidEgresoAutorizado, int usuarioActual)
        {
            try
            {
                var autorizado = await _context.EgresoAutorizados
                    .FirstOrDefaultAsync(x => x.PkidEgresoAutorizado == pkidEgresoAutorizado && x.Activo);

                if (autorizado == null)
                {
                    return BoolFailure($"Presupuesto autorizado con ID {pkidEgresoAutorizado} no encontrado.", "NOT_FOUND");
                }

                if (!autorizado.FkidEgresoProyectadoPres.HasValue)
                {
                    return BoolFailure("El presupuesto autorizado no proviene de un egreso proyectado.", "INVALID_OPERATION");
                }

                var proyectadoActivo = await _context.EgresoProyectados
                    .AsNoTracking()
                    .AnyAsync(x => x.PkidEgresoProyectado == autorizado.FkidEgresoProyectadoPres.Value && x.Activo);

                if (!proyectadoActivo)
                {
                    return BoolFailure("El egreso proyectado origen no existe o no esta activo.", "NOT_FOUND");
                }

                autorizado.Activo = false;
                autorizado.UsuarioModificacion = usuarioActual;
                autorizado.FechaModificacion = DateTime.Now;

                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Presupuesto autorizado regresado a proyectado correctamente.",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return BoolFailure($"Error al regresar el presupuesto autorizado a proyectado: {ex.Message}", "ERROR");
            }
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

        private async Task<PagedResult<EgresoAutorizadoResponse>> CrearAutorizacionCapturadaAsync(
            EgresoAutorizadoResponse response,
            int usuarioActual)
        {
            try
            {
                var pkidEgresoProyectado = response.FkidEgresoProyectadoPres!.Value;
                var proyectado = await _context.EgresoProyectados
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidEgresoProyectado == pkidEgresoProyectado && x.Activo);

                if (proyectado == null)
                {
                    return Failure("El egreso proyectado no existe o no esta activo.", "NOT_FOUND");
                }

                var existingId = await _context.EgresoAutorizados
                    .AsNoTracking()
                    .Where(x => x.FkidEgresoProyectadoPres == pkidEgresoProyectado && x.Activo)
                    .Select(x => (int?)x.PkidEgresoAutorizado)
                    .FirstOrDefaultAsync();

                if (existingId.HasValue)
                {
                    return await GetByIdAsync(existingId.Value);
                }

                var now = DateTime.Now;
                var autorizado = new EgresoAutorizado
                {
                    FkidEgresoProyectadoPres = pkidEgresoProyectado,
                    FkidProgramaPres = proyectado.FkidProgramaPres,
                    FkidPartidaConta = proyectado.FkidPartidaConta,
                    FkidAreaSis = proyectado.FkidAreaSis,
                    FkidFuenteFinanciamientoPres = proyectado.FkidFuenteFinanciamientoPres,
                    FkidTipoGastoPres = proyectado.FkidTipoGastoPres,
                    FkidDigitoIdentificadorPres = proyectado.FkidDigitoIdentificadorPres,
                    FkidDestinoGastoPres = proyectado.FkidDestinoGastoPres,
                    FkidPyPres = proyectado.FkidPyPres,
                    Descripcion = proyectado.Descripcion,
                    Fecha = proyectado.Fecha,
                    FkidPolizaConta = response.FkidPolizaConta,
                    Enero = proyectado.Enero,
                    Febrero = proyectado.Febrero,
                    Marzo = proyectado.Marzo,
                    Abril = proyectado.Abril,
                    Mayo = proyectado.Mayo,
                    Junio = proyectado.Junio,
                    Julio = proyectado.Julio,
                    Agosto = proyectado.Agosto,
                    Septiembre = proyectado.Septiembre,
                    Octubre = proyectado.Octubre,
                    Noviembre = proyectado.Noviembre,
                    Diciembre = proyectado.Diciembre,
                    Total = proyectado.Total,
                    FechaAutorizacion = now,
                    UsuarioAutorizacion = usuarioActual,
                    Activo = true,
                    FechaCreacion = now,
                    UsuarioCreacion = usuarioActual
                };

                _context.EgresoAutorizados.Add(autorizado);
                await _context.SaveChangesAsync();

                return await GetByIdAsync(autorizado.PkidEgresoAutorizado);
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

        private static PagedResult<EgresoAutorizadoResponse> Failure(string message, string code)
        {
            return new PagedResult<EgresoAutorizadoResponse>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }

        private static PagedResult<bool> BoolFailure(string message, string code)
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

using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Data;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class EgresoAutorizadoAppService
        : StoredProcedureCrudAppService<EgresoAutorizado, VwEgresoAutorizado, EgresoAutorizadoDto, EgresoAutorizadoResponse>,
            IEgresoAutorizadoAppService
    {
        private const string StoredProcedure = "PRES.SP_MantenimientoEgresoAutorizado";
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;
        private readonly ILogger<EgresoAutorizadoAppService> _logger;

        public EgresoAutorizadoAppService(
            GenericService<EgresoAutorizado, EgresoAutorizadoDto, EgresoAutorizadoResponse> service,
            GenericService<VwEgresoAutorizado, EgresoAutorizadoDto, EgresoAutorizadoResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext,
            ILogger<EgresoAutorizadoAppService> logger)
            : base(
                service,
                serviceView,
                context,
                "PkidEgresoAutorizado",
                "Presupuesto autorizado",
                (dto, id) => dto.PkidEgresoAutorizado = id,
                StoredProcedure,
                response => response.PkidEgresoAutorizado,
                BuildParameters)
        {
            _context = context;
            _userContext = userContext;
            _logger = logger;
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

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    StoredProcedure,
                    BuildParameters(3, id, null, _userContext.GetCurrentUserId()));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = string.IsNullOrWhiteSpace(spResult.Mensaje)
                        ? "Presupuesto autorizado eliminado correctamente."
                        : spResult.Mensaje,
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
                    Message = ex.Message,
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
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

                await NotifyPresupuestoAutorizadoAsync(autorizadoId, pkidEgresoProyectado, usuarioActual);

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

                await NotifyPresupuestoAutorizadoAsync(
                    autorizado.PkidEgresoAutorizado,
                    autorizado.FkidEgresoProyectadoPres,
                    usuarioActual);

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

        private async Task NotifyPresupuestoAutorizadoAsync(
            int pkidEgresoAutorizado,
            int? pkidEgresoProyectado,
            int usuarioActual)
        {
            try
            {
                var idNotification = new SqlParameter("@IdNotificacion", SqlDbType.BigInt)
                {
                    Direction = ParameterDirection.Output
                };

                var titulo = $"Presupuesto autorizado {pkidEgresoAutorizado}";
                var mensaje = pkidEgresoProyectado.HasValue
                    ? $"Se autorizo el anteproyecto {pkidEgresoProyectado.Value} como presupuesto autorizado."
                    : "Se creo un presupuesto autorizado.";
                var jsonData = pkidEgresoProyectado.HasValue
                    ? $"{{\"id\":{pkidEgresoAutorizado},\"egresoProyectadoId\":{pkidEgresoProyectado.Value}}}"
                    : $"{{\"id\":{pkidEgresoAutorizado}}}";

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC SIS.sp_NotificacionCrearPorPermiso @ClaveTipo, @Fk_IdUsuarioOrigen, @Modulo, @SubModulo, @Accion, @Evento, @Entidad, @Fk_IdEntidad, @Titulo, @Mensaje, @Url, @JsonData, @IdUser, @IdNotificacion OUTPUT",
                    new SqlParameter("@ClaveTipo", "AUTORIZACION_REALIZADA"),
                    new SqlParameter("@Fk_IdUsuarioOrigen", usuarioActual),
                    new SqlParameter("@Modulo", "Egreso"),
                    new SqlParameter("@SubModulo", "Presupuesto_Autorizado"),
                    new SqlParameter("@Accion", "view"),
                    new SqlParameter("@Evento", "Autorizado"),
                    new SqlParameter("@Entidad", "EgresoAutorizado"),
                    new SqlParameter("@Fk_IdEntidad", pkidEgresoAutorizado),
                    new SqlParameter("@Titulo", titulo),
                    new SqlParameter("@Mensaje", mensaje),
                    new SqlParameter("@Url", "/Presupuesto/Egreso/Presupuesto_Autorizado"),
                    new SqlParameter("@JsonData", jsonData),
                    new SqlParameter("@IdUser", usuarioActual),
                    idNotification);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(
                    ex,
                    "No se pudo crear la notificacion de presupuesto autorizado {PkidEgresoAutorizado}.",
                    pkidEgresoAutorizado);
            }
        }

        private static SqlParameter[] BuildParameters(int action, int? id, EgresoAutorizadoResponse? response, int? usuarioActual)
        {
            return new[]
            {
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdEgresoAutorizado", id ?? response?.PkidEgresoAutorizado),
                StoredProcedureExecutor.Param("@FKIdPrograma_PRES", response?.FkidProgramaPres),
                StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", response?.FkidFuenteFinanciamientoPres),
                StoredProcedureExecutor.Param("@FKIdTipoGasto_PRES", response?.FkidTipoGastoPres),
                StoredProcedureExecutor.Param("@FKIdDigitoIdentificador_PRES", response?.FkidDigitoIdentificadorPres),
                StoredProcedureExecutor.Param("@FKIdDestinoGasto_PRES", response?.FkidDestinoGastoPres),
                StoredProcedureExecutor.Param("@FKIdPY_PRES", response?.FkidPyPres),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response?.FkidPartidaConta),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response?.FkidAreaSis),
                StoredProcedureExecutor.Param("@Descripcion", response?.Descripcion),
                StoredProcedureExecutor.Param("@Fecha", response?.Fecha == default ? null : response?.Fecha.ToDateTime(TimeOnly.MinValue)),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response?.FkidPolizaConta),
                StoredProcedureExecutor.Param("@Enero", response?.Enero),
                StoredProcedureExecutor.Param("@Febrero", response?.Febrero),
                StoredProcedureExecutor.Param("@Marzo", response?.Marzo),
                StoredProcedureExecutor.Param("@Abril", response?.Abril),
                StoredProcedureExecutor.Param("@Mayo", response?.Mayo),
                StoredProcedureExecutor.Param("@Junio", response?.Junio),
                StoredProcedureExecutor.Param("@Julio", response?.Julio),
                StoredProcedureExecutor.Param("@Agosto", response?.Agosto),
                StoredProcedureExecutor.Param("@Septiembre", response?.Septiembre),
                StoredProcedureExecutor.Param("@Octubre", response?.Octubre),
                StoredProcedureExecutor.Param("@Noviembre", response?.Noviembre),
                StoredProcedureExecutor.Param("@Diciembre", response?.Diciembre),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                StoredProcedureExecutor.Param("@FKIdEgresoProyectado_PRES", response?.FkidEgresoProyectadoPres)
            };
        }
    }
}

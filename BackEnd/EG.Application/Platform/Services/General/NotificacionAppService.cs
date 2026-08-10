using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.General
{
    public class NotificacionAppService : INotificacionAppService
    {
        private readonly EGestionContext _context;
        private readonly ILogger<NotificacionAppService> _logger;

        public NotificacionAppService(EGestionContext context, ILogger<NotificacionAppService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<PagedResult<NotificacionResumenResponse>> GetResumenAsync(int usuarioId)
        {
            try
            {
                var data = new NotificacionResumenResponse
                {
                    Total = await QueryUsuario(usuarioId).CountAsync(),
                    Pendientes = await QueryUsuario(usuarioId).CountAsync(x => x.FkIdNotificacionEstado == 1),
                    Leidas = await QueryUsuario(usuarioId).CountAsync(x => x.FkIdNotificacionEstado == 2),
                    Atendidas = await QueryUsuario(usuarioId).CountAsync(x => x.FkIdNotificacionEstado == 3),
                    RequierenAccion = await QueryUsuario(usuarioId)
                        .CountAsync(x => x.FkIdNotificacionEstado == 1 && x.Url != null && x.Url != string.Empty)
                };

                return Success(data, "Resumen de notificaciones");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen de notificaciones para usuario {UsuarioId}", usuarioId);
                return Error<NotificacionResumenResponse>(ex.Message);
            }
        }

        public async Task<PagedResult<NotificacionUsuarioResponse>> GetMisNotificacionesAsync(int usuarioId, int take = 30, bool soloPendientes = false)
        {
            try
            {
                take = Math.Clamp(take, 1, 100);
                var query = QueryUsuario(usuarioId);

                if (soloPendientes)
                {
                    query = query.Where(x => x.FkIdNotificacionEstado == 1);
                }

                var rows = await query
                    .OrderBy(x => x.FkIdNotificacionEstado == 1 ? 0 : 1)
                    .ThenByDescending(x => x.FechaNotificacion)
                    .Take(take)
                    .ToListAsync();

                var usuarios = await LoadUserNamesAsync(rows
                    .SelectMany(x => new int?[] { x.FkIdUsuarioOrigen, x.FkIdUsuarioDestino }));
                var items = rows.Select(x => Map(x, usuarioId, usuarios)).ToList();

                return new PagedResult<NotificacionUsuarioResponse>
                {
                    Success = true,
                    Message = "Notificaciones obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener notificaciones para usuario {UsuarioId}", usuarioId);
                return Error<NotificacionUsuarioResponse>(ex.Message);
            }
        }

        public async Task<PagedResult<NotificacionUsuarioResponse>> GetConversacionAsync(long notificacionDestinoId, int usuarioId)
        {
            try
            {
                var origen = await QueryUsuario(usuarioId)
                    .FirstOrDefaultAsync(x => x.PkIdNotificacionDestino == notificacionDestinoId);

                if (origen == null)
                {
                    return Error<NotificacionUsuarioResponse>("La notificacion no existe o no pertenece al usuario actual.");
                }

                var notifications = await BuildConversationQuery(origen)
                    .Include(x => x.FkIdNotificacionTipoNavigation)
                    .Include(x => x.NotificacionDestinos)
                    .Where(x =>
                        x.FkIdUsuarioOrigen == usuarioId ||
                        x.NotificacionDestinos.Any(d => d.CtLive && d.FkIdUsuarioDestino == usuarioId))
                    .OrderBy(x => x.CtCreatedDate)
                    .ThenBy(x => x.PkIdNotificacion)
                    .ToListAsync();

                var usuarios = await LoadUserNamesAsync(notifications
                    .Select(x => x.FkIdUsuarioOrigen)
                    .Concat(notifications.SelectMany(x => x.NotificacionDestinos.Select(d => (int?)d.FkIdUsuarioDestino))));

                var items = notifications
                    .Select(x => MapConversation(x, usuarioId, usuarios))
                    .ToList();

                return new PagedResult<NotificacionUsuarioResponse>
                {
                    Success = true,
                    Message = "Conversacion obtenida correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener conversacion de notificacion {NotificacionDestinoId}", notificacionDestinoId);
                return Error<NotificacionUsuarioResponse>(ex.Message);
            }
        }

        public async Task<PagedResult<bool>> MarcarLeidaAsync(long notificacionDestinoId, int usuarioId)
        {
            return await CambiarEstadoAsync(notificacionDestinoId, usuarioId, 2, "Notificación marcada como leída");
        }

        public async Task<PagedResult<bool>> AtenderAsync(long notificacionDestinoId, int usuarioId)
        {
            return await CambiarEstadoAsync(notificacionDestinoId, usuarioId, 3, "Notificación atendida");
        }

        public async Task<PagedResult<bool>> ResponderAsync(long notificacionDestinoId, int usuarioId, string mensaje)
        {
            if (string.IsNullOrWhiteSpace(mensaje))
            {
                return ErrorBool("La respuesta no puede ir vacía.");
            }

            var origen = await QueryUsuario(usuarioId)
                .FirstOrDefaultAsync(x => x.PkIdNotificacionDestino == notificacionDestinoId);

            if (origen == null)
            {
                return ErrorBool("La notificación no existe o no pertenece al usuario actual.");
            }

            if (!origen.FkIdUsuarioOrigen.HasValue || origen.FkIdUsuarioOrigen.Value <= 0)
            {
                return ErrorBool("La notificación no tiene usuario origen para responder.");
            }

            if (origen.FkIdUsuarioOrigen.Value == usuarioId)
            {
                return ErrorBool("No se puede responder una notificacion propia.");
            }

            try
            {
                var idNotificacion = new OutputParameter<long?>();
                await _context.Procedures.sp_NotificacionResponderAsync(
                    pk_IdNotificacionDestino: notificacionDestinoId,
                    fk_IdUsuarioResponde: usuarioId,
                    mensaje: mensaje.Trim(),
                    idUser: usuarioId,
                    idNotificacion: idNotificacion);

                return SuccessBool("Respuesta enviada correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al responder notificación {NotificacionDestinoId}", notificacionDestinoId);
                return ErrorBool(ex.Message);
            }
        }

        private IQueryable<VwNotificacionUsuario> QueryUsuario(int usuarioId)
        {
            return _context.VwNotificacionUsuarios
                .AsNoTracking()
                .Where(x => x.FkIdUsuarioDestino == usuarioId);
        }

        public async Task<PagedResult<bool>> SolicitarAyudaProcesoAsync(int usuarioId, SolicitudAyudaProcesoRequest request)
        {
            if (request == null || request.EntidadId <= 0 || string.IsNullOrWhiteSpace(request.ClaveAyuda))
            {
                return ErrorBool("Indica el expediente y el tipo de ayuda requerido.");
            }

            if (!ProcessHelpTargets.TryGetValue(request.ClaveAyuda.Trim(), out var target))
            {
                return ErrorBool("El tipo de ayuda solicitado no esta habilitado.");
            }

            try
            {
                var requisitionExists = await _context.Requisicions
                    .AsNoTracking()
                    .AnyAsync(x => x.PkidRequisicion == request.EntidadId && x.Activo);
                if (!requisitionExists)
                {
                    return ErrorBool("La requisicion indicada no existe o ya no esta activa.");
                }

                var reference = string.IsNullOrWhiteSpace(request.Referencia)
                    ? $"Expediente #{request.EntidadId}"
                    : TrimTo(request.Referencia, 180);
                var detail = string.IsNullOrWhiteSpace(request.Detalle)
                    ? target.DefaultMessage
                    : TrimTo(request.Detalle, 1200);
                var idNotificacion = new OutputParameter<long?>();

                await _context.Procedures.sp_NotificacionCrearPorPermisoAsync(
                    claveTipo: "AYUDA_PROCESO",
                    fk_IdUsuarioOrigen: usuarioId,
                    modulo: target.Module,
                    subModulo: target.SubModule,
                    accion: target.Action,
                    evento: "Solicitud de ayuda",
                    entidad: target.Entity,
                    fk_IdEntidad: request.EntidadId,
                    titulo: $"Ayuda requerida: {reference}",
                    mensaje: $"{detail} Ruta para atender: {target.MenuPath}.",
                    url: target.Route,
                    jsonData: null,
                    idUser: usuarioId,
                    idNotificacion: idNotificacion);

                return SuccessBool("Solicitud enviada al equipo responsable.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al solicitar ayuda {ClaveAyuda} para entidad {EntidadId}", request.ClaveAyuda, request.EntidadId);
                return ErrorBool("No fue posible enviar la solicitud de ayuda. Verifica que exista un responsable con el permiso indicado.");
            }
        }

        private static readonly IReadOnlyDictionary<string, ProcessHelpTarget> ProcessHelpTargets =
            new Dictionary<string, ProcessHelpTarget>(StringComparer.OrdinalIgnoreCase)
            {
                ["SISTEMA_USUARIO"] = new("Sistema", "Usuario", "update", "ORCO.Requisicion", "/configuracion/sistema/usuarios", "Configuracion > Sistema > Usuarios", "Se requiere habilitar la persona y el area solicitante."),
                ["EGRESO_PRESUPUESTO"] = new("Egreso", "Presupuesto_Autorizado", "update", "ORCO.Requisicion", "/Presupuesto/Egreso/Presupuesto_Autorizado", "Presupuesto > Egreso > Presupuesto autorizado", "Se requiere revisar la posicion y disponibilidad presupuestal."),
                ["ADQ_COMPRAS"] = new("Adquisiciones", "requisicion", "update", "ORCO.Requisicion", "/Adquisiciones/Requisicion", "Adquisiciones > Requisicion", "Se requiere apoyo de Compras para continuar el expediente."),
                ["ALMACEN_CATALOGO"] = new("Almacen", "Tipo_Bien", "update", "ORCO.Requisicion", "/configuracion/Patrimonio/Bienes_Servicios", "Configuracion > Patrimonio > Bienes y servicios", "Se requiere revisar el bien, servicio o su partida contable.")
            };

        private static string TrimTo(string value, int maxLength) =>
            value.Trim().Length <= maxLength ? value.Trim() : value.Trim()[..maxLength];

        private sealed record ProcessHelpTarget(
            string Module,
            string SubModule,
            string Action,
            string Entity,
            string Route,
            string MenuPath,
            string DefaultMessage);

        private IQueryable<Notificacion1> BuildConversationQuery(VwNotificacionUsuario origen)
        {
            var query = _context.Notificacions1
                .AsNoTracking()
                .Where(x => x.CtLive);

            if (origen.FkIdEntidad.HasValue)
            {
                var modulo = origen.Modulo ?? string.Empty;
                var subModulo = origen.SubModulo ?? string.Empty;
                var entidad = origen.Entidad ?? string.Empty;
                var entidadId = origen.FkIdEntidad.Value;

                return query.Where(x =>
                    x.Modulo == modulo &&
                    (x.SubModulo ?? string.Empty) == subModulo &&
                    (x.Entidad ?? string.Empty) == entidad &&
                    x.FkIdEntidad == entidadId);
            }

            if (!string.IsNullOrWhiteSpace(origen.JsonData))
            {
                var modulo = origen.Modulo ?? string.Empty;
                var subModulo = origen.SubModulo ?? string.Empty;
                var entidad = origen.Entidad ?? string.Empty;
                var jsonData = origen.JsonData;

                return query.Where(x =>
                    x.Modulo == modulo &&
                    (x.SubModulo ?? string.Empty) == subModulo &&
                    (x.Entidad ?? string.Empty) == entidad &&
                    x.JsonData == jsonData);
            }

            return query.Where(x => x.PkIdNotificacion == origen.PkIdNotificacion);
        }

        private static NotificacionUsuarioResponse Map(
            VwNotificacionUsuario row,
            int usuarioActual,
            IReadOnlyDictionary<int, string> usuarios)
        {
            var origenNombre = GetUserName(usuarios, row.FkIdUsuarioOrigen);
            var destinoNombre = GetUserName(usuarios, row.FkIdUsuarioDestino);
            var esRespuesta = IsReply(row.Tipo, row.Evento);

            return new NotificacionUsuarioResponse
            {
                PkidNotificacionDestino = row.PkIdNotificacionDestino,
                PkidNotificacion = row.PkIdNotificacion,
                FkidUsuarioOrigen = row.FkIdUsuarioOrigen,
                FkidUsuarioDestino = row.FkIdUsuarioDestino,
                Tipo = row.Tipo,
                Modulo = row.Modulo,
                SubModulo = row.SubModulo,
                Evento = row.Evento,
                Entidad = row.Entidad,
                FkidEntidad = row.FkIdEntidad,
                Titulo = row.Titulo,
                Mensaje = row.Mensaje,
                Url = row.Url,
                JsonData = row.JsonData,
                UsuarioOrigenNombre = origenNombre,
                UsuarioDestinoNombre = destinoNombre,
                Destinatarios = destinoNombre,
                Estado = row.Estado,
                FkidNotificacionEstado = row.FkIdNotificacionEstado,
                FechaLeido = row.FechaLeido,
                FechaAtendido = row.FechaAtendido,
                FechaNotificacion = row.FechaNotificacion,
                FueCreadaPorMi = row.FkIdUsuarioOrigen == usuarioActual,
                EsRespuesta = esRespuesta,
                NivelConversacion = esRespuesta ? 1 : 0
            };
        }

        private static NotificacionUsuarioResponse MapConversation(
            Notificacion1 row,
            int usuarioActual,
            IReadOnlyDictionary<int, string> usuarios)
        {
            var destinos = row.NotificacionDestinos
                .Where(x => x.CtLive)
                .OrderBy(x => x.PkIdNotificacionDestino)
                .ToList();
            var destinoActual = destinos.FirstOrDefault(x => x.FkIdUsuarioDestino == usuarioActual);
            var destinoPrincipal = destinoActual ?? destinos.FirstOrDefault();
            var tipo = row.FkIdNotificacionTipoNavigation?.Clave;
            var estadoId = destinoActual?.FkIdNotificacionEstado ?? 0;
            var esRespuesta = IsReply(tipo, row.Evento);

            return new NotificacionUsuarioResponse
            {
                PkidNotificacionDestino = destinoActual?.PkIdNotificacionDestino ?? 0,
                PkidNotificacion = row.PkIdNotificacion,
                FkidUsuarioOrigen = row.FkIdUsuarioOrigen,
                FkidUsuarioDestino = destinoPrincipal?.FkIdUsuarioDestino ?? 0,
                Tipo = tipo,
                Modulo = row.Modulo,
                SubModulo = row.SubModulo,
                Evento = row.Evento,
                Entidad = row.Entidad,
                FkidEntidad = row.FkIdEntidad,
                Titulo = row.Titulo,
                Mensaje = row.Mensaje,
                Url = row.Url,
                JsonData = row.JsonData,
                UsuarioOrigenNombre = GetUserName(usuarios, row.FkIdUsuarioOrigen),
                UsuarioDestinoNombre = GetUserName(usuarios, destinoPrincipal?.FkIdUsuarioDestino),
                Destinatarios = string.Join(", ", destinos
                    .Select(x => GetUserName(usuarios, x.FkIdUsuarioDestino))
                    .Where(x => !string.IsNullOrWhiteSpace(x))
                    .Distinct()),
                Estado = destinoActual == null && row.FkIdUsuarioOrigen == usuarioActual
                    ? "Enviada"
                    : EstadoDescripcion(estadoId),
                FkidNotificacionEstado = estadoId,
                FechaLeido = destinoActual?.FechaLeido,
                FechaAtendido = destinoActual?.FechaAtendido,
                FechaNotificacion = row.CtCreatedDate,
                FueCreadaPorMi = row.FkIdUsuarioOrigen == usuarioActual,
                EsRespuesta = esRespuesta,
                NivelConversacion = esRespuesta ? 1 : 0
            };
        }

        private async Task<Dictionary<int, string>> LoadUserNamesAsync(IEnumerable<int?> ids)
        {
            var userIds = ids
                .Where(x => x.HasValue && x.Value > 0)
                .Select(x => x!.Value)
                .Distinct()
                .ToArray();

            if (userIds.Length == 0)
            {
                return new Dictionary<int, string>();
            }

            var users = await (
                from u in _context.Usuarios.AsNoTracking()
                join p in _context.Personas.AsNoTracking()
                    on u.FkidPersonaNom equals p.PkidPersona into personas
                from p in personas.DefaultIfEmpty()
                join au in _context.AspNetUsers.AsNoTracking()
                    on (int?)u.PkIdUsuario equals au.PkIdUsuario into aspUsers
                from au in aspUsers.DefaultIfEmpty()
                where userIds.Contains(u.PkIdUsuario)
                select new
                {
                    u.PkIdUsuario,
                    u.PayrollId,
                    Email = au.Email,
                    Nombre = p.Nombre,
                    Paterno = p.Paterno,
                    Materno = p.Materno
                })
                .ToListAsync();

            return users
                .GroupBy(x => x.PkIdUsuario)
                .ToDictionary(
                x => x.Key,
                x =>
                {
                    var user = x.First();
                    var fullName = string.Join(" ", new[] { user.Nombre, user.Paterno, user.Materno }
                        .Where(value => !string.IsNullOrWhiteSpace(value)));
                    if (!string.IsNullOrWhiteSpace(fullName))
                    {
                        return fullName;
                    }

                    if (!string.IsNullOrWhiteSpace(user.Email))
                    {
                        return user.Email;
                    }

                    return string.IsNullOrWhiteSpace(user.PayrollId)
                        ? $"Usuario {user.PkIdUsuario}"
                        : user.PayrollId;
                });
        }

        private static string GetUserName(IReadOnlyDictionary<int, string> usuarios, int? usuarioId)
        {
            if (!usuarioId.HasValue || usuarioId.Value <= 0)
            {
                return string.Empty;
            }

            return usuarios.TryGetValue(usuarioId.Value, out var nombre)
                ? nombre
                : $"Usuario {usuarioId.Value}";
        }

        private static bool IsReply(string? tipo, string? evento) =>
            string.Equals(tipo, "RESPUESTA_NOTIFICACION", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(evento, "Respuesta", StringComparison.OrdinalIgnoreCase);

        private static string EstadoDescripcion(int estadoId) =>
            estadoId switch
            {
                1 => "Pendiente",
                2 => "Leida",
                3 => "Atendida",
                4 => "Cancelada",
                _ => "Enviada"
            };

        private async Task<PagedResult<bool>> CambiarEstadoAsync(long notificacionDestinoId, int usuarioId, int estadoId, string mensaje)
        {
            try
            {
                await _context.Procedures.sp_NotificacionActualizarEstadoAsync(notificacionDestinoId, usuarioId, estadoId, usuarioId);
                return SuccessBool(mensaje);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar estado de notificación {NotificacionDestinoId}", notificacionDestinoId);
                return ErrorBool(ex.Message);
            }
        }

        private static PagedResult<T> Success<T>(T data, string message)
        {
            return new PagedResult<T>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = data,
                Items = new List<T> { data },
                TotalCount = 1
            };
        }

        private static PagedResult<T> Error<T>(string message)
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = "ERROR",
                TotalCount = 0
            };
        }

        private static PagedResult<bool> SuccessBool(string message)
        {
            return new PagedResult<bool>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            };
        }

        private static PagedResult<bool> ErrorBool(string message)
        {
            return new PagedResult<bool>
            {
                Success = false,
                Message = message,
                Code = "ERROR",
                Data = false,
                TotalCount = 0
            };
        }
    }
}

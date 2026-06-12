using System.Data;
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
                var query = QueryUsuario(usuarioId);
                var totalTask = query.CountAsync();
                var pendientesTask = query.CountAsync(x => x.FkIdNotificacionEstado == 1);
                var leidasTask = query.CountAsync(x => x.FkIdNotificacionEstado == 2);
                var atendidasTask = query.CountAsync(x => x.FkIdNotificacionEstado == 3);
                var accionTask = query.CountAsync(x => x.FkIdNotificacionEstado == 1 && x.Url != null && x.Url != string.Empty);

                await Task.WhenAll(totalTask, pendientesTask, leidasTask, atendidasTask, accionTask);

                var data = new NotificacionResumenResponse
                {
                    Total = totalTask.Result,
                    Pendientes = pendientesTask.Result,
                    Leidas = leidasTask.Result,
                    Atendidas = atendidasTask.Result,
                    RequierenAccion = accionTask.Result
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

                var items = rows.Select(Map).ToList();

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

            try
            {
                var usuarios = new DataTable();
                usuarios.Columns.Add("Fk_IdUsuarioDestino", typeof(int));
                usuarios.Rows.Add(origen.FkIdUsuarioOrigen.Value);

                var idNotificacion = new OutputParameter<long?>();
                await _context.Procedures.sp_NotificacionCrearAsync(
                    claveTipo: "RESPUESTA_NOTIFICACION",
                    fk_IdUsuarioOrigen: usuarioId,
                    modulo: origen.Modulo ?? "Sistema",
                    subModulo: origen.SubModulo,
                    evento: "Respuesta",
                    entidad: origen.Entidad,
                    fk_IdEntidad: origen.FkIdEntidad,
                    titulo: $"Respuesta: {origen.Titulo}",
                    mensaje: mensaje.Trim(),
                    url: origen.Url,
                    jsonData: origen.JsonData,
                    usuarios: usuarios,
                    idUser: usuarioId,
                    idNotificacion: idNotificacion);

                await _context.Procedures.sp_NotificacionActualizarEstadoAsync(notificacionDestinoId, usuarioId, 3, usuarioId);

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

        private static NotificacionUsuarioResponse Map(VwNotificacionUsuario row)
        {
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
                Estado = row.Estado,
                FkidNotificacionEstado = row.FkIdNotificacionEstado,
                FechaLeido = row.FechaLeido,
                FechaAtendido = row.FechaAtendido,
                FechaNotificacion = row.FechaNotificacion
            };
        }

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

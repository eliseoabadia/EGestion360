using System.Globalization;
using System.Net;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class CotizacionAppService
        : AdquisicionCrudAppService<Cotizacion, VwCotizacion, CotizacionDto, CotizacionResponse>,
            ICotizacionAppService
    {
        private readonly EGestionContext _context;
        private readonly IEmailService _emailService;

        public CotizacionAppService(
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> service,
            GenericService<VwCotizacion, CotizacionDto, CotizacionResponse> serviceView,
            EGestionContext context,
            IEmailService emailService)
            : base(
                service,
                serviceView,
                "PkidCotizacion",
                "Cotizacion",
                (dto, id) => dto.PkidCotizacion = id)
        {
            _context = context;
            _emailService = emailService;
        }

        public override async Task<PagedResult<CotizacionResponse>> CreateAsync(CotizacionResponse response, int usuarioActual)
        {
            try
            {
                var validation = await NormalizeAndValidateAsync(response, requireDetails: true);
                if (validation != null)
                {
                    return validation;
                }

                var now = DateTime.Now;
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoCotizacion]",
                    StoredProcedureExecutor.Param("@Action", 1),
                    StoredProcedureExecutor.Param("@FKIdRequisicion_ORCO", response.FkidRequisicionOrco),
                    StoredProcedureExecutor.Param("@FKIdProveedor_SIS", response.FkidProveedorSis),
                    StoredProcedureExecutor.Param("@FechaSolicitud", response.FechaSolicitud == default ? now.Date : response.FechaSolicitud),
                    StoredProcedureExecutor.Param("@FechaProveedorCotiza", response.FechaProveedorCotiza),
                    StoredProcedureExecutor.Param("@FechaProveedorCompromiso", response.FechaProveedorCompromiso),
                    StoredProcedureExecutor.Param("@Comentarios", response.Comentarios),
                    StoredProcedureExecutor.Param("@FL_Documento", response.FlDocumento),
                    StoredProcedureExecutor.Param("@Entrega", response.Entrega),
                    StoredProcedureExecutor.Param("@Vigencia", response.Vigencia),
                    StoredProcedureExecutor.Param("@Condiciones", response.Condiciones),
                    StoredProcedureExecutor.Param("@FKIdAnio_SIS", response.FkidAnioSis),
                    StoredProcedureExecutor.Param("@FKIdContenedorCot_ORCO", response.FkidContenedorCotOrco),
                    StoredProcedureExecutor.Param("@FKIdContenedorMultiCot_ORCO", response.FkidContenedorMultiCotOrco),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                response.PkidCotizacion = spResult.GetId() ?? 0;

                var result = await GetByIdAsync(response.PkidCotizacion);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<CotizacionResponse>($"Error al crear Cotizacion: {ex.Message}");
            }
        }

        public override async Task<PagedResult<CotizacionResponse>> UpdateAsync(int id, CotizacionResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, requireDetails: false);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoCotizacion]",
                    StoredProcedureExecutor.Param("@Action", 2),
                    StoredProcedureExecutor.Param("@PKIdCotizacion", id),
                    StoredProcedureExecutor.Param("@FKIdRequisicion_ORCO", response.FkidRequisicionOrco),
                    StoredProcedureExecutor.Param("@FKIdProveedor_SIS", response.FkidProveedorSis),
                    StoredProcedureExecutor.Param("@FechaSolicitud", response.FechaSolicitud),
                    StoredProcedureExecutor.Param("@FechaProveedorCotiza", response.FechaProveedorCotiza),
                    StoredProcedureExecutor.Param("@FechaProveedorCompromiso", response.FechaProveedorCompromiso),
                    StoredProcedureExecutor.Param("@Comentarios", response.Comentarios),
                    StoredProcedureExecutor.Param("@Servicio", response.Servicio),
                    StoredProcedureExecutor.Param("@FL_Documento", response.FlDocumento),
                    StoredProcedureExecutor.Param("@Entrega", response.Entrega),
                    StoredProcedureExecutor.Param("@Vigencia", response.Vigencia),
                    StoredProcedureExecutor.Param("@Condiciones", response.Condiciones),
                    StoredProcedureExecutor.Param("@FKIdAnio_SIS", response.FkidAnioSis),
                    StoredProcedureExecutor.Param("@FKIdContenedorCot_ORCO", response.FkidContenedorCotOrco),
                    StoredProcedureExecutor.Param("@FKIdContenedorMultiCot_ORCO", response.FkidContenedorMultiCotOrco),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure<CotizacionResponse>($"Error al actualizar Cotizacion: {ex.Message}", "ERROR");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoCotizacion]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdCotizacion", id));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
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
                    Message = $"Error al eliminar Cotizacion: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<CotizacionResponse>> SendCotizacionEmailAsync(int cotizacionId, int usuarioActual)
        {
            try
            {
                var cotizacion = await _context.Cotizacions
                    .Include(x => x.FkidProveedorSisNavigation)
                    .Include(x => x.FkidRequisicionOrcoNavigation)
                    .FirstOrDefaultAsync(x => x.PkidCotizacion == cotizacionId && x.Activo);

                if (cotizacion == null)
                {
                    return Failure<CotizacionResponse>("La cotizacion no existe o esta inactiva.", "NOT_FOUND");
                }

                if (cotizacion.FkidProveedorSisNavigation == null ||
                    string.IsNullOrWhiteSpace(cotizacion.FkidProveedorSisNavigation.Email))
                {
                    return Failure<CotizacionResponse>("El proveedor no tiene email capturado.");
                }

                await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoCotizacion]",
                    StoredProcedureExecutor.Param("@Action", 5),
                    StoredProcedureExecutor.Param("@PKIdCotizacion", cotizacion.PkidCotizacion),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                var detalles = await GetCotizacionEmailDetallesAsync(cotizacion.PkidCotizacion);
                if (!detalles.Any())
                {
                    return Failure<CotizacionResponse>("La requisicion no tiene bienes para solicitar cotizacion.");
                }

                var email = new EmailMessageRequest
                {
                    To = new List<string> { cotizacion.FkidProveedorSisNavigation.Email },
                    Subject = $"Solicitud de cotizacion - {cotizacion.FkidRequisicionOrcoNavigation?.Descripcion ?? cotizacion.PkidCotizacion.ToString()}",
                    Body = BuildCotizacionEmailBody(cotizacion, detalles),
                    IsHtml = true
                };

                var emailResult = await _emailService.SendAsync(email);
                if (!emailResult.Success)
                {
                    return Failure<CotizacionResponse>(emailResult.Message);
                }

                var result = await GetByIdAsync(cotizacion.PkidCotizacion);
                result.Message = "Solicitud de cotizacion enviada por correo.";
                return result;
            }
            catch (Exception ex)
            {
                return Failure<CotizacionResponse>($"Error al enviar cotizacion por correo: {ex.Message}");
            }
        }

        public async Task<PagedResult<CotizacionDetalleResponse>> GetRecepcionCotizacionAsync(int cotizacionId)
        {
            try
            {
                var items = await GetCotizacionDetallesAsync(cotizacionId);
                return new PagedResult<CotizacionDetalleResponse>
                {
                    Success = true,
                    Message = "Bienes cotizados obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (Exception ex)
            {
                return Failure<CotizacionDetalleResponse>($"Error al obtener bienes cotizados: {ex.Message}");
            }
        }

        public async Task<PagedResult<CotizacionDetalleResponse>> SaveRecepcionCotizacionAsync(CotizacionRecepcionRequest request, int usuarioActual)
        {
            try
            {
                if (request == null || request.FkidCotizacionOrco <= 0)
                {
                    return Failure<CotizacionDetalleResponse>("Debe existir una cotizacion seleccionada.");
                }

                var validItems = request.Items?
                    .Where(x => x.PkidCotizacionDetalle > 0)
                    .GroupBy(x => x.PkidCotizacionDetalle)
                    .Select(x => x.First())
                    .ToList() ?? new List<CotizacionRecepcionItemRequest>();

                if (!validItems.Any())
                {
                    return Failure<CotizacionDetalleResponse>("No hay bienes cotizados para guardar.");
                }

                if (validItems.Any(x => x.PrecioUnitario.HasValue && x.PrecioUnitario.Value <= 0m))
                {
                    return Failure<CotizacionDetalleResponse>("Los precios capturados deben ser mayores a cero.");
                }

                var ids = validItems.Select(x => x.PkidCotizacionDetalle).ToList();
                var detalles = await _context.CotizacionDetalles
                    .Include(x => x.FkidCotizacionOrcoNavigation)
                    .Where(x =>
                        x.Activo &&
                        ids.Contains(x.PkidCotizacionDetalle) &&
                        x.FkidCotizacionOrco == request.FkidCotizacionOrco &&
                        x.FkidCotizacionOrcoNavigation.Activo)
                    .ToDictionaryAsync(x => x.PkidCotizacionDetalle);

                if (detalles.Count != ids.Count)
                {
                    return Failure<CotizacionDetalleResponse>("Uno o mas bienes no pertenecen a la cotizacion seleccionada.");
                }

                await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoCotizacion]",
                    StoredProcedureExecutor.Param("@Action", 4),
                    StoredProcedureExecutor.Param("@PKIdCotizacion", request.FkidCotizacionOrco),
                    StoredProcedureExecutor.JsonParam("@ItemsJson", validItems),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                return await GetRecepcionCotizacionAsync(request.FkidCotizacionOrco);
            }
            catch (Exception ex)
            {
                return Failure<CotizacionDetalleResponse>($"Error al guardar montos cotizados: {ex.Message}");
            }
        }

        private async Task<PagedResult<CotizacionResponse>?> NormalizeAndValidateAsync(CotizacionResponse response, bool requireDetails)
        {
            if (response == null)
            {
                return Failure<CotizacionResponse>("La cotizacion no contiene datos.");
            }

            if (response.FkidRequisicionOrco <= 0)
            {
                return Failure<CotizacionResponse>("Debe seleccionar una requisicion.");
            }

            if (response.FkidProveedorSis <= 0)
            {
                return Failure<CotizacionResponse>("Debe seleccionar un proveedor.");
            }

            var requisicion = await _context.Requisicions
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidRequisicion == response.FkidRequisicionOrco && x.Activo);

            if (requisicion == null)
            {
                return Failure<CotizacionResponse>("La requisicion no existe o esta inactiva.");
            }

            var proveedorExists = await _context.Proveedors
                .AsNoTracking()
                .AnyAsync(x => x.PkidProveedor == response.FkidProveedorSis && x.Activo);

            if (!proveedorExists)
            {
                return Failure<CotizacionResponse>("El proveedor no existe o esta inactivo.");
            }

            if (requireDetails)
            {
                var hasDetails = await _context.RequisicionDetalles
                    .AsNoTracking()
                    .AnyAsync(x => x.FkidRequisicionOrco == requisicion.PkidRequisicion && x.Activo);

                if (!hasDetails)
                {
                    return Failure<CotizacionResponse>("La requisicion debe tener al menos un bien para generar una cotizacion.");
                }
            }

            response.Servicio = requisicion.Servicio;
            response.FkidAnioSis = response.FkidAnioSis.GetValueOrDefault() > 0
                ? response.FkidAnioSis
                : requisicion.FkidAnioSis;
            response.FechaSolicitud = response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud;
            response.FlDocumento ??= string.Empty;
            response.Entrega ??= string.Empty;
            response.Vigencia ??= string.Empty;
            response.Condiciones ??= string.Empty;
            response.Comentarios ??= string.Empty;

            return null;
        }

        private async Task<int> SeedDetallesFromRequisicionAsync(int cotizacionId, int requisicionId, int usuarioActual, DateTime now)
        {
            if (cotizacionId <= 0 || requisicionId <= 0)
            {
                return 0;
            }

            var detalleIds = await _context.RequisicionDetalles
                .AsNoTracking()
                .Where(x => x.Activo && x.FkidRequisicionOrco == requisicionId)
                .Select(x => x.PkidRequisicionDetalle)
                .ToListAsync();

            if (!detalleIds.Any())
            {
                return 0;
            }

            var existingIds = await _context.CotizacionDetalles
                .AsNoTracking()
                .Where(x => x.Activo && x.FkidCotizacionOrco == cotizacionId)
                .Select(x => x.FkidRequisicionDetalleOrco)
                .ToListAsync();

            var existing = existingIds.ToHashSet();
            var created = 0;
            foreach (var detalleId in detalleIds.Where(x => !existing.Contains(x)))
            {
                await _context.CotizacionDetalles.AddAsync(new CotizacionDetalle
                {
                    FkidCotizacionOrco = cotizacionId,
                    FkidRequisicionDetalleOrco = detalleId,
                    PrecioUnitario = null,
                    Activo = true,
                    FechaCreacion = now,
                    UsuarioCreacion = usuarioActual
                });

                created++;
            }

            return created;
        }

        private async Task<List<CotizacionDetalleResponse>> GetCotizacionDetallesAsync(int cotizacionId)
        {
            var items = await _context.VwCotizacionDetalles
                .AsNoTracking()
                .Where(x => x.Activo && x.FkidCotizacionOrco == cotizacionId)
                .OrderBy(x => x.TipoBienClave)
                .ThenBy(x => x.TipoBienDescripcion)
                .ToListAsync();

            return items.Adapt<List<CotizacionDetalleResponse>>();
        }

        private async Task<List<CotizacionEmailDetalle>> GetCotizacionEmailDetallesAsync(int cotizacionId)
        {
            var detalles = await (
                from cotizacionDetalle in _context.CotizacionDetalles.AsNoTracking()
                join detalle in _context.RequisicionDetalles.AsNoTracking()
                    on cotizacionDetalle.FkidRequisicionDetalleOrco equals detalle.PkidRequisicionDetalle
                join tipoBien in _context.TipoBiens.AsNoTracking()
                    on detalle.FkidTipoBienAlma equals tipoBien.PkidTipoBien
                join unidadJoin in _context.Unidades.AsNoTracking()
                    on detalle.FkidUnidadesAlma equals unidadJoin.PkidUnidades into unidades
                from unidad in unidades.DefaultIfEmpty()
                where cotizacionDetalle.Activo &&
                      detalle.Activo &&
                      tipoBien.Activo &&
                      cotizacionDetalle.FkidCotizacionOrco == cotizacionId
                orderby tipoBien.CodigoClave, tipoBien.Descripcion
                select new
                {
                    Clave = tipoBien.CodigoClave ?? string.Empty,
                    Descripcion = tipoBien.Descripcion ?? string.Empty,
                    Cantidad = detalle.Cantidad,
                    Unidad = unidad == null ? string.Empty : unidad.Descripcion ?? string.Empty,
                    Observaciones = detalle.Observaciones ?? string.Empty
                })
                .ToListAsync();

            return detalles.Select(x => new CotizacionEmailDetalle
            {
                Clave = x.Clave,
                Descripcion = x.Descripcion,
                Cantidad = x.Cantidad,
                Unidad = x.Unidad,
                Observaciones = x.Observaciones
            }).ToList();
        }

        private static string BuildCotizacionEmailBody(Cotizacion cotizacion, List<CotizacionEmailDetalle> detalles)
        {
            var requisicion = cotizacion.FkidRequisicionOrcoNavigation;
            var proveedor = cotizacion.FkidProveedorSisNavigation;
            var rows = string.Join(string.Empty, detalles.Select(detalle =>
            {
                var clave = WebUtility.HtmlEncode(detalle.Clave);
                var descripcion = WebUtility.HtmlEncode(detalle.Descripcion);
                var unidad = WebUtility.HtmlEncode(detalle.Unidad);
                var observaciones = WebUtility.HtmlEncode(detalle.Observaciones);

                return $@"
                    <tr>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{clave}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{descripcion}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;text-align:right;"">{FormatQuantity(detalle.Cantidad)}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{unidad}</td>
                        <td style=""padding:8px;border-bottom:1px solid #e5e7eb;"">{observaciones}</td>
                    </tr>";
            }));

            var compromiso = cotizacion.FechaProveedorCompromiso.HasValue
                ? cotizacion.FechaProveedorCompromiso.Value.ToString("dd/MM/yyyy")
                : "Por definir";

            return $@"
                <div style=""font-family:Segoe UI,Arial,sans-serif;color:#111827;font-size:14px;"">
                    <p>Estimado proveedor {WebUtility.HtmlEncode(proveedor?.Nombre ?? string.Empty)},</p>
                    <p>Se solicita su cotizacion para la requisicion <strong>{WebUtility.HtmlEncode(requisicion?.Descripcion ?? cotizacion.PkidCotizacion.ToString())}</strong>.</p>
                    <p><strong>Fecha de solicitud:</strong> {cotizacion.FechaSolicitud:dd/MM/yyyy}<br />
                    <strong>Fecha compromiso:</strong> {compromiso}</p>
                    <table style=""border-collapse:collapse;width:100%;margin-top:12px;"">
                        <thead>
                            <tr style=""background:#f3f4f6;"">
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Clave</th>
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Bien / Servicio</th>
                                <th style=""padding:8px;text-align:right;border-bottom:1px solid #d1d5db;"">Cantidad</th>
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Unidad</th>
                                <th style=""padding:8px;text-align:left;border-bottom:1px solid #d1d5db;"">Observaciones</th>
                            </tr>
                        </thead>
                        <tbody>{rows}</tbody>
                    </table>
                    <p style=""margin-top:14px;"">Favor de responder con precio unitario, vigencia, entrega y condiciones comerciales.</p>
                </div>";
        }

        private static readonly CultureInfo NumberCulture = CultureInfo.InvariantCulture;

        private static string FormatQuantity(decimal value) => value.ToString("0.00", NumberCulture);

        private static PagedResult<T> Failure<T>(string message, string code = "VALIDATION") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };

        private sealed class CotizacionEmailDetalle
        {
            public string Clave { get; set; } = string.Empty;
            public string Descripcion { get; set; } = string.Empty;
            public decimal Cantidad { get; set; }
            public string Unidad { get; set; } = string.Empty;
            public string Observaciones { get; set; } = string.Empty;
        }
    }
}

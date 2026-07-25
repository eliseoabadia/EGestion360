using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Data;
using System.Data.Common;

namespace EG.Application.Services.ConteoCiclico
{
    public class PeriodoConteoAppService : IPeriodoConteoAppService
    {
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _service;
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _serviceView;
        private readonly EGestionContext _context;

        public PeriodoConteoAppService(
            GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> service,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> serviceView,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PeriodoConteoResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual)
        {
            ConteoCiclicoValidator.ValidatePeriodo(dto);
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await NormalizeAsync(dto);
            await EnsureUniqueCodeAsync(dto);
            await _service.AddAsync(dto);
            return await _serviceView.GetByIdAsync(dto.PkidPeriodoConteo, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual)
        {
            var existing = await GetPeriodoEntityAsync(id);
            await EnsureCurrentStatusAsync(existing, "Pendiente");

            ConteoCiclicoValidator.ValidatePeriodo(dto);
            dto.PkidPeriodoConteo = id;
            dto.FkidEstatusAlma = existing.FkidEstatusAlma;
            dto.FechaCierre = existing.FechaCierre;
            dto.UsuarioCreacion = existing.UsuarioCreacion;
            dto.FechaCreacion = existing.FechaCreacion;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await NormalizeAsync(dto);
            await EnsureUniqueCodeAsync(dto, id);
            await _service.UpdateAsync(id, dto);
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
        }

        private async Task NormalizeAsync(PeriodoConteoDto dto)
        {
            dto.CodigoPeriodo = (dto.CodigoPeriodo ?? string.Empty).Trim();
            dto.Nombre = (dto.Nombre ?? string.Empty).Trim();
            dto.Descripcion = (dto.Descripcion ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(dto.CodigoPeriodo))
            {
                throw new ArgumentException("El codigo del periodo es requerido.");
            }

            if (string.IsNullOrWhiteSpace(dto.Nombre))
            {
                throw new ArgumentException("El nombre del periodo es requerido.");
            }

            if (dto.FkidSucursalSis <= 0)
            {
                throw new ArgumentException("Selecciona una sucursal valida.");
            }

            if (!await _context.Sucursals.AnyAsync(s => s.PkidSucursal == dto.FkidSucursalSis && s.Activo))
            {
                throw new ArgumentException("La sucursal seleccionada no existe o no esta activa.");
            }

            if (!await _context.Usuarios.AnyAsync(u =>
                    u.PkIdUsuario == dto.FkidResponsableSis && u.Activo))
            {
                throw new ArgumentException("La persona responsable no existe o no esta activa.");
            }

            if (dto.RequiereAprobacionSupervisor && !await _context.Usuarios.AnyAsync(u =>
                    u.PkIdUsuario == dto.FkidSupervisorSis && u.Activo))
            {
                throw new ArgumentException("El supervisor seleccionado no existe o no esta activo.");
            }

            if (dto.FkidTipoConteoAlma <= 0 || !await _context.TipoConteos.AnyAsync(t => t.PkidTipoConteo == dto.FkidTipoConteoAlma && t.Activo))
            {
                dto.FkidTipoConteoAlma = await GetDefaultTipoConteoIdAsync();
            }

            if (dto.FkidEstatusAlma <= 0 || !await _context.EstatusPeriodos.AnyAsync(e => e.PkidEstatusPeriodo == dto.FkidEstatusAlma && e.Activo))
            {
                dto.FkidEstatusAlma = await GetDefaultEstatusPeriodoIdAsync();
            }
        }

        private async Task<int> GetDefaultTipoConteoIdAsync()
        {
            var tipoId = await _context.TipoConteos
                .Where(t => t.Activo)
                .OrderBy(t => t.PkidTipoConteo)
                .Select(t => t.PkidTipoConteo)
                .FirstOrDefaultAsync();

            if (tipoId <= 0)
            {
                throw new ArgumentException("No hay tipos de conteo activos para crear el periodo.");
            }

            return tipoId;
        }

        private async Task<int> GetDefaultEstatusPeriodoIdAsync()
        {
            var estatus = await _context.EstatusPeriodos
                .Where(e => e.Activo)
                .OrderByDescending(e => e.Nombre.Contains("Abierto"))
                .ThenByDescending(e => e.Nombre.Contains("Activo"))
                .ThenBy(e => e.PkidEstatusPeriodo)
                .Select(e => e.PkidEstatusPeriodo)
                .FirstOrDefaultAsync();

            if (estatus <= 0)
            {
                throw new ArgumentException("No hay estatus de periodo activos para crear el periodo.");
            }

            return estatus;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var existing = await GetPeriodoEntityAsync(id);
            await EnsureCurrentStatusAsync(existing, "Pendiente");

            if (await _context.Conteos.AnyAsync(c => c.FkidPeriodoConteoAlma == id && c.Activo))
                throw new InvalidOperationException("No se puede eliminar un periodo que ya tiene conteos activos.");

            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<PeriodoConteoResponse> IniciarAsync(int id, int usuarioActual)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                var periodo = await GetPeriodoEntityAsync(id);
                await EnsureCurrentStatusAsync(periodo, "Pendiente");

                var conteosExistentes = await _context.Conteos
                    .AnyAsync(c => c.FkidPeriodoConteoAlma == id && c.Activo);

                if (!conteosExistentes)
                {
                    var tiposActivos = await _context.TipoBiens
                        .AsNoTracking()
                        .Where(t => t.Activo && t.FkidPartidaConta > 20000 && t.FkidPartidaConta < 30000)
                        .Select(t => t.PkidTipoBien)
                        .ToListAsync();

                    var existencias = await _context.VwExistencias
                        .AsNoTracking()
                        .Where(e => tiposActivos.Contains(e.PkidTipoBien) && e.Existencias > 0)
                        .ToListAsync();

                    foreach (var grupo in existencias.GroupBy(e => e.PkidTipoBien))
                    {
                        var primera = grupo.First();
                        _context.Conteos.Add(new Conteo
                        {
                            FkidTipoBienAlma = grupo.Key,
                            FkidPeriodoConteoAlma = id,
                            CantidadInventario = grupo.Sum(e => e.Existencias ?? 0),
                            Descripcion = primera.Descripcion ?? $"Conteo del tipo de bien {grupo.Key}",
                            FechaInicio = DateTime.Now,
                            Activo = true,
                            UsuarioCreacion = usuarioActual,
                            FechaCreacion = DateTime.Now
                        });
                    }

                    if (existencias.Count == 0)
                        throw new InvalidOperationException("No hay existencias positivas para iniciar el periodo. Registra inventario o crea los conteos antes de iniciarlo.");
                }

                periodo.FkidEstatusAlma = await GetStatusIdAsync("En Proceso");
                periodo.TotalArticulos = await _context.Conteos.CountAsync(c => c.FkidPeriodoConteoAlma == id && c.Activo);
                periodo.ArticulosConcluidos = 0;
                periodo.ArticulosConDiferencia = 0;
                periodo.UsuarioModificacion = usuarioActual;
                periodo.FechaModificacion = DateTime.Now;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            });

            return await GetRequiredResponseAsync(id);
        }

        public async Task<PeriodoConteoResponse> CompletarAsync(int id, int usuarioActual)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                var periodo = await GetPeriodoEntityAsync(id);
                await EnsureCurrentStatusAsync(periodo, "En Proceso");

                var conteos = await _context.Conteos
                    .Where(c => c.FkidPeriodoConteoAlma == id && c.Activo)
                    .ToListAsync();

                if (conteos.Count == 0)
                    throw new InvalidOperationException("El periodo no tiene conteos activos para completar.");

                var conteoIds = conteos.Select(c => c.PkidConteo).ToList();
                var lecturas = await _context.ConteoDetalleEscaneos
                    .AsNoTracking()
                    .Where(e => e.Activo && conteoIds.Contains(e.FkidConteoAlma) && e.FkidBienAlma.HasValue)
                    .GroupBy(e => e.FkidConteoAlma)
                    .Select(g => new { ConteoId = g.Key, Total = g.Select(e => e.FkidBienAlma).Distinct().Count() })
                    .ToDictionaryAsync(x => x.ConteoId, x => x.Total);

                var pendientes = conteos
                    .Where(c => c.CantidadInventario > 0 && !lecturas.ContainsKey(c.PkidConteo))
                    .Select(c => c.Descripcion)
                    .Take(3)
                    .ToList();

                if (pendientes.Count > 0)
                    throw new InvalidOperationException($"Aun existen conteos sin lecturas: {string.Join(", ", pendientes)}.");

                var concluidos = 0;
                var diferencias = 0;
                foreach (var conteo in conteos)
                {
                    var totalLecturas = lecturas.GetValueOrDefault(conteo.PkidConteo);
                    if (totalLecturas == conteo.CantidadInventario)
                        concluidos++;
                    else
                        diferencias++;

                    conteo.FechaFin = DateTime.Now;
                    conteo.UsuarioModificacion = usuarioActual;
                    conteo.FechaModificacion = DateTime.Now;
                }

                periodo.TotalArticulos = conteos.Count;
                periodo.ArticulosConcluidos = concluidos;
                periodo.ArticulosConDiferencia = diferencias;
                periodo.FkidEstatusAlma = await GetStatusIdAsync("Completado");
                periodo.UsuarioModificacion = usuarioActual;
                periodo.FechaModificacion = DateTime.Now;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            });

            return await GetRequiredResponseAsync(id);
        }

        public async Task<PeriodoConteoResponse> CerrarAsync(int id, int usuarioActual)
        {
            var periodo = await GetPeriodoEntityAsync(id);
            await EnsureCurrentStatusAsync(periodo, "Completado");

            if (periodo.RequiereAprobacionSupervisor && periodo.FkidSupervisorSis != usuarioActual)
                throw new InvalidOperationException("Este periodo debe ser cerrado por el supervisor asignado.");

            if (periodo.ArticulosConDiferencia.GetValueOrDefault() > 0)
            {
                var puedeRevisarDiferencias = periodo.FkidSupervisorSis == usuarioActual ||
                    await _context.Usuarios.AsNoTracking().AnyAsync(u =>
                        u.PkIdUsuario == usuarioActual && u.Activo && u.EsAdministrador) ||
                    await _context.UsuarioSucursals.AsNoTracking().AnyAsync(us =>
                        us.FkidUsuarioSis == usuarioActual &&
                        us.FkidSucursalSis == periodo.FkidSucursalSis &&
                        us.Activo && us.PuedeAcceder && us.EsSupervisor);

                if (!puedeRevisarDiferencias)
                    throw new InvalidOperationException("El periodo tiene diferencias y debe ser revisado por un supervisor antes de cerrar.");
            }

            periodo.FkidEstatusAlma = await GetStatusIdAsync("Cerrado");
            periodo.FechaCierre = DateTime.Now;
            periodo.UsuarioModificacion = usuarioActual;
            periodo.FechaModificacion = DateTime.Now;
            await _context.SaveChangesAsync();

            await _context.Database.ExecuteSqlInterpolatedAsync($@"
                UPDATE P
                   SET UltimaFechaConteo = CONVERT(date, GETDATE()),
                       ProximaFechaConteo = DATEADD(day, P.FrecuenciaDias, CONVERT(date, GETDATE())),
                       RequiereConteoPorUmbral = 0,
                       FechaModificacion = SYSDATETIME(),
                       UsuarioModificacion = {usuarioActual}
                FROM ALMA.PlanConteoCiclico P
                WHERE EXISTS
                (
                    SELECT 1
                    FROM ALMA.Conteo C
                    WHERE C.FKIdPeriodoConteo_ALMA = {id}
                      AND C.FKIdTipoBien_ALMA = P.FKIdTipoBien_ALMA
                      AND C.Activo = 1
                );");

            return await GetRequiredResponseAsync(id);
        }

        public async Task<IReadOnlyList<ConteoPlanificacionResponse>> GetPlanificacionAsync()
        {
            const string sql = """
                SELECT
                    P.PKIdPlanConteoCiclico,
                    P.FKIdTipoBien_ALMA,
                    ISNULL(T.CodigoClave, ''),
                    ISNULL(T.Descripcion, ''),
                    P.FKIdArea_SIS,
                    ISNULL(A.Nombre, 'Sin ubicacion asignada'),
                    P.ClasificacionABC,
                    P.FrecuenciaDias,
                    P.UltimaFechaConteo,
                    P.ProximaFechaConteo,
                    P.ExistenciaActual,
                    P.ExistenciaMinima,
                    P.ValorInventario,
                    P.GenerarPorUmbral,
                    P.RequiereConteoPorUmbral,
                    CASE WHEN P.ProximaFechaConteo <= CONVERT(date, GETDATE()) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
                    P.Activo
                FROM ALMA.PlanConteoCiclico P
                INNER JOIN ALMA.TipoBien T ON T.PKIdTipoBien = P.FKIdTipoBien_ALMA
                LEFT JOIN SIS.Area A ON A.PKIdArea = P.FKIdArea_SIS
                WHERE P.Activo = 1
                ORDER BY
                    CASE P.ClasificacionABC WHEN 'A' THEN 1 WHEN 'B' THEN 2 ELSE 3 END,
                    P.ProximaFechaConteo,
                    T.Descripcion;
                """;

            var items = new List<ConteoPlanificacionResponse>();
            var connection = _context.Database.GetDbConnection();
            var closeConnection = connection.State != ConnectionState.Open;
            if (closeConnection)
                await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();
                command.CommandText = sql;
                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    items.Add(new ConteoPlanificacionResponse
                    {
                        PkidPlanConteoCiclico = reader.GetInt32(0),
                        IdTipoBien = reader.GetInt32(1),
                        CodigoTipoBien = reader.GetString(2),
                        TipoBien = reader.GetString(3),
                        IdArea = reader.IsDBNull(4) ? null : reader.GetInt32(4),
                        Ubicacion = reader.GetString(5),
                        ClasificacionAbc = reader.GetString(6),
                        FrecuenciaDias = reader.GetInt32(7),
                        UltimaFechaConteo = reader.IsDBNull(8) ? null : DateOnly.FromDateTime(reader.GetDateTime(8)),
                        ProximaFechaConteo = DateOnly.FromDateTime(reader.GetDateTime(9)),
                        ExistenciaActual = reader.GetDecimal(10),
                        ExistenciaMinima = reader.IsDBNull(11) ? null : reader.GetDecimal(11),
                        ValorInventario = reader.GetDecimal(12),
                        GenerarPorUmbral = reader.GetBoolean(13),
                        RequiereConteoPorUmbral = reader.GetBoolean(14),
                        EstaVencido = reader.GetBoolean(15),
                        Activo = reader.GetBoolean(16)
                    });
                }
            }
            finally
            {
                if (closeConnection)
                    await connection.CloseAsync();
            }

            return items;
        }

        public async Task<IReadOnlyList<ConteoPlanificacionResponse>> ActualizarClasificacionAbcAsync(int usuarioActual)
        {
            await _context.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ALMA.SP_ActualizarPlanConteoCiclico @UsuarioActual={usuarioActual}");
            return await GetPlanificacionAsync();
        }

        public async Task<ConteoPlanificacionResponse> ActualizarPlanAsync(
            int id,
            ConteoPlanificacionUpdateRequest request,
            int usuarioActual)
        {
            if (request.FrecuenciaDias is < 1 or > 3650)
                throw new ArgumentException("La frecuencia debe estar entre 1 y 3650 dias.");
            if (request.ProximaFechaConteo < DateOnly.FromDateTime(DateTime.Today))
                throw new ArgumentException("La proxima fecha de conteo no puede estar en el pasado.");
            if (request.IdArea.HasValue && !await _context.Areas.AnyAsync(a => a.PkidArea == request.IdArea && a.Activo))
                throw new ArgumentException("La ubicacion seleccionada no existe o no esta activa.");

            var affected = await _context.Database.ExecuteSqlInterpolatedAsync($@"
                UPDATE ALMA.PlanConteoCiclico
                   SET FKIdArea_SIS = {request.IdArea},
                       FrecuenciaDias = {request.FrecuenciaDias},
                       FrecuenciaPersonalizada = 1,
                       ProximaFechaConteo = {request.ProximaFechaConteo},
                       GenerarPorUmbral = {request.GenerarPorUmbral},
                       RequiereConteoPorUmbral = CASE
                           WHEN {request.GenerarPorUmbral} = 1
                            AND ExistenciaMinima IS NOT NULL
                            AND ExistenciaActual > 0
                            AND ExistenciaActual <= ExistenciaMinima THEN 1 ELSE 0 END,
                       FechaModificacion = SYSDATETIME(),
                       UsuarioModificacion = {usuarioActual}
                 WHERE PKIdPlanConteoCiclico = {id} AND Activo = 1;");

            if (affected == 0)
                throw new KeyNotFoundException("Plan de conteo no encontrado.");

            return (await GetPlanificacionAsync()).First(p => p.PkidPlanConteoCiclico == id);
        }

        public async Task<int> GenerarConteosSugeridosAsync(int periodoId, int usuarioActual)
        {
            await using var command = _context.Database.GetDbConnection().CreateCommand();
            command.CommandText = "ALMA.SP_GenerarConteosCiclicosSugeridos";
            command.CommandType = CommandType.StoredProcedure;
            AddParameter(command, "@PKIdPeriodoConteo", periodoId);
            AddParameter(command, "@UsuarioActual", usuarioActual);

            var closeConnection = command.Connection!.State != ConnectionState.Open;
            if (closeConnection)
                await command.Connection.OpenAsync();
            try
            {
                var result = await command.ExecuteScalarAsync();
                return Convert.ToInt32(result ?? 0);
            }
            finally
            {
                if (closeConnection)
                    await command.Connection.CloseAsync();
            }
        }

        private static void AddParameter(DbCommand command, string name, object value)
        {
            var parameter = command.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value;
            command.Parameters.Add(parameter);
        }

        private async Task EnsureUniqueCodeAsync(PeriodoConteoDto dto, int? excludedId = null)
        {
            var duplicate = await _context.PeriodoConteos.AnyAsync(p =>
                p.Activo &&
                p.FkidSucursalSis == dto.FkidSucursalSis &&
                p.CodigoPeriodo == dto.CodigoPeriodo &&
                (!excludedId.HasValue || p.PkidPeriodoConteo != excludedId.Value));

            if (duplicate)
                throw new ArgumentException("Ya existe un periodo activo con ese codigo en la sucursal seleccionada.");
        }

        private async Task<PeriodoConteo> GetPeriodoEntityAsync(int id)
            => await _context.PeriodoConteos.FirstOrDefaultAsync(p => p.PkidPeriodoConteo == id && p.Activo)
               ?? throw new KeyNotFoundException("Periodo de conteo no encontrado.");

        private async Task EnsureCurrentStatusAsync(PeriodoConteo periodo, string expectedStatus)
        {
            var currentStatus = await _context.EstatusPeriodos
                .AsNoTracking()
                .Where(e => e.PkidEstatusPeriodo == periodo.FkidEstatusAlma)
                .Select(e => e.Nombre)
                .FirstOrDefaultAsync();

            if (!string.Equals(currentStatus, expectedStatus, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException($"La operacion solo se permite cuando el periodo esta en estatus {expectedStatus}.");
        }

        private async Task<int> GetStatusIdAsync(string status)
        {
            var statuses = await _context.EstatusPeriodos.AsNoTracking().Where(e => e.Activo).ToListAsync();
            return statuses.FirstOrDefault(e => string.Equals(e.Nombre, status, StringComparison.OrdinalIgnoreCase))?.PkidEstatusPeriodo
                   ?? throw new InvalidOperationException($"No existe el estatus activo '{status}'.");
        }

        private async Task<PeriodoConteoResponse> GetRequiredResponseAsync(int id)
            => await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo")
               ?? throw new InvalidOperationException("No fue posible recuperar el periodo actualizado.");
    }
}

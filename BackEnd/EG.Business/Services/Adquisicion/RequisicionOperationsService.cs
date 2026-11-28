using EG.Business.Services.Adquisicion;
using EG.Infrastructure;
using EG.Business.Interfaces;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Common.Modules;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.Adquisicion
{
    public class RequisicionOperationsService
        : AdquisicionCrudOperationsService<Requisicion, VwRequisicion, RequisicionDto, RequisicionResponse>,
            IRequisicionOperations
    {
        private readonly GenericService<Cotizacion, CotizacionDto, CotizacionResponse> _cotizacionService;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public RequisicionOperationsService(
            GenericService<Requisicion, RequisicionDto, RequisicionResponse> service,
            GenericService<VwRequisicion, RequisicionDto, RequisicionResponse> serviceView,
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> cotizacionService,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidRequisicion",
                "Requisicion",
                (dto, id) => dto.PkidRequisicion = id)
        {
            _cotizacionService = cotizacionService;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<EG.Domain.DTOs.Responses.General.UsuarioAreaResponse>> GetRequestersAsync()
        {
            var companyId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var userId = _userContext.GetCurrentUserId();
            var administrator = EG.Common.Security.SystemRoles.IsSuperAdmin(_userContext.GetUserPrincipal());
            var query = _context.PersonaAreas.AsNoTracking().Where(assignment =>
                assignment.Activo && assignment.EsSolicitante == true &&
                assignment.FkidAreaSisNavigation.Activo && assignment.FkidPersonaNomNavigation.Activo &&
                assignment.FkidPersonaNomNavigation.FkidEmpresaSis == companyId);
            if (!administrator)
            {
                query = query.Where(assignment => _context.VwUsuarioPersonaAreas.Any(access =>
                    access.PkIdUsuario == userId && access.UsuarioActivo && access.PersonaActivo == true &&
                    access.AreaActivo == true && access.EsSolicitante == true &&
                    access.PkidPersona == assignment.FkidPersonaNom && access.PkidArea == assignment.FkidAreaSis));
            }
            var items = await query.OrderBy(assignment => assignment.FkidAreaSisNavigation.Nombre)
                .ThenBy(assignment => assignment.FkidPersonaNomNavigation.Nombre)
                .Select(assignment => new EG.Domain.DTOs.Responses.General.UsuarioAreaResponse
                {
                    PkidPersonaArea = assignment.PkidPersonaArea,
                    PkidPersona = assignment.FkidPersonaNom,
                    PersonaClave = assignment.FkidPersonaNomNavigation.Clave,
                    PersonaNombre = assignment.FkidPersonaNomNavigation.Nombre,
                    PersonaPaterno = assignment.FkidPersonaNomNavigation.Paterno,
                    PersonaMaterno = assignment.FkidPersonaNomNavigation.Materno,
                    PkidArea = assignment.FkidAreaSis,
                    AreaClave = assignment.FkidAreaSisNavigation.Clave,
                    AreaNombre = assignment.FkidAreaSisNavigation.Nombre,
                    UsuarioAreaDescripcion = assignment.FkidAreaSisNavigation.Nombre,
                    Activo = true, EsSolicitante = true, IsAdscrito = assignment.IsAdscrito,
                    EsAutorizador = assignment.EsAutorizador == true
                }).ToListAsync();
            return new() { Success = true, Code = "SUCCESS", Items = items, TotalCount = items.Count };
        }

        public override async Task<PagedResult<RequisicionResponse>> CreateAsync(
            RequisicionResponse response,
            int usuarioActual)
        {
            try
            {
                response.FkidEmpresaSis = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
                await ValidateClasificacionAsync(response);
                if (!await OrcoProyectoCatalog.EnsureProyectoOrcoAsync(_context, response.FkidProyectoOrco, usuarioActual))
                {
                    return InvalidProyectoResult(response.FkidProyectoOrco);
                }

                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidRequisicion = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(response.PkidRequisicion);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (ArgumentException ex)
            {
                return ValidationResult(ex.Message);
            }
            catch (Exception ex)
            {
                return new PagedResult<RequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al crear Requisicion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public override async Task<PagedResult<RequisicionResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            await ApplyWorkflowStateAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success)
            {
                var records = (result.Items ?? new List<RequisicionResponse>()).ToList();
                if (result.Data != null && records.All(item => !ReferenceEquals(item, result.Data)))
                    records.Add(result.Data);

                await ApplyWorkflowStateAsync(records);
                if (records.Count > 0)
                {
                    var journey = await RequisitionJourneyReader.ReadAsync(_context, id,
                        _userContext.GetCurrentEmpresaId(), _userContext.GetCurrentAnioPresupuestalId());
                    foreach (var record in records) record.Journey = journey;
                }
            }

            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            await ApplyWorkflowStateAsync(result.Items);
            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> UpdateAsync(
            int id,
            RequisicionResponse response,
            int usuarioActual)
        {
            if (await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(_context, _userContext, id) == null)
                return NotFoundResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, id))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder editarla.");
            }

            try
            {
                response.FkidEmpresaSis = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
                await ValidateClasificacionAsync(response, id);
                if (!await OrcoProyectoCatalog.EnsureProyectoOrcoAsync(_context, response.FkidProyectoOrco, usuarioActual))
                {
                    return InvalidProyectoResult(response.FkidProyectoOrco);
                }

                var spResult = await StoredProcedureExecutor.ExecuteConcurrencyCheckedAsync<Requisicion>(
                    _context,
                    id,
                    response.RowVersion,
                    "Requisición",
                    () => ExecuteMantenimientoAsync(2, id, response, usuarioActual));
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (UserVisibleException ex)
            {
                return new PagedResult<RequisicionResponse>
                {
                    Success = false,
                    Message = ex.UserMessage,
                    Code = ex.Code,
                    TotalCount = 0
                };
            }
            catch (ArgumentException ex)
            {
                return ValidationResult(ex.Message);
            }
            catch (Exception ex)
            {
                return new PagedResult<RequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar Requisicion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
            => await DeleteAsync(id, 0);

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            if (await RequisicionWorkflowGuard.GetOwnedRequisicionAsync(_context, _userContext, id) == null)
                return NotFoundDeleteResult();

            if (await RequisicionWorkflowGuard.IsLockedAsync(_context, id))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder eliminarla.",
                    Code = "LOCKED",
                    Data = false,
                    Items = new List<bool> { false },
                    TotalCount = 0
                };
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoRequisicion]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdRequisicion", id),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual > 0 ? usuarioActual : null));

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
                    Message = $"Error al eliminar Requisicion: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            RequisicionResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoRequisicion]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdRequisicion", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdPersona_NOM", response.FkidPersonaNom),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@FechaRequisicion", response.FechaRequisicion),
                StoredProcedureExecutor.Param("@Servicio", response.Servicio),
                StoredProcedureExecutor.Param("@FL_FOTO", response.FlFoto),
                StoredProcedureExecutor.Param("@FKIdProyecto_ORCO", response.FkidProyectoOrco),
                StoredProcedureExecutor.Param("@FechaRequiereInicio", response.FechaRequiereInicio),
                StoredProcedureExecutor.Param("@FechaRequiereFin", response.FechaRequiereFin),
                StoredProcedureExecutor.Param("@FKIdPrograma_PRES", response.FkidProgramaPres),
                StoredProcedureExecutor.Param("@Importe", response.Importe),
                StoredProcedureExecutor.Param("@FKIdJefeAlmacen_NOM", response.FkidJefeAlmacenNom),
                StoredProcedureExecutor.Param("@FKIdSuficiencia_PRES", response.FkidSuficienciaPres),
                StoredProcedureExecutor.Param("@FKIdSuperviso_NOM", response.FkidSupervisoNom),
                StoredProcedureExecutor.Param("@FKIdAutorizo_NOM", response.FkidAutorizoNom),
                StoredProcedureExecutor.Param("@FKIdPSolicita_NOM", response.FkidPsolicitaNom),
                StoredProcedureExecutor.Param("@FKIdPJefeAlmacen_NOM", response.FkidPjefeAlmacenNom),
                StoredProcedureExecutor.Param("@FKIdPSuficiencia_NOM", response.FkidPsuficienciaNom),
                StoredProcedureExecutor.Param("@FKIdPSuperviso_NOM", response.FkidPsupervisoNom),
                StoredProcedureExecutor.Param("@FKIdPAutorizo_NOM", response.FkidPautorizoNom),
                StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", response.FkidFuenteFinanciamientoPres),
                StoredProcedureExecutor.Param("@FKIdAnio_SIS", response.FkidAnioSis),
                StoredProcedureExecutor.Param("@FKIdTipoGasto_PRES", response.FkidTipoGastoPres),
                StoredProcedureExecutor.Param("@FKIdDigitoIdentificador_PRES", response.FkidDigitoIdentificadorPres),
                StoredProcedureExecutor.Param("@FKIdDestinoGasto_PRES", response.FkidDestinoGastoPres),
                StoredProcedureExecutor.Param("@FKIdEgresoAutorizado_PRES", response.FkidEgresoAutorizadoPres),
                StoredProcedureExecutor.Param("@Oficio", response.Oficio),
                StoredProcedureExecutor.Param("@FechaOficio", response.FechaOficio),
                StoredProcedureExecutor.Param("@CompraDirecta", response.CompraDirecta),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private async Task ValidateClasificacionAsync(RequisicionResponse response, int? requisicionId = null)
        {
            response.FkidEmpresaSis = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            response.FkidAnioSis = _userContext.GetCurrentAnioPresupuestalId();
            if (string.IsNullOrWhiteSpace(response.Descripcion))
                response.Descripcion = string.Empty;
            if (response.FkidAreaSis <= 0)
                throw new ArgumentException("El area solicitante es requerida.");
            if (response.FkidPersonaNom <= 0)
                throw new ArgumentException("El solicitante es requerido.");
            if (!response.FkidAnioSis.HasValue || response.FkidAnioSis.Value <= 0)
                throw new ArgumentException("El anio presupuestal es requerido.");
            if (!response.FkidProgramaPres.HasValue ||
                !await _context.Programas.AsNoTracking().AnyAsync(x =>
                    x.PkidPrograma == response.FkidProgramaPres.Value &&
                    x.FkidAnioSis == response.FkidAnioSis.Value &&
                    x.Activo))
                throw new ArgumentException("El programa presupuestario es requerido y debe estar activo.");
            if (response.FkidFuenteFinanciamientoPres.HasValue &&
                !await _context.FuenteFinanciamientos.AsNoTracking().AnyAsync(x => x.PkidFuenteFinanciamiento == response.FkidFuenteFinanciamientoPres.Value && x.Activo))
                throw new ArgumentException("La fuente de financiamiento seleccionada no esta activa.");
            if (response.FkidTipoGastoPres.HasValue &&
                !await _context.TipoGastos.AsNoTracking().AnyAsync(x => x.PkidTipoGasto == response.FkidTipoGastoPres.Value && x.Activo))
                throw new ArgumentException("El tipo de gasto seleccionado no esta activo.");
            if (response.FkidDigitoIdentificadorPres.HasValue &&
                !await _context.DigitoIdentificadors.AsNoTracking().AnyAsync(x => x.PkidDigitoIdentificador == response.FkidDigitoIdentificadorPres.Value && x.Activo))
                throw new ArgumentException("El digito identificador seleccionado no esta activo.");
            if (response.FkidDestinoGastoPres.HasValue &&
                !await _context.DestinoGastos.AsNoTracking().AnyAsync(x => x.PkidDestinoGasto == response.FkidDestinoGastoPres.Value && x.Activo))
                throw new ArgumentException("El destino del gasto seleccionado no esta activo.");
            if (!response.Importe.HasValue || response.Importe.Value <= 0)
                throw new ArgumentException("El importe de la requisicion debe ser mayor a cero.");

            var dateValidation = RequisitionDateRules.Validate(
                response.FechaRequisicion,
                response.FechaRequiereInicio,
                response.FechaRequiereFin);
            if (dateValidation != null)
                throw new ArgumentException(dateValidation);

            var areaSolicitanteValido = await _context.PersonaAreas.AsNoTracking().AnyAsync(x =>
                x.FkidPersonaNom == response.FkidPersonaNom &&
                x.FkidAreaSis == response.FkidAreaSis &&
                x.EsSolicitante == true &&
                x.FkidPersonaNomNavigation.Activo &&
                x.FkidPersonaNomNavigation.FkidEmpresaSis == response.FkidEmpresaSis &&
                x.FkidAreaSisNavigation.Activo &&
                x.Activo);
            if (!areaSolicitanteValido)
            {
                var solicitante = await _context.Personas.AsNoTracking()
                    .Where(x => x.PkidPersona == response.FkidPersonaNom)
                    .Select(x => $"{x.Nombre} {x.Paterno} {x.Materno}")
                    .FirstOrDefaultAsync();
                var area = await _context.Areas.AsNoTracking()
                    .Where(x => x.PkidArea == response.FkidAreaSis)
                    .Select(x => x.Nombre)
                    .FirstOrDefaultAsync();

                throw new ArgumentException(
                    $"{(string.IsNullOrWhiteSpace(solicitante) ? "El solicitante" : solicitante.Trim())} no está habilitado como solicitante del área {(string.IsNullOrWhiteSpace(area) ? response.FkidAreaSis : area)}. " +
                    "Selecciona otro solicitante o pide a Administración de personal/sistema activar la relación Persona–Área con el permiso 'Es solicitante'.");
            }

            var usuarioId = _userContext.GetCurrentUserId();
            var areaDelUsuario = EG.Common.Security.SystemRoles.IsSuperAdmin(_userContext.GetUserPrincipal()) ||
                await _context.VwUsuarioPersonaAreas.AsNoTracking().AnyAsync(x =>
                x.PkIdUsuario == usuarioId &&
                x.PkidPersona == response.FkidPersonaNom &&
                x.PkidArea == response.FkidAreaSis &&
                x.UsuarioActivo &&
                x.PersonaActivo == true &&
                x.AreaActivo == true &&
                x.EsSolicitante == true);
            if (!areaDelUsuario)
                throw new ArgumentException(
                    "Tu usuario no tiene asignada esa persona y area como solicitante. " +
                    "Ve a Configuracion > Sistema > Usuarios, edita tu usuario y en 'Persona y areas' asigna el area. " +
                    "Si no tienes acceso, solicitalo a Administracion del sistema.");

            if (!response.FkidEgresoAutorizadoPres.HasValue)
                throw new ArgumentException("Debe seleccionar una posicion de presupuesto disponible.");

            var posicion = await _context.VwEgresoDisponibles.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidEgresoAutorizado == response.FkidEgresoAutorizadoPres.Value &&
                x.FkidEmpresaSis == response.FkidEmpresaSis &&
                x.FkidAnioSis == response.FkidAnioSis &&
                x.FkidAreaSis == response.FkidAreaSis);
            if (posicion == null)
                throw new ArgumentException("La posicion presupuestal no pertenece al anio y area seleccionados.");
            if (posicion.Total.GetValueOrDefault() <= 0)
                throw new ArgumentException("La posicion presupuestal seleccionada no tiene saldo disponible.");
            if (posicion.FkidProgramaPres != response.FkidProgramaPres ||
                posicion.FkidFuenteFinanciamientoPres != response.FkidFuenteFinanciamientoPres ||
                posicion.FkidTipoGastoPres != response.FkidTipoGastoPres ||
                posicion.FkidDigitoIdentificadorPres != response.FkidDigitoIdentificadorPres ||
                posicion.FkidDestinoGastoPres != response.FkidDestinoGastoPres)
                throw new ArgumentException("La clasificacion no corresponde a la posicion presupuestal seleccionada.");

            if (response.FkidProyectoOrco != posicion.FkidPyPres)
                throw new ArgumentException("El proyecto no corresponde a la posicion presupuestal seleccionada.");

            if (requisicionId.HasValue)
            {
                var partidas = await _context.RequisicionPartida.AsNoTracking()
                    .Where(x => x.Activo && x.FkidRequisicionOrco == requisicionId.Value)
                    .Select(x => new
                    {
                        x.Monto,
                        x.FkidEgresoAutorizadoPres,
                        x.FkidPartidaConta
                    })
                    .ToListAsync();
                if (partidas.Sum(x => x.Monto ?? 0m) > response.Importe.Value)
                    throw new ArgumentException("El nuevo importe es menor que el monto ya distribuido en partidas.");

                if (partidas.Any(partida => !partida.FkidEgresoAutorizadoPres.HasValue))
                    throw new ArgumentException("Existen partidas sin posicion presupuestal; corrigelas antes de editar la requisicion.");

                var posicionesIds = partidas
                    .Select(partida => partida.FkidEgresoAutorizadoPres!.Value)
                    .Distinct()
                    .ToArray();
                var posiciones = await _context.VwEgresoDisponibles
                    .AsNoTracking()
                    .Where(posicion => posicionesIds.Contains(posicion.PkidEgresoAutorizado))
                    .Select(posicion => new
                    {
                        posicion.PkidEgresoAutorizado,
                        posicion.FkidPartidaConta,
                        posicion.FkidAnioSis,
                        posicion.FkidAreaSis,
                        posicion.FkidProgramaPres,
                        posicion.FkidFuenteFinanciamientoPres,
                        posicion.FkidTipoGastoPres,
                        posicion.FkidDigitoIdentificadorPres,
                        posicion.FkidDestinoGastoPres,
                        posicion.FkidPyPres
                    })
                    .ToDictionaryAsync(posicion => posicion.PkidEgresoAutorizado);

                foreach (var partida in partidas)
                {
                    var partidaPosicionId = partida.FkidEgresoAutorizadoPres!.Value;
                    if (!posiciones.TryGetValue(partidaPosicionId, out var partidaPosicion) ||
                        partidaPosicion.FkidPartidaConta != partida.FkidPartidaConta ||
                        partidaPosicion.FkidAnioSis != response.FkidAnioSis ||
                        partidaPosicion.FkidAreaSis != response.FkidAreaSis ||
                        partidaPosicion.FkidProgramaPres != response.FkidProgramaPres ||
                        partidaPosicion.FkidFuenteFinanciamientoPres != response.FkidFuenteFinanciamientoPres ||
                        partidaPosicion.FkidTipoGastoPres != response.FkidTipoGastoPres ||
                        partidaPosicion.FkidDigitoIdentificadorPres != response.FkidDigitoIdentificadorPres ||
                        partidaPosicion.FkidDestinoGastoPres != response.FkidDestinoGastoPres ||
                        partidaPosicion.FkidPyPres != response.FkidProyectoOrco)
                    {
                        throw new ArgumentException(
                            "La nueva clasificacion no es compatible con las partidas existentes; elimina o corrige las partidas primero.");
                    }
                }
            }
        }

        private int CountActiveCotizaciones(int requisicionId)
        {
            return _cotizacionService.GetQueryWithIncludes()
                .Count(x => x.FkidRequisicionOrco == requisicionId);
        }

        private async Task ApplyWorkflowStateAsync(IList<RequisicionResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var requisicionIds = items.Select(x => x.PkidRequisicion).Distinct().ToList();
            var counts = await _cotizacionService.GetQueryWithIncludes()
                .Where(x => requisicionIds.Contains(x.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionOrco)
                .ToDictionaryAsync(x => x.Key, x => x.Count());

            var partidas = await _context.RequisicionPartida
                .AsNoTracking()
                .Where(x => x.Activo && requisicionIds.Contains(x.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionOrco)
                .Select(group => new
                {
                    RequisicionId = group.Key,
                    Total = group.Count(),
                    ConPosicionPresupuestal = group.Count(x => x.FkidEgresoAutorizadoPres.HasValue),
                    Monto = group.Sum(x => x.Monto ?? 0m)
                })
                .ToDictionaryAsync(x => x.RequisicionId);

            var detalles = await _context.RequisicionDetalles
                .AsNoTracking()
                .Where(x => x.Activo && requisicionIds.Contains(x.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionOrco)
                .ToDictionaryAsync(x => x.Key, x => x.Count());

            var cotizados = await _context.CotizacionDetalles
                .AsNoTracking()
                .Where(x =>
                    x.Activo &&
                    x.PrecioUnitario.HasValue &&
                    x.PrecioUnitario.Value > 0 &&
                    x.FkidCotizacionOrcoNavigation.Activo &&
                    x.FkidRequisicionDetalleOrcoNavigation.Activo &&
                    requisicionIds.Contains(x.FkidRequisicionDetalleOrcoNavigation.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionDetalleOrcoNavigation.FkidRequisicionOrco)
                .Select(group => new
                {
                    RequisicionId = group.Key,
                    Total = group.Select(x => x.FkidRequisicionDetalleOrco).Distinct().Count()
                })
                .ToDictionaryAsync(x => x.RequisicionId, x => x.Total);

            var enSuficiencia = await _context.SolicitudSuficienciaDetalles
                .AsNoTracking()
                .Where(x =>
                    x.Activo &&
                    x.FkidSolicitudSuficienciaPresNavigation.Activo &&
                    x.FkidRequisicionDetalleOrcoNavigation.Activo &&
                    requisicionIds.Contains(x.FkidRequisicionDetalleOrcoNavigation.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionDetalleOrcoNavigation.FkidRequisicionOrco)
                .Select(group => new
                {
                    RequisicionId = group.Key,
                    Total = group.Select(x => x.FkidRequisicionDetalleOrco).Distinct().Count()
                })
                .ToDictionaryAsync(x => x.RequisicionId, x => x.Total);

            var suficiencias = await _context.SolicitudSuficiencia
                .AsNoTracking()
                .Where(x => x.Activo && requisicionIds.Contains(x.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionOrco)
                .ToDictionaryAsync(x => x.Key, x => x.Count());

            foreach (var item in items)
            {
                item.CotizacionesActivas = counts.TryGetValue(item.PkidRequisicion, out var count) ? count : 0;
                item.SuficienciasActivas = suficiencias.TryGetValue(item.PkidRequisicion, out var suficienciaActivaCount)
                    ? suficienciaActivaCount
                    : 0;
                if (partidas.TryGetValue(item.PkidRequisicion, out var partidaState))
                {
                    item.PartidasActivas = partidaState.Total;
                    item.PartidasConPosicionPresupuestal = partidaState.ConPosicionPresupuestal;
                    item.MontoPartidas = partidaState.Monto;
                }
                else
                {
                    item.PartidasActivas = 0;
                    item.PartidasConPosicionPresupuestal = 0;
                    item.MontoPartidas = 0m;
                }
                item.DetallesActivos = detalles.TryGetValue(item.PkidRequisicion, out var detalleCount) ? detalleCount : 0;
                item.DetallesCotizados = cotizados.TryGetValue(item.PkidRequisicion, out var cotizadoCount) ? cotizadoCount : 0;
                item.DetallesEnSuficiencia = enSuficiencia.TryGetValue(item.PkidRequisicion, out var suficienciaCount) ? suficienciaCount : 0;
            }
        }

        private static PagedResult<RequisicionResponse> NotFoundResult() => new()
        {
            Success = false,
            Message = "La requisicion no existe, esta inactiva o no pertenece a la empresa actual.",
            Code = "NOT_FOUND",
            TotalCount = 0
        };

        private static PagedResult<bool> NotFoundDeleteResult() => new()
        {
            Success = false,
            Message = "La requisicion no existe, esta inactiva o no pertenece a la empresa actual.",
            Code = "NOT_FOUND",
            Data = false,
            TotalCount = 0
        };

        private static PagedResult<RequisicionResponse> LockedResult(string message)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static PagedResult<RequisicionResponse> ValidationResult(string message)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "VALIDATION",
                TotalCount = 0
            };
        }

        private static PagedResult<RequisicionResponse> InvalidProyectoResult(int? proyectoId)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = proyectoId.HasValue
                    ? $"El proyecto seleccionado ({proyectoId.Value}) no existe en ORCO.Proyecto o no esta activo."
                    : "El proyecto seleccionado no es valido.",
                Code = "INVALID_ORCO_PROJECT",
                TotalCount = 0
            };
        }
    }
}

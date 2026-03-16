using AutoMapper;
using AutoMapper.QueryableExtensions;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Requests.ConteoCiclico.EG.Domain.DTOs.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.ConteoCiclico
{
    public class ConteoCiclicoService : IConteoCiclicoService
    {
        private readonly IPeriodoConteoAppService _periodoService;
        private readonly IArticuloConteoAppService _articuloService;
        private readonly IRegistroConteoAppService _registroService;

        // Servicios genéricos para operaciones directas sobre entidades
        private readonly GenericService<ArticuloConteo, ArticuloConteoDto, ArticuloConteoResponse> _articuloEntityService;
        private readonly GenericService<RegistroConteo, RegistroConteoDto, RegistroConteoResponse> _registroEntityService;
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _periodoEntityService;

        // Servicios genéricos para vistas (consultas)
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _periodoViewService;
        private readonly GenericService<VwArticuloConteo, ArticuloConteoDto, ArticuloConteoResponse> _articuloViewService;
        private readonly GenericService<VwRegistroConteo, RegistroConteoDto, RegistroConteoResponse> _registroViewService;

        // Servicio para el catálogo de tipos de bien (TipoBien) que reemplaza al anterior "Articulo"
        private readonly GenericService<TipoBien, TipoBienDto, TipoBienResponse> _tipoBienService;

        private readonly ILogger<ConteoCiclicoService> _logger;
        private readonly IMapper _mapper;

        public ConteoCiclicoService(
            IPeriodoConteoAppService periodoService,
            IArticuloConteoAppService articuloService,
            IRegistroConteoAppService registroService,
            GenericService<ArticuloConteo, ArticuloConteoDto, ArticuloConteoResponse> articuloEntityService,
            GenericService<RegistroConteo, RegistroConteoDto, RegistroConteoResponse> registroEntityService,
            GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> periodoEntityService,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> periodoViewService,
            GenericService<VwArticuloConteo, ArticuloConteoDto, ArticuloConteoResponse> articuloViewService,
            GenericService<VwRegistroConteo, RegistroConteoDto, RegistroConteoResponse> registroViewService,
            GenericService<TipoBien, TipoBienDto, TipoBienResponse> tipoBienService,
            ILogger<ConteoCiclicoService> logger,
            IMapper mapper)
        {
            _periodoService = periodoService;
            _articuloService = articuloService;
            _registroService = registroService;
            _articuloEntityService = articuloEntityService;
            _registroEntityService = registroEntityService;
            _periodoEntityService = periodoEntityService;
            _periodoViewService = periodoViewService;
            _articuloViewService = articuloViewService;
            _registroViewService = registroViewService;
            _tipoBienService = tipoBienService;
            _logger = logger;
            _mapper = mapper;
        }

        // ==================== GENERAR CONTEO ====================
        public async Task<ConteoResult> GenerarConteoAsync(GenerarConteoRequest request, int usuarioActual)
        {
            try
            {
                // Validar periodo
                var periodo = await _periodoService.GetByIdAsync(request.PeriodoId);
                if (periodo == null)
                    return new ConteoResult { Success = false, Message = "Periodo no encontrado" };
                if (!periodo.Activo)
                    return new ConteoResult { Success = false, Message = "El periodo no está activo" };
                if (periodo.FechaCierre.HasValue)
                    return new ConteoResult { Success = false, Message = "No se puede generar conteo para un periodo cerrado" };

                // Obtener tipos de bien del catálogo (solo activos)
                var tiposBienQuery = _tipoBienService.GetQueryWithIncludes()
                    .Where(t => t.Activo);

                // NOTA: La entidad TipoBien no tiene SucursalId, por lo que no podemos filtrar por sucursal directamente.
                // Si se requiere filtrar por sucursal, se debe contar con una tabla intermedia (ej. Inventario) que relacione TipoBien con Sucursal y existencia.
                // Por ahora, se obtienen todos los tipos de bien activos.
                var tiposBien = await tiposBienQuery.ToListAsync();

                // Si se proporcionan IDs específicos, filtrar por ellos (asumiendo que los IDs corresponden a PkidTipoBien)
                if (request.ArticulosSeleccionados?.Any() == true)
                {
                    tiposBien = tiposBien.Where(t => request.ArticulosSeleccionados.Contains(t.PkidTipoBien)).ToList();
                }

                if (!tiposBien.Any())
                    return new ConteoResult { Success = false, Message = "No hay tipos de bien para generar en el conteo" };

                // Crear ArticuloConteo para cada tipo de bien
                var articulosConteo = new List<ArticuloConteoDto>();
                foreach (var tipo in tiposBien)
                {
                    // NOTA: Se requiere información de existencia por sucursal. Si no está disponible, se puede obtener de otra entidad (ej. Inventario) o dejar en 0.
                    // Por ahora, se asigna ExistenciaSistema = 0 y se omite Ubicación.
                    var nuevo = new ArticuloConteoDto
                    {
                        FkidPeriodoConteoAlma = request.PeriodoId,
                        FkidSucursalSis = request.SucursalId,  // SucursalId viene en el request
                        FkidTipoBienAlma = tipo.PkidTipoBien,
                        FkidEstatusAlma = 1, // Estatus inicial "Pendiente"
                        CodigoBarras = tipo.CodigoClave,       // Usamos CodigoClave como código de barras
                        DescripcionArticulo = tipo.Descripcion,
                        UnidadMedida = tipo.FkidUnidadesAlma?.ToString() ?? "", // Si no se tiene unidad, se puede obtener de la navegación
                        Ubicacion = string.Empty, // No disponible en TipoBien, podría venir de otra fuente
                        ExistenciaSistema = 0,    // Valor por defecto; se debe obtener del inventario real
                        ConteosRealizados = 0,
                        ConteosPendientes = periodo.MaximoConteosPorArticulo,
                        Activo = true,
                        FechaCreacion = DateTime.Now,
                        UsuarioCreacion = usuarioActual
                    };
                    articulosConteo.Add(nuevo);
                }

                // Guardar cada artículo (podría optimizarse con AddRange si el servicio lo soporta)
                foreach (var dto in articulosConteo)
                {
                    await _articuloEntityService.AddAsync(dto);
                }

                // Actualizar contadores del periodo usando servicio de entidad
                var _periodoEntity = await _periodoEntityService.GetByIdAsync(request.PeriodoId);

                var periodoEntity = _mapper.Map<PeriodoConteoDto>(_periodoEntity);

                if (periodoEntity != null)
                {
                    periodoEntity.TotalArticulos = articulosConteo.Count;
                    periodoEntity.ArticulosConcluidos = 0;
                    periodoEntity.ArticulosConDiferencia = 0;
                    await _periodoEntityService.UpdateAsync(request.PeriodoId, periodoEntity);
                }

                return new ConteoResult
                {
                    Success = true,
                    Message = $"Se generaron {articulosConteo.Count} artículos para el conteo",
                    Data = articulosConteo.Select(a => a.PkidArticuloConteo).ToList()
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al generar conteo");
                return new ConteoResult { Success = false, Message = ex.Message };
            }
        }

        // ==================== INICIAR CONTEO ====================
        public async Task<ConteoResult> IniciarConteoAsync(int articuloConteoId, int usuarioActual)
        {
            try
            {
                var articulo = await _articuloService.GetByIdAsync(articuloConteoId);
                if (articulo == null)
                    return new ConteoResult { Success = false, Message = "Artículo no encontrado" };

                if (articulo.FechaCierre.HasValue)
                    return new ConteoResult { Success = false, Message = "El artículo ya está concluido" };

                // Actualizar fecha de inicio usando el servicio de entidad
                await _articuloEntityService.UpdateAsync(articuloConteoId, new ArticuloConteoDto
                {
                    PkidArticuloConteo = articuloConteoId,
                    FechaInicioConteo = DateTime.Now,
                    UsuarioModificacion = usuarioActual
                });

                return new ConteoResult { Success = true, Message = "Conteo iniciado correctamente" };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al iniciar conteo");
                return new ConteoResult { Success = false, Message = ex.Message };
            }
        }

        // ==================== REGISTRAR CONTEO ====================
        public async Task<ConteoResult> RegistrarConteoAsync(RegistrarConteoRequest request, int usuarioActual)
        {
            try
            {
                var articulo = await _articuloService.GetByIdAsync(request.ArticuloConteoId);
                if (articulo == null)
                    return new ConteoResult { Success = false, Message = "Artículo no encontrado" };

                if (articulo.FechaCierre.HasValue)
                    return new ConteoResult { Success = false, Message = "El artículo ya está concluido" };

                if (articulo.ArticulosConcluidos.Value >= articulo.MaximoConteosPorArticulo)
                    return new ConteoResult { Success = false, Message = "Ya se alcanzó el máximo de conteos permitidos" };

                // Crear registro de conteo
                var registroDto = new RegistroConteoDto
                {
                    FkidArticuloConteoAlma = request.ArticuloConteoId,
                    FkidPeriodoConteoAlma = articulo.Id,
                    FkidSucursalSis = articulo.SucursalId,
                    NumeroConteo = articulo.ArticulosConcluidos.Value + 1,
                    CantidadContada = request.CantidadContada,
                    FechaConteo = DateTime.Now,
                    FkidUsuarioSis = usuarioActual,
                    Observaciones = request.Observaciones,
                    EsReconteo = request.EsReconteo,
                    FotoPath = request.FotoPath,
                    Latitud = request.Latitud,
                    Longitud = request.Longitud,
                    Activo = true,
                    FechaCreacion = DateTime.Now
                };

                await _registroEntityService.AddAsync(registroDto);

                // Actualizar artículo
                var articuloDto = new ArticuloConteoDto
                {
                    PkidArticuloConteo = request.ArticuloConteoId,
                    ConteosRealizados = articulo.ArticulosConcluidos.Value + 1,
                    ConteosPendientes = articulo.MaximoConteosPorArticulo - 1,  //eae  validar esto
                    UsuarioModificacion = usuarioActual
                };

                // Si es el primer conteo, guardar como existencia final temporal
                if (articulo.ArticulosConcluidos.Value == 0)
                {
                    articuloDto.ExistenciaFinal = request.CantidadContada;
                }

                await _articuloEntityService.UpdateAsync(request.ArticuloConteoId, articuloDto);

                // Verificar cierre automático
                if (articulo.ArticulosConcluidos.Value + 1 >= articulo.MaximoConteosPorArticulo)
                {
                    await CerrarConteoInternoAsync(request.ArticuloConteoId, usuarioActual);
                }

                return new ConteoResult
                {
                    Success = true,
                    Message = "Conteo registrado correctamente",
                    Data = registroDto.PkidRegistroConteo
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar conteo");
                return new ConteoResult { Success = false, Message = ex.Message };
            }
        }

        // ==================== CERRAR CONTEO ====================
        public async Task<ConteoResult> CerrarConteoAsync(CerrarConteoRequest request, int usuarioActual)
        {
            try
            {
                var articulo = await _articuloService.GetByIdAsync(request.ArticuloConteoId);
                if (articulo == null)
                    return new ConteoResult { Success = false, Message = "Artículo no encontrado" };

                if (articulo.FechaCierre.HasValue)
                    return new ConteoResult { Success = false, Message = "El artículo ya está concluido" };

                // Obtener registros del artículo
                var registrosPaged = await _registroService.GetByArticuloConteoIdAsync(request.ArticuloConteoId);
                var registros = registrosPaged.Items;
                if (!registros.Any())
                    return new ConteoResult { Success = false, Message = "No hay registros de conteo para cerrar" };

                // Determinar existencia final
                decimal existenciaFinal = request.ExistenciaFinal ?? registros.OrderByDescending(r => r.FechaConteo).First().CantidadContada;

                // Calcular diferencia
                var diferencia = existenciaFinal - articulo.TotalArticulos;
                var porcentaje = articulo.TotalArticulos != 0
                    ? (diferencia / articulo.TotalArticulos) * 100
                    : (diferencia != 0 ? 100 : 0);

                // Actualizar artículo
                var articuloDto = new ArticuloConteoDto
                {
                    PkidArticuloConteo = request.ArticuloConteoId,
                    ExistenciaFinal = existenciaFinal,
                    Diferencia = diferencia,
                    PorcentajeDiferencia = porcentaje,
                    FechaConclusion = DateTime.Now,
                    FkidUsuarioConcluyoSis = usuarioActual,
                    FkidEstatusAlma = 2, // Estatus "Concluido"
                    UsuarioModificacion = usuarioActual
                };
                await _articuloEntityService.UpdateAsync(request.ArticuloConteoId, articuloDto);

                // Actualizar estadísticas del periodo
                await ActualizarEstadisticasPeriodo(articulo.Id);

                return new ConteoResult { Success = true, Message = "Conteo cerrado correctamente" };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cerrar conteo");
                return new ConteoResult { Success = false, Message = ex.Message };
            }
        }

        // ==================== DASHBOARD ====================
        // ==================== DASHBOARD ====================
        public async Task<DashboardResponse> GetDashboardAsync(int? sucursalId = null)
        {
            try
            {
                var dashboard = new DashboardResponse();

                // Consultas usando servicios de vistas
                var queryPeriodos = _periodoViewService.GetQueryWithIncludes().Where(p => p.Activo);
                var queryArticulos = _articuloViewService.GetQueryWithIncludes().Where(a => a.Activo);
                var queryRegistros = _registroViewService.GetQueryWithIncludes().Where(r => r.Activo);

                if (sucursalId.HasValue)
                {
                    queryPeriodos = queryPeriodos.Where(p => p.SucursalId == sucursalId);
                    queryArticulos = queryArticulos.Where(a => a.SucursalId == sucursalId);
                    queryRegistros = queryRegistros.Where(r => r.SucursalId == sucursalId);
                }

                // Totales generales (usando CountAsync directamente sobre entidades, está bien)
                dashboard.TotalPeriodosActivos = await queryPeriodos.CountAsync();
                dashboard.TotalArticulosEnConteo = await queryArticulos.CountAsync(a => a.EstaConcluido == 0);
                dashboard.TotalArticulosConcluidos = await queryArticulos.CountAsync(a => a.EstaConcluido == 1);
                dashboard.TotalArticulosConDiferencia = await queryArticulos.CountAsync(a => a.Diferencia != 0);

                var totalArticulos = await queryArticulos.CountAsync();
                dashboard.PorcentajeAvanceGeneral = totalArticulos > 0
                    ? (decimal)dashboard.TotalArticulosConcluidos / totalArticulos * 100
                    : 0;

                // Resumen por periodo (mapeo con ProjectTo)
                dashboard.PeriodosResumen = await queryPeriodos
                    .Select(p => new PeriodoResumen
                    {
                        PeriodoId = p.Id,
                        PeriodoNombre = p.Nombre,
                        SucursalNombre = p.SucursalNombre,
                        TotalArticulos = p.TotalArticulos ?? 0,
                        Concluidos = p.ArticulosConcluidos ?? 0,
                        Pendientes = p.ArticulosPendientes ?? 0,
                        ConDiferencia = p.ArticulosConDiferencia ?? 0,
                        PorcentajeAvance = p.PorcentajeAvance ?? 0,
                        EstatusNombre = p.EstatusNombre
                    })
                    .Take(5)
                    .ToListAsync();

                // Últimos artículos concluidos (mapeados con ProjectTo)
                dashboard.UltimosArticulosConcluidos = await queryArticulos
                    .Where(a => a.EstaConcluido == 1)
                    .OrderByDescending(a => a.FechaConclusion) // 👈 Corregido (antes usaba .HasValue)
                    .Take(5)
                    .ProjectTo<ArticuloConteoResponse>(_mapper.ConfigurationProvider) // 👈 Mapeo a DTO
                    .ToListAsync();

                // Últimos registros de conteo (mapeados con ProjectTo)
                dashboard.UltimosRegistros = await queryRegistros
                    .OrderByDescending(r => r.FechaConteo)
                    .Take(10)
                    .ProjectTo<RegistroConteoResponse>(_mapper.ConfigurationProvider) // 👈 Mapeo a DTO
                    .ToListAsync();

                return dashboard;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener dashboard");
                throw;
            }
        }

        // ==================== MÉTODOS PRIVADOS ====================
        private async Task CerrarConteoInternoAsync(int articuloConteoId, int usuarioActual)
        {
            var request = new CerrarConteoRequest { ArticuloConteoId = articuloConteoId };
            await CerrarConteoAsync(request, usuarioActual);
        }

        private async Task ActualizarEstadisticasPeriodo(int periodoId)
        {
            // Obtener todos los artículos del periodo usando el servicio AppService
            var articulosPaged = await _articuloService.GetByPeriodoIdAsync(periodoId);
            var articulos = articulosPaged.Items;

            var total = articulos.Count;
            var concluidos = articulos.Count(a => a.FechaCierre.HasValue);
            var conDiferencia = articulos.Count(a => a.ArticulosConDiferencia != 0 && a.ArticulosConDiferencia.HasValue);

            // Actualizar periodo usando servicio de entidad
            var _periodoDto = await _periodoEntityService.GetByIdAsync(periodoId);
            if (_periodoDto != null)
            {
                var periodoDto = _mapper.Map<PeriodoConteoDto>(_periodoDto);
                periodoDto.TotalArticulos = total;
                periodoDto.ArticulosConcluidos = concluidos;
                periodoDto.ArticulosConDiferencia = conDiferencia;
                await _periodoEntityService.UpdateAsync(periodoId, periodoDto);
            }
        }
    }
}
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.General
{
    public class DashboardAppService : IDashboardAppService
    {
        private readonly EGestionContext _context;
        private readonly ILogger<DashboardAppService> _logger;

        public DashboardAppService(EGestionContext context, ILogger<DashboardAppService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<PagedResult<DashboardResumenResponse>> GetResumenAsync()
        {
            try
            {
                var proveedoresTask = _context.Set<Proveedor>().CountAsync(p => p.Activo);
                var unidadesTask = _context.Set<Area>().CountAsync(a => a.Activo);
                var fraccionesTask = _context.Set<Fraccion>().CountAsync(f => f.Activo);
                var gruposBienTask = _context.Set<GrupoBien>().CountAsync(g => g.Activo);
                var conceptosTask = _context.Set<Concepto>().CountAsync(c => c.Activo);
                var articulosTask = _context.Set<Articulo>().CountAsync(a => a.Activo);
                var tipoCambioTask = _context.Set<TipoCambio>().CountAsync(t => t.Activo);
                var usuariosTask = _context.Set<Usuario>().CountAsync(u => u.Activo);

                await Task.WhenAll(
                    proveedoresTask, unidadesTask, fraccionesTask, gruposBienTask,
                    conceptosTask, articulosTask, tipoCambioTask, usuariosTask);

                var response = new DashboardResumenResponse
                {
                    Conteos = new List<ConteoResumen>
                    {
                        new() { Etiqueta = "Proveedores", Conteo = await proveedoresTask },
                        new() { Etiqueta = "Unidades Responsables", Conteo = await unidadesTask },
                        new() { Etiqueta = "Fracciones", Conteo = await fraccionesTask },
                        new() { Etiqueta = "Grupos de Bien", Conteo = await gruposBienTask },
                        new() { Etiqueta = "Conceptos", Conteo = await conceptosTask },
                        new() { Etiqueta = "Artículos", Conteo = await articulosTask },
                        new() { Etiqueta = "Tipos de Cambio", Conteo = await tipoCambioTask },
                        new() { Etiqueta = "Usuarios", Conteo = await usuariosTask },
                    }
                };

                return new PagedResult<DashboardResumenResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<DashboardResumenResponse> { response },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen del dashboard");
                return new PagedResult<DashboardResumenResponse>
                {
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    Code = "ERROR"
                };
            }
        }
    }
}

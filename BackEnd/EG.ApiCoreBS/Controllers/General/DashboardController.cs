using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly EGestionContext _context;
        private readonly ILogger<DashboardController> _logger;

        public DashboardController(EGestionContext context, ILogger<DashboardController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DashboardResumenResponse>>> GetResumen()
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

                return Ok(new PagedResult<DashboardResumenResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<DashboardResumenResponse> { response },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen del dashboard");
                return Ok(new PagedResult<DashboardResumenResponse>
                {
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }
    }
}
